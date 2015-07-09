# Namespace for modules for synchronizing the persistent cache and in-memory Metasploit Module instances on their
# actions.
module Metasploit::Cache::Actionable::Ephemeral
  extend ActiveSupport::Autoload

  autoload :Actions
end