# A potential target for a {Mdm::Module::Instance module}.  Targets can change options including offsets for ROP chains
# to tune an exploit to work with different system libraries and versions.
class Mdm::Module::Target < ActiveRecord::Base
  include Metasploit::Model::Module::Target
  include MetasploitDataModels::Batch::Descendant

  self.table_name = 'module_targets'

  #
  #
  # Associations
  #
  #

  # @!attribute [rw] module_instance
  #   Module where this target was declared.
  #
  #   @return [Mdm::Module::Instance]
  belongs_to :module_instance, class_name: 'Mdm::Module::Instance', inverse_of: :targets

  # @!attribute [rw] target_architectures
  #   Joins this target to its {#architectures}
  #
  #   @return [Array<Mdm::Module::Target::Architecture]
  has_many :target_architectures,
           class_name: 'Mdm::Module::Target::Architecture',
           dependent: :destroy,
           foreign_key: :module_target_id,
           inverse_of: :module_target

  # @!attribute [rw] target_platforms
  #   Joins this target to its {#platforms}
  #
  #   @return [Array<Mdm::Module::Target::Platform>]
  has_many :target_platforms,
           class_name: 'Mdm::Module::Target::Platform',
           dependent: :destroy,
           foreign_key: :module_target_id,
           inverse_of: :module_target

  #
  # through: :target_architectures
  #

  # @!attribute [r] architectures
  #   Architectures that this target supports, either by being declared specifically for this target or because
  #   this target did not override architectures and so inheritted the architecture set from the class.
  #
  #   @return [Array<Metasploit::Model::Architecture>]
  has_many :architectures, class_name: 'Mdm::Architecture', through: :target_architectures

  #
  # through: :target_platforms
  #

  # @!attribute [r] platforms
  #   Platforms that this target supports, either by being declared specifically for this target or because this
  #   target did not override platforms and so inheritted the platform set from the class.
  #
  #   @return [Array<Metasploit::Model::Platform>]
  has_many :platforms, class_name: 'Mdm::Platform', through: :target_platforms

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   The name of this target.
  #
  #   @return [String]

  #
  # Validations
  #

  validates :name,
            uniqueness: {
                scope: :module_instance_id,
                unless: :batched?
            }

  ActiveSupport.run_load_hooks(:mdm_module_target, self)
end
