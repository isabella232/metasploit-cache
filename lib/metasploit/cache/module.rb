# Namespace for all models dealing with module caching.
#
# Metasploit module metadata is split between 3 classes:
#
# 1. {Metasploit::Cache::Module::Ancestor} which represents the ruby Module (in the case of payloads) or ruby Class (in the case
#    of non-paylods) loaded by Msf::Modules::Loader::Base#load_modules and so has file related metadata.
# 2. {Metasploit::Cache::Module::Class} which represents the Class<Msf::Module> derived from one or more
#    {Metasploit::Cache::Module::Ancestor ancestors}. {Metasploit::Cache::Module::Class} can have a different reference name in the case of
#    payloads.
# 3. {Metasploit::Cache::Module::Instance} which represents the instance of Msf::Module created from a {Metasploit::Cache::Module::Class}.  Metadata
#    that is only available after running #initialize is stored in this model.
#
# # Translation from metasploit_data_models <= 0.16.5
#
# If you're trying to convert your SQL queries from metasploit_data_models <= 0.16.5 and the Metasploit::Cache::Module::Details cache
# to the new Metasploit::Cache::Module::Instance cache available in metasploit_data_models >= 0.17.2, then see this
# {file:docs/mdm_module_sql_translation.md guide}.
module Metasploit::Cache::Module
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :AncestorCell
  autoload :Descendant
  autoload :Class
  autoload :Handler
  autoload :Instance
  autoload :Namespace
  autoload :Path
  autoload :Persister
  autoload :Rank
  autoload :Rankable
  autoload :Stance
  autoload :Type

  #
  # Module Methods
  #

  def self.table_name_prefix
    "#{parent.table_name_prefix}module_"
  end
end
