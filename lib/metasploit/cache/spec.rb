# Helper methods for running specs for metasploit-cache.
module Metasploit::Cache::Spec
  extend ActiveSupport::Autoload

  autoload :Matcher
  autoload :Template
  autoload :Unload
end
