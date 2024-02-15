class DNSLookup

  attr_reader :duration

  def initialize(domain, type, server)
    @domain = domain
    @type = type.to_s.upcase
    @server = server

    if @type == 'PTR'
      @domain = "#{@domain.split('.').reverse.join('.')}.in-addr.arpa"
    end
  end

  def run
    start_time = Time.monotonic_now
    results = Resolv::DNS.open(nameserver: @server) do |r|
      r.timeouts = 5
      r.getresources(@domain, "Resolv::DNS::Resource::IN::#{@type}".constantize)
    end
    @duration = (Time.monotonic_now - start_time) * 1000

    format_results(results)
  end

  private

  def format_results(results)
    results.map do |result|
      case result
      when Resolv::DNS::Resource::IN::A
        { address: result.address.to_s, ttl: result.ttl }
      when Resolv::DNS::Resource::IN::AAAA
        { address: result.address.to_s, ttl: result.ttl }
      when Resolv::DNS::Resource::IN::MX
        {
          exchange: result.exchange.to_s, preference: result.preference,
          ttl: result.ttl
        }
      when Resolv::DNS::Resource::IN::NS
        { name: result.name.to_s, ttl: result.ttl }
      when Resolv::DNS::Resource::IN::TXT
        { strings: result.strings, ttl: result.ttl }
      when Resolv::DNS::Resource::IN::SOA
        {
          expire: result.expire,
          minimum: result.minimum,
          mname: result.mname.to_s,
          refresh: result.refresh,
          retry: result.retry,
          rname: result.rname.to_s,
          serial: result.serial.to_s,
          ttl: result.ttl
        }
      when Resolv::DNS::Resource::IN::CAA
        {
          flags: result.flags.to_i, tag: result.tag.to_s,
          value: result.value.to_s, ttl: result.ttl
        }
      when Resolv::DNS::Resource::IN::PTR
        { name: result.name.to_s, ttl: result.ttl }
      end
    end.compact
  end

end
