require 'test_helper'

class DNSLookupTest < ActiveSupport::TestCase
  def test_noerror
    response = dns_lookup.run('d53.co', 'A')
    assert_equal(
      { status: 'NOERROR', from: '1.1.1.1' }, response[:json].except(:answer)
    )
    assert_match 'NOERROR', response[:zone]
  end

  def test_servfail
    response = dns_lookup.run('servfail.testing.d53.co', 'NS')
    assert_equal({ status: 'SERVFAIL', from: '1.1.1.1' }, response[:json])
    assert_match 'SERVFAIL', response[:zone]
  end

  def test_timeout
    response = DNSLookup.new('1.2.3.4').run('timeout.testing.d53.co', 'NS')
    assert_equal({ status: 'TIMEOUT', from: '1.2.3.4' }, response[:json])
    assert_nil response[:zone]
  end

  def test_not_implemented
    response = dns_lookup.run('d53.co', 'ANY')
    assert_equal({ status: 'NOTIMP', from: '1.1.1.1' }, response[:json])
    assert_match 'NOTIMP', response[:zone]
  end

  def test_a
    response = get_answer('a.testing.d53.co', 'A')
    assert_equal([{ type: 'A', address: '0.0.0.0' }], response[:json])
    assert_match "a.testing.d53.co.\tIN\tA", response[:zone]
  end

  def test_aaaa
    response = get_answer('aaaa.testing.d53.co', 'AAAA')
    assert_equal(
      [{ type: 'AAAA', address: '4149:8F20:F382:F7B2:45:1A0:A38F:34D9' }],
      response[:json]
    )
    assert_match "aaaa.testing.d53.co.\tIN\tAAAA", response[:zone]
  end

  def test_caa
    response = get_answer('caa.testing.d53.co', 'CAA')
    assert_equal(
      [{ type: 'CAA', flag: 0, property_tag: 'issue', property_value: 'd53.co' }],
      response[:json]
    )
    assert_match "caa.testing.d53.co.\tIN\tCAA", response[:zone]
  end

  def test_cert
    response = get_answer('cert.testing.d53.co', 'CERT')
    assert_equal(
      [
        {
          type: 'CERT', algorithm: 'RSASHA256', cert: 'this-is-a-test-cert',
          certtype: 'PKIX', keytag: 1
        }
      ],
      response[:json]
    )
    assert_match "cert.testing.d53.co.\tIN\tCERT", response[:zone]
  end

  def test_cname
    response = get_answer('cname.testing.d53.co', 'CNAME')
    assert_equal(
      [{ type: 'CNAME', name: 'cnamev.testing.d53.co' }],
      response[:json]
    )
    assert_match "cname.testing.d53.co.\tIN\tCNAME", response[:zone]
  end

  def test_dnskey
    response = get_answer('cloudflare.com', 'DNSKEY')
    assert_equal(
      [
        {
          type: 'DNSKEY', algorithm: 'ECDSAP256SHA256', flags: 256,
          key: "oJMRESz5E4gYzS/q6XDrvU1qMPYIjCWzJaOau8XNEZeqCYKD5ar0IRd8KqXX\nFJkqmVfRvMGPmM1x8fGAa2XhSA==",
          key_tag: 34505, protocol: 3
        },
        {
          type: 'DNSKEY', algorithm: 'ECDSAP256SHA256', flags: 257,
          key: "mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxL\nbxILfDLUT0rAK9iUzy1L53eKGQ==",
          key_tag: 2371, protocol: 3
        }
      ],
      response[:json]
    )
    assert_match "cloudflare.com.\tIN\tDNSKEY", response[:zone]
  end

  def test_ds
    response = get_answer('cloudflare.com', 'DS')
    assert_equal(
      [
        {
          type: 'DS', algorithm: 'ECDSAP256SHA256',
          digest: '32996839a6d808afe3eb4a795a0e6a7a39a76fc52ff228b22b76f6d63826f2b9',
          digest_type: 'SHA-256', key_tag: 2371
        }
      ],
      response[:json]
    )
    assert_match "cloudflare.com.\tIN\tDS", response[:zone]
  end

  def test_hinfo
    response = DNSLookup.new('8.8.8.8').run('cloudflare.com', 'ANY')
    assert_equal(
      [{ type: 'HINFO', data: 'RFC8482' }],
      remove_dynamic(response.dig(:json, :answer))
    )
    assert_match "cloudflare.com.\tIN\tANY", response[:zone]
  end

  def test_mx
    response = get_answer('mx.testing.d53.co', 'MX')
    assert_equal(
      [{ type: 'MX', exchange: 'mxv.testing.d53.co', preference: 0 }],
      response[:json]
    )
    assert_match "mx.testing.d53.co.\tIN\tMX", response[:zone]
  end

  def test_ns
    response = get_answer('d53.co', 'NS')
    assert_equal(
      [
        { type: 'NS', name: 'eva.ns.cloudflare.com' },
        { type: 'NS', name: 'sid.ns.cloudflare.com' }
      ],
      response[:json]
    )
    assert_match "d53.co.\tIN\tNS", response[:zone]
  end

  def test_ptr_domain
    response = get_answer('ptr.testing.d53.co', 'PTR')
    assert_equal(
      [{ type: 'PTR', name: 'ptrv.testing.d53.co' }],
      response[:json]
    )
    assert_match "ptr.testing.d53.co.\tIN\tPTR", response[:zone]
  end

  def test_ptr_ip
    response = get_answer('8.8.4.4', 'PTR')
    assert_equal([{ type: 'PTR', name: 'dns.google' }], response[:json])
    assert_match "4.4.8.8.in-addr.arpa.\tIN\tPTR", response[:zone]
  end

  def test_soa
    response = get_answer('d53.co', 'SOA')
    assert_equal(
      [
        {
          type: 'SOA', expire: 604800, minimum: 1800,
          mname: 'eva.ns.cloudflare.com', refresh: 10000, retry: 2400,
          rname: 'dns.cloudflare.com'
        }
      ],
      response[:json]
    )
    assert_match "d53.co.\tIN\tSOA", response[:zone]
  end

  def test_txt
    response = get_answer('txt.testing.d53.co', 'TXT')
    assert_equal([{ type: 'TXT', strings: ['test-text'] }], response[:json])
    assert_match "txt.testing.d53.co.\tIN\tTXT", response[:zone]
  end

  def test_uri
    response = get_answer('uri.testing.d53.co', 'URI')
    assert_equal(
      [{ type: 'URI', priority: 0, target: 'uriv.testing.d53.co', weight: 0 }],
      response[:json]
    )
    assert_match "uri.testing.d53.co.\tIN\tURI", response[:zone]
  end

  private

  def dns_lookup
    @dns_lookup ||= DNSLookup.new('1.1.1.1')
  end

  def get_answer(domain, type)
    response = dns_lookup.run(domain, type)
    { json: remove_dynamic(response.dig(:json, :answer)), zone: response[:zone] }
  end

  def remove_dynamic(fields)
    fields.map { |answer| answer.except(:ttl, :serial) }
  end
end
