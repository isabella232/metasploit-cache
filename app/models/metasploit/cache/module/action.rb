# Actions that auxiliary modules can perform.  Actions are used to select subcommand-like behavior implemented by the
# same auxiliary module.  The semantics of a given action are specific to a given {Metasploit::Cache::Module::Instance module}: if two
# {Metasploit::Cache::Module::Instance modules} have {Metasploit::Cache::Module::Action actions} with the same {Metasploit::Cache::Module::Action name}, no
# similarity should be assumed between those two {Metasploit::Cache::Module::Action actions} or {Metasploit::Cache::Module::Instance modules}.
class Metasploit::Cache::Module::Action < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  #
  # Associations
  #

  # @!attribute module_instance
  #   Module that has this action.
  #
  #   @return [Metasploit::Cache::Module::Instance]
  belongs_to :module_instance, class_name: 'Metasploit::Cache::Module::Instance', inverse_of: :actions

  #
  # Attributes
  #

  # @!attribute name
  #   The name of this action.
  #
  #   @return [String]

  #
  # Mass Assignment Security
  #

  attr_accessible :name

  #
  # Search Attributes
  #

  search_attribute :name, :type => :string

  #
  # Validations
  #

  validates :module_instance,
            presence: true
  validates :name,
            presence: true,
            uniqueness: {
                scope: :module_instance_id,
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # @!method module_instance=(module_instance)
  #   Sets {#module_instance}.
  #
  #   @param module_instance [Module::Cache::Module::Instance] Module that has this action.
  #   @return [void]

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] Name of this action.
  #   @return [void]

  Metasploit::Concern.run(self)
end