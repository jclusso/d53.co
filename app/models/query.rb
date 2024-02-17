# == Schema Information
#
# Table name: queries
#
#  id         :uuid             not null, primary key
#  domain     :string
#  duration   :integer
#  results    :json             not null
#  server     :string
#  server_ip  :string
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  session_id :string
#
class Query < ApplicationRecord
  self.inheritance_column = nil

  def self.servers
    {
      'Cloudflare': '1.1.1.1',
      'Google': '8.8.8.8',
      'Quad9': '9.9.9.9',
      'OpenDNS': '208.67.222.222',
      'DNS.Watch': '84.200.69.80',
      'Comodo': '8.26.56.26',
      'OpenNIC': '162.243.19.47',
      'Yandex': '77.88.8.88',
      'CleanBrowsing': '185.228.168.9',
      'FreeDNS': '45.33.97.5',
      'CyberGhost': '38.132.106.139',
      'Neustar': '156.154.70.5',
      'AdGuard': '94.140.14.140',
      'Dyn': '216.146.35.35',
      'GCore': '95.85.95.85',
      'Level3': '4.2.2.1'
    }
  end

  def self.types
    %w[A AAAA ANY CAA CERT CNAME DNSKEY DS MX NS PTR SOA TXT URI]
  end

  validates_presence_of :domain, :server, :type

  def server=(value)
    ip = self.class.servers[value.to_sym]
    return unless ip

    super(value)
    self.server_ip = ip
  end

  def type=(value)
    return unless self.class.types.include?(value)

    super(value)
  end

  def duration_ms
    "#{(duration || 0).to_fs(:delimited)} ms"
  end

end
