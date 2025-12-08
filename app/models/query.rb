# == Schema Information
#
# Table name: queries
#
#  id            :uuid             not null, primary key
#  dnssec_failed :boolean
#  domain        :string
#  duration      :integer
#  results       :json             not null
#  server        :string
#  server_ip     :string
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  session_id    :string
#
class Query < ApplicationRecord
  self.inheritance_column = nil

  SERVERS = {
    'Cloudflare': '1.1.1.1',
    'Google': '8.8.8.8',
    'Quad9': '9.9.9.9',
    'OpenDNS': '208.67.222.222',
    'Comodo': '8.26.56.26',
    'CleanBrowsing': '185.228.168.9',
    'Neustar': '156.154.70.5',
    'AdGuard': '94.140.14.140',
    'Dyn': '216.146.35.35',
  }.freeze
  TYPES = %w[A AAAA ANY CAA CERT CNAME DNSKEY DS MX NS PTR SOA TXT URI].freeze

  validates_presence_of :domain, :server, :type

  def domain=(value)
    return unless value.present?

    cleaned_value = value.
      gsub(/(^\w+:|^)\/\//, ''). # remove protocols
      gsub(/\/(?:[^\/]|\/(?!$))*$/, ''). # remove path
      gsub(/\.$/, ''). # remove trailing period
      delete(' '). # remove any spaces
      downcase

    super(cleaned_value)
  end
  alias_method :domain_name=, :domain=

  def server=(value)
    server_hash = SERVERS.find { |name, ip| name.to_s.casecmp?(value) }
    return unless server_hash

    super(server_hash.first)
    self.server_ip = server_hash.last
  end

  def type=(value)
    cleaned_value = value.upcase
    return unless TYPES.include?(cleaned_value)

    super(cleaned_value)
  end

  def duration_ms
    "#{(duration || 0).to_fs(:delimited)} ms"
  end

  def do_dns_lookup!
    dns_lookup = DNSLookup.new(server_ip)
    self.results = dns_lookup.run(domain, type)
    self.duration = dns_lookup.duration
    self.dnssec_failed = dns_lookup.dnssec_failed
    self
  end

  def redirect_params
    { domain_name: domain, type: type.downcase, server: server.downcase }
  end
end
