# Instance-level metadata for stager payload Metasploit Module
class Metasploit::Cache::Payload::Stager::Instance < ActiveRecord::Base
  #
  #
  # Associations
  #
  #

  # Joins {#architectures} to this stager payload Metasploit Module.
  has_many :architecturable_architectures,
           class_name: 'Metasploit::Cache::Architecturable::Architecture',
           dependent: :destroy,
           inverse_of: :architecturable

  # The connection handler
  belongs_to :handler,
             class_name: 'Metasploit::Cache::Payload::Handler',
             inverse_of: :payload_stager_instances

  # Joins {#licenses} to this auxiliary Metasploit Module.
  has_many :licensable_licenses,
           as: :licensable,
           class_name: 'Metasploit::Cache::Licensable::License'

  # Staged payload Metasploit Module formed by combining this stager payload Metasploit Module with a compatible stage
  # payload Metasploit Module.
  has_many :payload_staged_classes,
           class_name: 'Metasploit::Cache::Payload::Staged::Class',
           dependent: :destroy,
           inverse_of: :payload_stager_instance

  # The class-level metadata for this stager payload Metasploit Module.
  belongs_to :payload_stager_class,
             class_name: 'Metasploit::Cache::Payload::Stager::Class',
             inverse_of: :payload_stager_instance

  # Joins {#platforms} to this stager payload Metasploit Module.
  has_many :platformable_platforms,
           class_name: 'Metasploit::Cache::Platformable::Platform',
           dependent: :destroy,
           inverse_of: :platformable

  #
  # through: :platformable_platform
  #

  # Platforms this payload stager Metasploit Module works on.
  has_many :platforms,
           class_name: 'Metasploit::Cache::Platform',
           through: :platformable_platforms

  #
  # through: :architecturable_architectures
  #

  # Architectures on which this payload can run.
  has_many :architectures,
           class_name: 'Metasploit::Cache::Architecture',
           through: :architecturable_architectures

  #
  # through: :licensable_licenses
  #

  # The {Metasploit::Cache::License} for the code in this auxiliary Metasploit Module.
  has_many :licenses,
           class_name: 'Metasploit::Cache::License',
           through: :licensable_licenses

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

  validates :architecturable_architectures,
            length: {
                minimum: 1
            }
  validates :description,
            presence: true

  validates :handler,
            presence: true

  validates :licensable_licenses,
            length: {
              minimum: 1
            }
  validates :name,
            presence: true

  validates :payload_stager_class,
            presence: true

  validates :payload_stager_class_id,
            uniqueness: true
  validates :platformable_platforms,
            length: {
                minimum: 1
            }
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

  # @!method privileged=(privileged)
  #   Sets {#privileged}.
  #
  #   @param priviliged [Boolean] `true` if privileged access is required; `false` if privileged access is not required.
  #   @return [void]

  Metasploit::Concern.run(self)
end