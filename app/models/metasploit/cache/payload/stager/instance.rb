# Instance-level metadata for stager payload Metasploit Module
class Metasploit::Cache::Payload::Stager::Instance < ActiveRecord::Base
  #
  # Associations
  #

  # The connection handler
  belongs_to :handler,
             class_name: 'Metasploit::Cache::Payload::Handler',
             inverse_of: :payload_stager_instances

  # The class-level metadata for this stager payload Metasploit Module.
  belongs_to :payload_stager_class,
             class_name: 'Metasploit::Cache::Payload::Stager::Class',
             inverse_of: :payload_stager_instance

  #
  # Attributes
  #

  # @!attribute description
  #   The long-form human-readable description of this stager payload Metasploit Module.
  #
  #   @return [String]

  # @!attribute handler_type_alias
  #   Alternate name for the handler_type to prevent naming collisions in staged payload Metasploit Modules that use
  #   this stager payload Metasploit Module.
  #
  #   @return [String]

  # @!attribute name
  #   The human-readable name of this stager payload Metasploit Module.  This can be thought of as the title or summary
  #   of the Metasploit Module.
  #
  #   @return [String]

  # @!attribute payload_stager_class_id
  #   The foreign key for the {#payload_stager_class} association.
  #
  #   @return [Integer]

  # @!attribute privileged
  #   Whether this payload requires privileged access to the remote machine.
  #
  #   @return [true] privileged access is required.
  #   @return [false] privileged access is NOT required.

  #
  # Validations
  #

  validates :description,
            presence: true
  validates :handler,
            presence: true
  validates :name,
            presence: true
  validates :payload_stager_class,
            presence: true
  validates :payload_stager_class_id,
            uniqueness: true

  Metasploit::Concern.run(self)
end