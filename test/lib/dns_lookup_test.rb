require 'test_helper'

class DNSLookupTest < ActiveSupport::TestCase

  def test_noerror
    assert_equal 'NOERROR', dns_lookup.run('d53.co', 'A')[:status]
  end

  def test_servfail
    assert_equal(
      'SERVFAIL', dns_lookup.run('servfail.testing.d53.co', 'NS')[:status]
    )
  end

  def test_timeout
    assert_equal(
      'TIMEOUT', dns_lookup.run('timeout.testing.d53.co', 'NS')[:status]
    )
  end

  def test_not_implemented
    assert_equal('NOT IMPLEMENTED', dns_lookup.run('d53.co', 'ANY')[:status])
  end

  def test_a
    assert_equal(
      [{ type: 'A', address: '0.0.0.0' }],
      get_answer('a.testing.d53.co', 'A')
    )
  end

  def test_aaaa
    assert_equal(
      [{ type: 'AAAA', address: '4149:8F20:F382:F7B2:45:1A0:A38F:34D9' }],
      get_answer('aaaa.testing.d53.co', 'AAAA')
    )
  end

  def test_caa
    assert_equal(
      [{ type: 'CAA', flag: 0, property_tag: 'issue', property_value: 'd53.co' }],
      get_answer('caa.testing.d53.co', 'CAA')
    )
  end

  def test_cert
    assert_equal(
      [
        {
          type: 'CERT', algorithm: 'RSASHA256', cert: 'this-is-a-test-cert',
          certtype: 'PKIX', keytag: 1
        }
      ],
      get_answer('cert.testing.d53.co', 'CERT')
    )
  end

  def test_cname
    assert_equal(
      [{ type: 'CNAME', name: 'cnamev.testing.d53.co' }],
      get_answer('cname.testing.d53.co', 'CNAME')
    )
  end

  def test_dnskey
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
      get_answer('cloudflare.com', 'DNSKEY')
    )
  end

  def test_ds
    assert_equal(
      [
        {
          type: 'DS', algorithm: 'ECDSAP256SHA256',
          digest: '32996839a6d808afe3eb4a795a0e6a7a39a76fc52ff228b22b76f6d63826f2b9',
          digest_type: 'SHA-256', key_tag: 2371
        }
      ],
      get_answer('cloudflare.com', 'DS')
    )
  end

  def test_hinfo
    assert_equal(
      [{ type: 'HINFO', data: 'RFC8482' }],
      remove_ttl(DNSLookup.new('8.8.8.8').run('cloudflare.com', 'ANY')[:answer])
    )
  end

  def test_mx
    assert_equal(
      [{ type: 'MX', exchange: 'mxv.testing.d53.co', preference: 0 }],
      get_answer('mx.testing.d53.co', 'MX')
    )
  end

  def test_ns
    assert_equal(
      [
        { type: 'NS', name: 'eva.ns.cloudflare.com' },
        { type: 'NS', name: 'sid.ns.cloudflare.com' }
      ],
      get_answer('d53.co', 'NS')
    )
  end

  def test_ptr_domain
    assert_equal(
      [{ type: 'PTR', name: 'ptrv.testing.d53.co' }],
      get_answer('ptr.testing.d53.co', 'PTR')
    )
  end

  def test_ptr_ip
    assert_equal(
      [{ type: 'PTR', name: 'dns.google' }],
      get_answer('8.8.4.4', 'PTR')
    )
  end

  def test_soa
    assert_equal(
      [
        {
          type: 'SOA', expire: 604800, minimum: 1800,
          mname: 'eva.ns.cloudflare.com', refresh: 10000, retry: 2400,
          rname: 'dns.cloudflare.com', serial: 2333549498
        }
      ],
      get_answer('d53.co', 'SOA')
    )
  end

  def test_txt
    assert_equal(
      [{ type: 'TXT', strings: ['test-text'] }],
      get_answer('txt.testing.d53.co', 'TXT')
    )
  end

  def test_uri
    assert_equal(
      [{ type: 'URI', priority: 0, target: 'uriv.testing.d53.co', weight: 0 }],
      get_answer('uri.testing.d53.co', 'URI')
    )
  end

  private

  def dns_lookup
    @dns_lookup ||= DNSLookup.new('1.1.1.1')
  end

  def get_answer(domain, type)
    remove_ttl(dns_lookup.run(domain, type)[:answer])
  end

  def remove_ttl(fields)
    fields.map { |answer| answer.except(:ttl) }
  end

end
