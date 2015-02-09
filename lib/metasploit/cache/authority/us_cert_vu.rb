# United States Computer Emergency Readiness Team Vulnerability Notes Database authority-specific code.
module Metasploit::Cache::Authority::UsCertVu
  # Returns URL to {Metasploit::Cache::Reference#designation Vul ID's} page on US CERT Notes Database.
  #
  # @param designation [String] N US CERT ID.
  # @return [String] URL
  def self.designation_url(designation)
    "http://www.kb.cert.org/vuls/id/#{designation}"
  end
end
