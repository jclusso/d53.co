# Replays DNS responses recorded in `test/dns_recordings` so tests don't
# depend on public resolvers answering. Run tests with `RECORD_DNS=1` to query
# the live servers and rewrite the recordings. They live outside
# `test/fixtures` because `fixtures :all` loads every YAML file there.
module RecordedDNS
  DIR = Rails.root.join('test/dns_recordings')

  def self.path(server, message)
    question = message.question.first
    name = [question.qname.to_s.downcase, question.qtype.to_s]
    name << 'cd' if message.header.cd

    DIR.join(server, "#{name.join('-')}.yml")
  end

  def self.record(path)
    response = yield
    save(path, response, nil)
    response
  rescue Dnsruby::ResolvError, Dnsruby::ResolvTimeout => e
    save(path, e.try(:response), e)
    raise
  end

  def self.save(path, response, error)
    FileUtils.mkdir_p(path.dirname)
    path.write(
      {
        'response' => response && Base64.strict_encode64(response.encode),
        'error' => error&.class&.name
      }.to_yaml
    )
  end

  def self.replay(path)
    unless path.exist?
      raise "No DNS recording at #{path.relative_path_from(Rails.root)}. " \
            'Run the test with RECORD_DNS=1 to record it.'
    end

    recording = YAML.load_file(path)
    response = recording['response'] &&
      Dnsruby::Message.decode(Base64.strict_decode64(recording['response']))
    return response unless recording['error']

    error = recording['error'].constantize.new
    error.response = response if error.respond_to?(:response=)
    raise error
  end

  def send_message(message)
    path = RecordedDNS.path(config.nameserver.first, message)
    return RecordedDNS.record(path) { super } if ENV['RECORD_DNS']

    RecordedDNS.replay(path)
  end
end

Dnsruby::Resolver.prepend(RecordedDNS)
