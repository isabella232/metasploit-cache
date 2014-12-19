# Model that joins {Metasploit::Cache::Architecture} and {Metasploit::Cache::Module::Target}.
module Metasploit::Cache::Module::Target::Architecture
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::Validations

    #
    # Validations
    #

    validates :architecture,
              presence: true
    validates :module_target,
              presence: true
  end

  #
  # Associations
  #

  # @!attribute [rw] architecture
  #   The architecture supported by the {#module_target}.
  #
  #   @return [Metasploit::Cache::Architecture]

  # @!attribute [rw] module_target
  #   The module target that supports {#architecture}.
  #
  #   @return [Metasploit::Cache::Module::Target]
end
