# Represents licenses like BSD, MIT, etc used to provide license information for Metasploit modules
class Metasploit::Cache::License < ActiveRecord::Base
  #
  # Associations
  #

  # Join model between this license and anything that uses this license.
  has_many :licensable_licenses,
           class_name: 'Metasploit::Cache::Licensable::License',
           dependent: :destroy,
           inverse_of: :license

  #
  # Attributes
  #

  # @!attribute abbreviation
  #   Short name of this license, e.g. "BSD-2"
  #
  #   @return [String]

  # @!attribute summary
  #   Summary of the license text
  #
  #   @return [String]

  # @!attribute url
  #   URL of the full license text
  #
  #   @return [String]


  #
  # Validations
  #

  validates :abbreviation,
            uniqueness: true,
            presence: true

  validates :summary,
            uniqueness: true,
            presence: true

  validates :url,
            uniqueness: true,
            presence: true


  # @!method abbreviation=(abbreviation)
  #   Sets {#abbreviation}.
  #
  #   @param abbreviation [String] short name of this license, e.g. "BSD-2"
  #   @return [void]

  # @!method summary=(summary)
  #   Sets {#summary}.
  #
  #   @param summary [String] summary of the license text
  #   @return [void]

  # @!method url=(url)
  #   Sets {#url}.
  #
  #   @param url [String] URL to the location of the full license text
  #   @return [void]


  Metasploit::Concern.run(self)
end
