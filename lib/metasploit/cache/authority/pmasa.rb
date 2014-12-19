# phpMyAdmin Security Announcement authority-specific code.
module Metasploit::Cache::Authority::Pmasa
  # Returns URL to {Metasploit::Cache::Reference#designation phpMyAdmin Security Advisory's} page on phpMyAdmin's site.
  #
  # @param designation [String] YYYY-N phpMyAdmin Security Advisory ID.
  # @return [String] URL
  def self.designation_url(designation)
    "http://www.phpmyadmin.net/home_page/security/PMASA-#{designation}.php"
  end
end
