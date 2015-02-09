# Microsoft Security Bulletin authority-specific code.
module Metasploit::Cache::Authority::Msb
  # Returns URL to {Metasploit::Cache::Reference#designation the security bulletin's} page on Technet.
  #
  # @param designation [String] MSYY-NNN Security Bulletin ID.
  # @return [String] URL
  def self.designation_url(designation)
    "http://www.microsoft.com/technet/security/bulletin/#{designation}"
  end
end
