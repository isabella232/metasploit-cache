# Instance-level metadata for stager payload Metasploit Module
class Metasploit::Cache::Payload::Stager::Instance < ActiveRecord::Base
  #
  # Associations
  #

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
  #   The foreign key for the {#payloadr_stage_class} association.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :description,
            presence: true
  validates :name,
            presence: true
  validates :payload_stager_class,
            presence: true
  validates :payload_stager_class_id,
            uniqueness: true

  #
  # Instance Methods
  #

  # @!method description=(description)
  #   Sets {#description}.
  #
  #   @param description [String] The long-form human-readable description of this stager payload Metasploit Module.
  #   @return [void]

  # @!attribute handler_type_alias=(handler_type_alias)
  #   Sets {#handler_type_alias}.
  #
  #   @param handler_type_alias [String, nil] Alternate name for the handler_type to prevent naming collisions in staged
  #     payload Metasploit Modules that use this stager payload Metasploit Module.
  #   @return [void]

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] The human-readable name of this stager payload Metasploit Module.  This can be thought of as
  #     the title or summary of the Metasploit Module.
  #   @return [void]

  # @!method payload_stager_class_id=(payload_stager_class_id)
  #   Sets {#payload_stager_class_id} and causes cache of {#payload_stager_class} to be invalidated and reloaded on next
  #   access.
  #
  #   @param payload_stager_class_id [Integer]
  #   @return [void]

  Metasploit::Concern.run(self)
end