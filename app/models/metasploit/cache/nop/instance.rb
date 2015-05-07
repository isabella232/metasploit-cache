# Instance-level metadata for a nop Metasploit Module
class Metasploit::Cache::Nop::Instance < ActiveRecord::Base
  #
  # Associations
  #

  # The class level metadata for this nop Metasploit Module.
  belongs_to :nop_class,
             class_name: 'Metasploit::Cache::Nop::Class',
             inverse_of: :nop_instance

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

  validates :description,
            presence: true
  validates :name,
            presence: true
  validates :nop_class,
            presence: true
  validates :nop_class_id,
            uniqueness: true

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