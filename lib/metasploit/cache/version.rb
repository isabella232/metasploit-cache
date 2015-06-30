module Metasploit
  module Cache
    # Holds components of {VERSION} as defined by {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0}.
    module Version
      #
      # CONSTANTS
      #

      # The major version number.
      MAJOR = 0
      # The minor version number, scoped to the {MAJOR} version number.
      MINOR = 65
      # The patch version number, scoped to the {MAJOR} and {MINOR} version numbers.
      PATCH = 1

      #
      # Module Methods
      #

      # The full version string, including the {Metasploit::Cache::Version::MAJOR},
      # {Metasploit::Cache::Version::MINOR}, {Metasploit::Cache::Version::PATCH}, and optionally, the
      # `Metasploit::Cache::Version::PRERELEASE` in the
      # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
      #
      # @return [String] '{Metasploit::Cache::Version::MAJOR}.{Metasploit::Cache::Version::MINOR}.{Metasploit::Cache::Version::PATCH}' on master.
      #   '{Metasploit::Cache::Version::MAJOR}.{Metasploit::Cache::Version::MINOR}.{Metasploit::Cache::Version::PATCH}-PRERELEASE'
      #   on any branch other than master.
      def self.full
        version = "#{MAJOR}.#{MINOR}.#{PATCH}"

        # :nocov:
        if defined? PRERELEASE
          version = "#{version}-#{PRERELEASE}"
        end
        # :nocov:

        version
      end

      # The full gem version string, including the {Metasploit::Cache::Version::MAJOR},
      # {Metasploit::Cache::Version::MINOR}, {Metasploit::Cache::Version::PATCH}, and optionally, the
      # `Metasploit::Cache::Version::PRERELEASE` in the
      # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
      #
      # @return [String] '{Metasploit::Cache::Version::MAJOR}.{Metasploit::Cache::Version::MINOR}.{Metasploit::Cache::Version::PATCH}'
      #   on master.  '{Metasploit::Cache::Version::MAJOR}.{Metasploit::Cache::Version::MINOR}.{Metasploit::Cache::Version::PATCH}.PRERELEASE'
      #   on any branch other than master.
      def self.gem
        full.gsub('-', '.pre.')
      end
    end

    # (see Version.gem)
    GEM_VERSION = Version.gem

    # (see Version.full)
    VERSION = Version.full
  end
end
