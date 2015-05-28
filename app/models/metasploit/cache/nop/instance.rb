# Instance-level metadata for a nop Metasploit Module
class Metasploit::Cache::Nop::Instance < ActiveRecord::Base
  #
  #
  # Associations
  #
  #

  # Joins {#architectures} to this nop Metasploit Module.
  has_many :architecturable_architectures,
           class_name: 'Metasploit::Cache::Architecturable::Architecture',
           dependent: :destroy,
           inverse_of: :architecturable

  # Joins {#licenses} to this auxiliary Metasploit Module.
  has_many :licensable_licenses,
           as: :licensable,
           class_name: 'Metasploit::Cache::Licensable::License'

  # The class level metadata for this nop Metasploit Module.
  belongs_to :nop_class,
             class_name: 'Metasploit::Cache::Nop::Class',
             inverse_of: :nop_instance

  # Joins {#platforms} to this encoder Metasploit Module.
  has_many :platformable_platforms,
           class_name: 'Metasploit::Cache::Platformable::Platform',
           dependent: :destroy,
           inverse_of: :platformable

  #
  # through: :architecturable_architectures
  #

  # Architectures on which this Metasploit Module can generate NOPs.
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
  # through: :platformable_platform
  #

  # Platforms this encoder Metasploit Module works on.
  has_many :platforms,
           class_name: 'Metasploit::Cache::Platform',
           through: :platformable_platforms

  #
  # Attributes
  #

  # @!attribute description
  #   The long-form human-readable description of this exploit Metasploit Module.
  #
  #   @return [String]

  # @!attribute name
  #   The human-readable name of this exploit Metasploit Module.  This can be thought of as the title or summary of
  #   the Metasploit Module.
  #
  #   @return [String]

  # @!attribute nop_class_id
  #   The foreign key for the {#nop_class} association.
  #
  #   @return [Integer]

  #
  # Validations
  #

  validates :architecturable_architectures,
            length: {
                minimum: 1
            }
  
  validates :description,
            presence: true

  validates :licensable_licenses,
            length: {
              minimum: 1
            }

  validates :name,
            presence: true

  validates :nop_class,
            presence: true

  validates :nop_class_id,
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
  #   @param description [String] The long-form human-readable description of this encoder Metasploit Module.
  #   @return [void]

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] The human-readable name of this exploit Metasploit Module.  This can be thought of as the
  #     title or summary of the Metasploit Module.
  #   @return [void]

  # @!method nop_class_id=(nop_class_id)
  #   Sets {#nop_class_id} and causes cache of {#nop_class} to be invalidated and reloaded on next access.
  #
  #   @param nop_class_id [Integer]
  #   @return [void]

  Metasploit::Concern.run(self)
end