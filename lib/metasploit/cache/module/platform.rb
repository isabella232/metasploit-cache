# Joins {Metasploit::Cache::Module::Instance} and {Metasploit::Cache::Platform.}
module Metasploit::Cache::Module::Platform
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::Validations

    #
    # Validations
    #

    validates :module_instance, :presence => true
    validates :platform, :presence => true
  end

  #
  # Associations
  #

  # @!attribute [rw] module_instance
  #   Module that supports {#platform}.
  #
  #   @return [Metasploit::Cache::Module::Instance]

  # @!attribute [rw] platform
  #  Platform supported by {#module_instance}.
  #
  #  @return [Metasploit::Cache::Platform]
end
