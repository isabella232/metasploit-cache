# The reliability of the module and likelyhood that the module won't knock over the service or host being exploited.
# Bigger {#number values} are better.
class Metasploit::Cache::Module::Rank < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  autoload :Seed

  #
  # CONSTANTS
  #

  # Regular expression to ensure that {#name} is a word starting with a capital letter
  NAME_REGEXP = /\A[A-Z][a-z]+\Z/

  # Converts {#name} to {#number}.  Used for seeding.  Seeds exist so that reports can use module_ranks to get the
  # name of a rank without having to duplicate this constant.
  NUMBER_BY_NAME = {
      'Manual' => 0,
      'Low' => 100,
      'Average' => 200,
      'Normal' => 300,
      'Good' => 400,
      'Great' => 500,
      'Excellent' => 600
  }
  # Converts {#number} to {#name}.  Used to convert *Ranking constants used in `Msf::Modules` back to Strings.
  NAME_BY_NUMBER = NUMBER_BY_NAME.invert

  #
  # Associations
  #

  # {Metasploit::Cache::Auxiliary::Class Auxiliary classes} assigned this rank.
  has_many :auxiliary_classes,
           class_name: 'Metasploit::Cache::Auxiliary::Class',
           dependent: :destroy,
           inverse_of: :rank

  # {Metasploit::Cache::Encoder::Class Encoder classes} assigned this rank.
  has_many :encoder_classes,
           class_name: 'Metasploit::Cache::Encoder::Class',
           dependent: :destroy,
           inverse_of: :rank

  # {Metasploit::Cache::Exploit::Class Exploit classes} assigned this rank.
  has_many :exploit_classes,
           class_name: 'Metasploit::Cache::Exploit::Class',
           dependent: :destroy,
           inverse_of: :rank

  # {Metasploit::Cache::Nop::Class Nop classes} assigned this rank.
  has_many :nop_classes,
           class_name: 'Metasploit::Cache::Nop::Class',
           dependent: :destroy,
           inverse_of: :rank

  # {Metasploit::Cache::Post::Class Post classes} assigned this rank.
  has_many :post_classes,
           class_name: 'Metasploit::Cache::Post::Class',
           dependent: :destroy,
           inverse_of: :rank

  # {Metasploit::Cache::Payload::Single::Unhandled::Class Single payload classes} assigned this rank.
  has_many :payload_single_unhandled_classes,
           class_name: 'Metasploit::Cache::Payload::Single::Unhandled::Class',
           dependent: :destroy,
           inverse_of: :rank

  # {Metasploit::Cache::Payload::Stage::Class Stage payload classes} assigned this rank.
  has_many :stage_payload_classes,
           class_name: 'Metasploit::Cache::Payload::Stage::Class',
           dependent: :destroy,
           inverse_of: :rank

  # {Metasploit::Cache::Payload::Stager::Class Stager payload classes} assigned this rank.
  has_many :stager_payload_classes,
           class_name: 'Metasploit::Cache::Payload::Stager::Class',
           dependent: :destroy,
           inverse_of: :rank

  #
  # Attributes
  #

  # @!attribute name
  #   The name of the rank.
  #
  #   @return [String]

  # @!attribute number
  #   The numerical value of the rank.  Higher numbers are better.
  #
  #   @return [Integer]

  #
  # Search Attributes
  #

  search_attribute :name, type: :string
  search_attribute :number, type: :integer

  #
  # Validations
  #

  validates :name,
            # To ensure NUMBER_BY_NAME and seeds stay in sync.
            inclusion: {
                in: NUMBER_BY_NAME.keys
            },
            # To ensure new seeds follow pattern.
            format: {
                with: NAME_REGEXP
            },
            uniqueness: true
  validates :number,
            # to ensure NUMBER_BY_NAME and seeds stay in sync.
            inclusion: {
                in: NUMBER_BY_NAME.values
            },
            # To ensure new seeds follow pattern.
            numericality: {
                only_integer: true
            },
            uniqueness: true

  Metasploit::Concern.run(self)
end