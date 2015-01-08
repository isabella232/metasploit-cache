# Associates an {Metasploit::Cache::Module::Ancestor} with an {Metasploit::Cache::Module::Class}. Shows that the ruby Class represented by
# {Metasploit::Cache::Module::Class} is descended from one of more {Metasploit::Cache::Module::Ancestor Metasploit::Cache::Module::Ancestors}.
class Metasploit::Cache::Module::Relationship < ActiveRecord::Base
  include Metasploit::Cache::Batch::Descendant

  #
  # Associations
  #

  # @!attribute ancestor
  #   The {Metasploit::Cache::Module::Ancestor} whose {Metasploit::Cache::Module::Ancestor#real_path file} defined the ruby Class or ruby Module.
  #
  #   @return [Metasploit::Cache::Module::Ancestor]
  belongs_to :ancestor, class_name: 'Metasploit::Cache::Module::Ancestor', inverse_of: :relationships

  # @!attribute descendant
  #   The {Metasploit::Cache::Module::Class} that either has the Module in {#ancestor} mixed in or is the Class in {#ancestor}.
  #
  #   @return [Metasploit::Cache::Module::Class]
  belongs_to :descendant, class_name: 'Metasploit::Cache::Module::Class', inverse_of: :relationships

  #
  # Validations
  #

  validates :ancestor,
            presence: true
  validates :ancestor_id,
            uniqueness: {
                scope: :descendant_id,
                unless: :batched?
            }
  validates :descendant,
            presence: true

  Metasploit::Concern.run(self)
end