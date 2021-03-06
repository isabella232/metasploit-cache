# Instance-level metadata for an encoder  Metasploit Module.
class Metasploit::Cache::Encoder::Instance < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root

  autoload :EncoderClass
  autoload :Persister

  #
  #
  # Associations
  #
  #

  # Joins {#architectures} to this encoder Metasploit Module.
  has_many :architecturable_architectures,
           as: :architecturable,
           autosave: true,
           class_name: 'Metasploit::Cache::Architecturable::Architecture',
           dependent: :destroy,
           inverse_of: :architecturable

  # Code contributions to this Metasploit Module.
  has_many :contributions,
           as: :contributable,
           autosave: true,
           class_name: 'Metasploit::Cache::Contribution',
           dependent: :destroy,
           inverse_of: :contributable

  # The class-level metadata for this instance metadata.
  #
  # @return [Metasploit::Cache::Encoder::Class]
  belongs_to :encoder_class,
             class_name: 'Metasploit::Cache::Encoder::Class',
             foreign_key: :encoder_class_id,
             inverse_of: :encoder_instance

  # Joins {#licenses} to this encoder Metasploit Module.
  has_many :licensable_licenses,
           as: :licensable,
           autosave: true,
           class_name: 'Metasploit::Cache::Licensable::License',
           dependent: :destroy,
           inverse_of: :licensable

  # Joins {#platforms} to this encoder Metasploit Module.
  has_many :platformable_platforms,
           as: :platformable,
           autosave: true,
           class_name: 'Metasploit::Cache::Platformable::Platform',
           dependent: :destroy,
           inverse_of: :platformable

  #
  # through: :architecturable_architectures
  #

  # Architectures this encoder Metasploit Modules works on.
  has_many :architectures,
           class_name: 'Metasploit::Cache::Architecture',
           through: :architecturable_architectures

  #
  # through: :licensable_licenses
  #

  # The {Metasploit::Cache::License} for the code in this encoder Metasploit Module.
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
  # The long-form human-readable description of this auxiliary Metasploit Module.
  #
  #   @return [String]

  # @!attribute encoder_class_id
  #   The foreign key for {#encoder_class}.
  #
  #   @return [Integer]

  # @!attribute name
  #   The human-readable name of this encoder Metasploit Module.  This can be thought of as the title or summary of
  #   the Metasploit Module.
  #
  #   @return [String]

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

  validates :encoder_class,
            presence: true

  validates :encoder_class_id,
            uniqueness: {
                unless: :batched?
            }

  validates :licensable_licenses,
            length: {
              minimum: 1
            }

  validates :name,
            presence: true
 
  validates :platformable_platforms,
            length: {
              minimum: 1
            }
  
  Metasploit::Concern.run(self)
end