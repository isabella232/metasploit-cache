# Instance-level metadata for single payload Metasploit Modules
class Metasploit::Cache::Payload::Single::Instance < ActiveRecord::Base
  #
  #
  # Associations
  #
  #

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

  validates :privileged,
            inclusion: {
                in: [
                    false,
                    true
                ]
            }

  Metasploit::Concern.run(self)
end