class DNSLookup

  attr_reader :duration

  def initialize(server)
    @server = server
  end

  def run(domain, type)
    start_time = Time.monotonic_now
    resolver = Dnsruby::Resolver.new(do_caching: false, nameserver: @server)
    if type == 'PTR' && is_ip?(domain)
      domain = "#{domain.split('.').reverse.join('.')}.in-addr.arpa"
    end
    response = resolver.query(domain, type)
    @duration = (Time.monotonic_now - start_time) * 1000

    {
      json: {
        status: response.rcode.to_s,
        from: @server,
        answer: (response.answer.present? ? format_answer(response.answer) : nil)
      }.compact,
      zone: response.to_s
    }.compact
  rescue Dnsruby::NXDomain => e
    { json: { status: 'NXDOMAIN', from: @server }, zone: e.response.to_s }
  rescue Dnsruby::ServFail => e
    { json: { status: 'SERVFAIL', from: @server }, zone: e.response.to_s }
  rescue Dnsruby::ResolvTimeout
    { json: { status: 'TIMEOUT', from: @server } }
  rescue Dnsruby::NotImp => e
    { json: { status: 'NOTIMP', from: @server }, zone: e.response.to_s }
  rescue Dnsruby::OtherResolvError
    { json: { status: 'OTHER ERROR', from: @server } }
  end

  private

  def format_answer(answers)
    answers.map do |answer|
      hash = { type: answer.type.to_s }
      case answer
      when Dnsruby::RR::IN::A, Dnsruby::RR::IN::AAAA
        hash[:address] = answer.address.to_s
      when Dnsruby::RR::IN::CAA
        hash.merge!(
          flag: answer.flag.to_i,
          property_tag: answer.property_tag,
          property_value: answer.property_value
        )
      when Dnsruby::RR::IN::CERT
        hash.merge!(
          algorithm: answer.alg&.to_s,
          cert: answer.cert,
          certtype: answer.certtype&.to_s,
          keytag: answer.keytag
        )
      when Dnsruby::RR::IN::CNAME
        hash.merge!(name: answer.domainname.to_s)
      when Dnsruby::RR::IN::DNSKEY
        hash.merge!(
          algorithm: answer.algorithm&.to_s,
          flags: answer.flags,
          key: encode_as_b64(answer.key.to_s),
          key_tag: answer.key_tag,
          protocol: answer.protocol
        )
      when Dnsruby::RR::IN::DS
        hash.merge!(
          algorithm: answer.algorithm&.to_s,
          digest: answer.digest,
          digest_type: answer.digest_type&.to_s,
          key_tag: answer.key_tag
        )
      when Dnsruby::RR::IN::HINFO
        hash[:data] = answer.cpu
      when Dnsruby::RR::IN::MX
        hash.merge!(
          exchange: answer.exchange.to_s,
          preference: answer.preference
        )
      when Dnsruby::RR::IN::NS
        hash[:name] = answer.domainname.to_s
      when Dnsruby::RR::IN::PTR
        hash[:name] = answer.domainname.to_s
      when Dnsruby::RR::IN::SOA
        hash.merge!(
          expire: answer.expire,
          minimum: answer.minimum,
          mname: answer.mname&.to_s,
          refresh: answer.refresh,
          retry: answer.retry,
          rname: answer.rname&.to_s,
          serial: answer.serial,
        )
      when Dnsruby::RR::IN::TXT
        hash[:strings] = answer.strings
      when Dnsruby::RR::IN::URI
        hash.merge!(
          priority: answer.priority,
          target: answer.target,
          weight: answer.weight
        )
      end
      next if hash.keys.count == 1

      hash.merge(ttl: answer.ttl)
    end.compact
  end

  private

  def encode_as_b64(string)
    return unless string

    Base64.encode64(string).strip
  end

  def is_ip?(ip)
    IPAddr.new(ip)
  rescue IPAddr::InvalidAddressError
    false
  end

end
