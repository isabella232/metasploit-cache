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

  Metasploit::Concern.run(self)
end