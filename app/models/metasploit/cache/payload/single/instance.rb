# Instance-level metadata for single payload Metasploit Modules
class Metasploit::Cache::Payload::Single::Instance < ActiveRecord::Base
  #
  #
  # Associations
  #
  #

  # Joins {#architectures} to this single payload Metasploit Module.
  has_many :architecturable_architectures,
           as: :architecturable,
           class_name: 'Metasploit::Cache::Architecturable::Architecture',
           dependent: :destroy,
           inverse_of: :architecturable

  # Code contributions to this single payload Metasploit Module
  has_many :contributions,
           as: :contributable,
           autosave: true,
           class_name: 'Metasploit::Cache::Contribution',
           dependent: :destroy,
           inverse_of: :contributable

  # The connection handler
  belongs_to :handler,
             class_name: 'Metasploit::Cache::Payload::Handler',
             inverse_of: :payload_single_instances

  # Joins {#licenses} to this auxiliary Metasploit Module.
  has_many :licensable_licenses,
           as: :licensable,
           class_name: 'Metasploit::Cache::Licensable::License'

  # The class-level metadata for this single payload Metasploit Module.
  belongs_to :payload_single_class,
             class_name: 'Metasploit::Cache::Payload::Single::Class',
             inverse_of: :payload_single_instance

  # Joins {#platforms} to this single payload Metasploit Module.
  has_many :platformable_platforms,
           as: :platformable,
           class_name: 'Metasploit::Cache::Platformable::Platform',
           dependent: :destroy,
           inverse_of: :platformable

  #
  # through: architecturable_architectures
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
  # through: :platformable_platform
  #

  # Platforms this playload single Metasploit Module works on.
  has_many :platforms,
           class_name: 'Metasploit::Cache::Platform',
           through: :platformable_platforms

  #
  # Attributes
  #

  # @!attribute description
  #   The long-form human-readable description of this single payload Metasploit Module.
  #
  #   @return [String]

  # @!attribute name
  #   The human-readable name of this single payload Metasploit Module.  This can be thought of as the title or summary
  #   of the Metasploit Module.
  #
  #   @return [String]

  # @!attribute payload_single_class_id
  #   The foreign key for the {#payload_single_class} association.
  #
  #   @return [Integer]
  
  # @!attribute privileged
  #   Whether this payload requires privileged access to the remote machine.
  #
  #   @return [true] privileged access is granted.
  #   @return [false] privileged access is NOT granted.


  #
  # Validations
  #

  validates :architecturable_architectures,
            length: {
                minimum: 1
            }
 
  validates :contributions,
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

  validates :payload_single_class,
            presence: true

  validates :payload_single_class_id,
            uniqueness: true
  
  validates :platformable_platforms,
            length: {
                minimum: 1
            }

  validates :privileged,
            inclusion: {
                in: [
                    false,
                    true
                ]
            }

  Metasploit::Concern.run(self)
end