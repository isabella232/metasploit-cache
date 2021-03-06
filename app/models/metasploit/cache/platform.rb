# {Metasploit::Cache::Module::Instance#platforms Platforms} for {Metasploit::Cache::Module::Instance modules}.
class Metasploit::Cache::Platform < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Derivation
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  autoload :Seed

  #
  # Acts
  #

  acts_as_nested_set dependent: :destroy,
                     left_column: :left,
                     right_column: :right,
                     order: :fully_qualified_name

  #
  #
  # Associations
  #
  #

  # Joins this {Metasploit::Cache::Platform} to {Metasploit::Cache::Module::Instance modules} that support the platform.
  has_many :module_platforms, class_name: 'Metasploit::Cache::Module::Platform', dependent: :destroy, inverse_of: :platform

  # Joins this {Metasploit::cache::Platform} to Metasploit::Cache::Encoder::Instance encoder},
  # {Metasploit::Cache::Nop::Instance nop}, {Metasploit::Cache::Payload::Single::Unhandled::Instance single payload},
  # {Metasploit::Cache::Payload::Stage::Instance stage payload},
  # {Metasploit::Cache::Payload::Stager::Instance stager payload}, or {Metasploit::Cache::Post::Instance post}) Metasploit
  # Modules or {Metasploit::Cache::Exploit::Target exploit Metasploit Module targets}.
  has_many :platformable_platforms,
           as: :platformable,
           class_name: 'Metasploit::Cache::Platformable::Platform',
           dependent: :destroy,
           inverse_of: :platform

  # Joins this to {Metasploit::Cache::Module::Target targets} that support this platform.
  has_many :target_platforms, class_name: 'Metasploit::Cache::Module::Target::Platform', dependent: :destroy, inverse_of: :platform

  #
  # through: :module_platforms
  #

  # {Metasploit::Cache::Module::Instance Modules} that has this {Metasploit::Cache::Platform} as one of their supported
  # {Metasploit::Cache::Module::Instance#platforms platforms}.
  has_many :module_instances, class_name: 'Metasploit::Cache::Module::Instance', through: :module_platforms

  #
  # through: :platformable_platforms
  #

  # Encoder Metasploit Modules that can encode for this platform.
  has_many :encoder_instances,
           class_name: 'Metasploit::Cache::Encoder::Instance',
           source: :platformable,
           source_type: 'Metasploit::Cache::Encoder::Instance',
           through: :platformable_platforms

  # Exploit Metasploit Module targets that can target this platform.
  has_many :exploit_targets,
           source: :platformable,
           source_type: 'Metasploit::Cache::Exploit::Target',
           through: :platformable_platforms

  # Nop Metasploit Modules that can produce nops for this platform.
  has_many :nop_instances,
           source: :platformable,
           source_type: 'Metasploit::Cache::Nop::Instance',
           through: :platformable_platforms

  # Single payload Metasploit Modules that can run on this platform.
  has_many :payload_single_unhandled_instances,
           source: :platformable,
           source_type: 'Metasploit::Cache::Payload::Single::Unhandled::Instance',
           through: :platformable_platforms

  # Stage payload Metasploit Modules that can run on this platform.
  has_many :payload_stage_instances,
           source: :platformable,
           source_type: 'Metasploit::Cache::Payload::Stage::Instance',
           through: :platformable_platforms

  # Stager payload Metasploit Modules that can run on this platform.
  has_many :payload_stager_instances,
           source: :platformable,
           source_type: 'Metasploit::Cache::Payload::Stager::Instance',
           through: :platformable_platforms

  #
  # Attributes
  #

  # @!attribute fully_qualified_name
  #   The fully qualified name of this platform, as would be used in the platform list in a metasploit-framework
  #   module.
  #
  #   @return [String]

  # @!attribute parent
  #   The parent platform of this platform.  For example, Windows is parent of Windows 98, which is the parent of
  #   Windows 98 FE.
  #
  #   @return [nil] if this is a top-level platform, such as Windows or Linux.
  #   @return [Metasploit::Cache::Platform]

  # @!attribute relative_name
  #   The name of this platform relative to the {#fully_qualified_name} of {#parent}.
  #
  #   @return [String]

  #
  # Derivations
  #

  derives :fully_qualified_name, validate: true

  #
  # Search
  #

  search_attribute :fully_qualified_name,
                   type: {
                       set: :string
                   }
  #
  # Validation
  #

  validates :fully_qualified_name,
            inclusion: {
                in: ->(record){
                  record.class.fully_qualified_name_set
                }
            }
  validates :relative_name,
            presence: true

  #
  # Class Methods
  #

  # @note Use {root_fully_qualified_name_set} to get just the the covering set of {#fully_qualified_name}.
  #
  # Set of valid {#fully_qualified_name} derived from {Metasploit::Cache::Platform::Seed::RELATIVE_NAME_TREE}.
  #
  # @return [Set<String>]
  def self.fully_qualified_name_set
    unless instance_variable_defined? :@fully_qualified_name_set
      @fully_qualified_name_set = Set.new

      self::Seed.each_attributes do |attributes|
        parent = attributes.fetch(:parent)
        relative_name = attributes.fetch(:relative_name)

        if parent
          fully_qualified_name = "#{parent} #{relative_name}"
        else
          fully_qualified_name = relative_name
        end

        @fully_qualified_name_set.add fully_qualified_name

        # yieldreturn
        fully_qualified_name
      end

      @fully_qualified_name_set.freeze
    end

    @fully_qualified_name_set
  end

  # @note Use {fully_qualified_name_set} to get the expanded set of {#fully_qualified_name}.
  #
  # Set of valid {#fully_qualified_name} derived from roots of {Metasploit::Cache::Platform::Seed::RELATIVE_NAME_TREE}.
  #
  # @return [Set<String>]
  def self.root_fully_qualified_name_set
    unless instance_variable_defined? :@root_fully_qualified_name_set
      @root_fully_qualified_name_set = self::Seed::RELATIVE_NAME_TREE.each_key.each_with_object(Set.new) do |root_fully_qualified_name, set|
        set.add root_fully_qualified_name
      end
    end

    @root_fully_qualified_name_set
  end

  #
  # Instance Methods
  #

  # Derives {#fully_qualified_name} from {#parent}'s {#fully_qualified_name} and this platform's {#relative_name}.
  #
  # @return [nil] if {#relative_name} is blank.
  # @return [String] {#relative_name} if {#parent} is `nil`.
  # @return [String] '<{#parent} {#relative_name}> <{#relative_name}>' if {#parent} is not `nil`.
  def derived_fully_qualified_name
    if relative_name.present?
      if parent
        "#{parent.fully_qualified_name} #{relative_name}".encode('UTF-8')
      else
        relative_name
      end
    end
  end

  Metasploit::Concern.run(self)
end