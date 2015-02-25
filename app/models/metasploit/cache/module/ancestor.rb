require 'digest/sha1'

# Module metadata that can be derived from a loaded module, which is an ancestor, in the sense of ruby's
# Module#ancestor, or a metasploit module class, Class<Msf::Module>.  Loaded modules will be either a ruby Module
# (for payloads) or a ruby Class (for all non-payloads).
class Metasploit::Cache::Module::Ancestor < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Derivation
  include Metasploit::Cache::Derivation::FullName
  include Metasploit::Cache::RealPathname
  include Metasploit::Model::Translation

  autoload :Cache
  autoload :Cacheable
  autoload :Load
  autoload :Spec

  #
  # CONSTANTS
  #

  # The directory for a given {#module_type} is a not always the pluralization of #module_type, so this maps the
  # #module_type to the type directory that is used to generate the #real_path from the #module_type and
  # #reference_name.
  DIRECTORY_BY_MODULE_TYPE = {
      Metasploit::Cache::Module::Type::AUX => Metasploit::Cache::Module::Type::AUX,
      Metasploit::Cache::Module::Type::ENCODER => Metasploit::Cache::Module::Type::ENCODER.pluralize,
      Metasploit::Cache::Module::Type::EXPLOIT => Metasploit::Cache::Module::Type::EXPLOIT.pluralize,
      Metasploit::Cache::Module::Type::NOP => Metasploit::Cache::Module::Type::NOP.pluralize,
      Metasploit::Cache::Module::Type::PAYLOAD => Metasploit::Cache::Module::Type::PAYLOAD.pluralize,
      Metasploit::Cache::Module::Type::POST => Metasploit::Cache::Module::Type::POST
  }

  # File extension used for metasploit modules.
  EXTENSION = '.rb'

  # The {#payload_type payload types} that require {#handler_type}.
  HANDLED_TYPES = [
      'single'
  ]

  # Maps directory to {#module_type} for converting a {#real_path} into a {#module_type} and {#reference_name}
  MODULE_TYPE_BY_DIRECTORY = DIRECTORY_BY_MODULE_TYPE.invert

  # Valid values for {#payload_type} if {#payload?} is `true`.
  PAYLOAD_TYPES = [
      'single'
  ]

  # Regexp to keep '\' out of reference names
  REFERENCE_NAME_REGEXP = /\A[\-0-9A-Z_a-z]+(?:\/[\-0-9A-Z_a-z]+)*\Z/

  # Separator used to join names in {#reference_name}.  It is always '/', even on Windows, where '\' is a valid
  # file separator.
  REFERENCE_NAME_SEPARATOR = '/'

  # Regular expression matching a full SHA-1 hex digest.
  SHA1_HEX_DIGEST_REGEXP = /\A[0-9a-z]{40}\Z/

  #
  #
  # Associations
  #
  #

  # @!attribute parent_path
  #   Path under which this load's type directory, {Metasploit::Cache::Module::Ancestor#module_type_directory}, and
  #   reference name path, {Metasploit::Cache::Module::Ancestor#reference_path} exists.
  #
  #   @return [Metasploit::Cache::Module::Path]
  belongs_to :parent_path, class_name: 'Metasploit::Cache::Module::Path', inverse_of: :module_ancestors

  # @!attribute relationships
  #   Relates this {Metasploit::Cache::Module::Ancestor} to the {Metasploit::Cache::Module::Class Metasploit::Cache::Module::Classes} that
  #   {Metasploit::Cache::Module::Relationship#descendant descend} from the {Metasploit::Cache::Module::Ancestor}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Relationship>]
  has_many :relationships, class_name: 'Metasploit::Cache::Module::Relationship', dependent: :destroy, inverse_of: :ancestor

  #
  # through: :relationships
  #

  # @!attribute [r] descendants
  #   {Metasploit::Cache::Module::Class Classes} that either subclass the ruby Class in {#real_path} or include the ruby Module in
  #   {#real_path}.
  #
  #   @return [ActiveRecord::Relation<Metasploit::Cache::Module::Class>]
  has_many :descendants, class_name: 'Metasploit::Cache::Module::Class', through: :relationships

  #
  # Attributes
  #

  # @!attribute full_name
  #   The full name of the module.  The full name is `"#{module_type}/#{reference_name}"`.
  #
  #   @return [String]

  # @!attribute module_type
  #   The type of the module. This would be called #type, but #type is reserved for ActiveRecord's single table
  #   inheritance.
  #
  #   @return [String] key in {Metasploit::Cache::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE}.

  # @!attribute payload_type
  #   For payload modules, the type of payload, either 'single', 'stage', or 'stager'.
  #
  #   @return ['single', 'stage', 'stager'] if {Metasploit::Cache::Module::Ancestor#payload?} is `true`.
  #   @return [nil] if {Metasploit::Cache::Module::Ancestor#payload?} is `false`
  #   @see Metasploit::Cache::Module::Ancestor::PAYLOAD_TYPES

  # @!attribute real_path
  #   The real (absolute) path to module file on-disk.
  #
  #   @return [String]

  # @!attribute real_path_modified_at
  #   The modification time of the module {#real_path file on-disk}.
  #
  #   @return [DateTime]

  # @!attribute real_path_sha1_hex_digest
  #   The SHA1 hexadecimal digest of contents of the file at {#real_path}.  Stored as a string because postgres does not
  #   have support for a 160 bit numerical type and the hexdigest format is more recognizable when using SQL directly.
  #
  #   @see Digest::SHA1#hexdigest
  #   @return [String]

  # @!attribute reference_name
  #   The reference name of the module.  The name of the module under its {#module_type type}.
  #
  #   @return [String]

  #
  # Derivations
  #

  #
  # Module Cache Construction derivation of {#module_type} and {#reference_name} from {#real_path} and
  # {Metasploit::Cache::Module::Path#real_path}.
  #

  derives :module_type, :validate => false
  derives :reference_name, :validate => false

  #
  # Normal derivation from setting {#module_type} and {#reference_name}
  #

  derives :full_name, :validate => true
  derives :payload_type, :validate => true
  derives :real_path, :validate => true

  # Don't validate attributes that require accessing file system to derive value
  derives :real_path_modified_at, :validate => false
  derives :real_path_sha1_hex_digest, :validate => false

  #
  # Mass Assignment Security
  #

  # full_name is NOT accessible since it's derived and must match {#derived_full_name} so there's no reason for a
  # user to set it.
  # module_type is accessible because it's needed to derive {#full_name} and {#real_path}.
  attr_accessible :module_type
  # parent_path_id is NOT accessible since it should be supplied from context
  # payload_type is NOT accessible since it's derived and must match {#derived_payload_type}.
  # reference_name is accessible because it's needed to derive {#full_name} and {#real_path}.
  attr_accessible :reference_name
  # real_path is accessible since {#module_type} and {#reference_name} can be derived from real_path.
  attr_accessible :real_path
  # real_path_modified_at is NOT accessible since it's derived
  # real_path_sha1_hex_digest is NOT accessible since it's derived

  #
  # Validations
  #

  validates :full_name,
            uniqueness: {
                unless: :batched?
            }
  validates :module_type,
            inclusion: {
                in: Metasploit::Cache::Module::Type::ALL
            }
  validates :parent_path,
            presence: true
  validates :payload_type,
            inclusion: {
                if: :payload?,
                in: PAYLOAD_TYPES
            },
            nil: {
                unless: :payload?
            }
  validates :real_path,
            uniqueness: {
                unless: :batched?
            }
  validates :real_path_modified_at,
            presence: true
  validates :real_path_sha1_hex_digest,
            format: {
                with: SHA1_HEX_DIGEST_REGEXP
            },
            uniqueness: {
                unless: :batched?
            }
  validates :reference_name,
            format: {
                with: REFERENCE_NAME_REGEXP
            },
            uniqueness: {
                scope: :module_type,
                unless: :batched?
            }

  #
  # Class Methods
  #

  # Returns whether {#handler_type} is required or must be `nil` for the given payload_type.
  #
  # @param options [Hash{Symbol => String,nil}]
  # @option options [String, nil] module_type (nil) `nil` or an element of
  #   `Metasploit::Cache::Module::Ancestor::MODULE_TYPES`.
  # @option options [String, nil] payload_type (nil) `nil` or an element of {PAYLOAD_TYPES}.
  # @return [true] if {#handler_type} must be present.
  # @return [false] if {#handler_type} must be `nil`.
  def self.handled?(options={})
    options.assert_valid_keys(:module_type, :payload_type)

    handled = false
    module_type = options[:module_type]
    payload_type = options[:payload_type]

    if module_type == 'payload' and HANDLED_TYPES.include? payload_type
      handled = true
    end

    handled
  end

  #
  # Instance Methods
  #

  def batched?
    super || loading_context?
  end
  # The contents of {#real_path}.
  #
  # @return [String] contents of file at {#real_path}.
  # @return [nil] if {#real_path} is `nil`.
  # @return [nil] if {#real_path} does not exist on-disk.
  def contents
    contents = nil

    if real_path
      # rescue around both File calls since file could be deleted before size or after size and before read
      begin
        size = File.size(real_path)
        # Specify full size of file for faster read on Windows (less chance of context switching mid-read).
        # Open in binary mode in Windows to handle non-text content embedded in file.
        contents = File.read(real_path, size, 0, mode: 'rb')
      rescue Errno::ENOENT
        contents = nil
      end
    end

    contents
  end

  # Derives {#module_type} from {#real_path} and {Metasploit::Cache::Module::Path#real_path}.
  #
  # @return [String]
  # @return [nil] if {#real_path} is `nil`
  # @return [nil] if {#relative_file_names} does not start with a module type directory.
  def derived_module_type
    module_type_directory = relative_file_names.first
    derived = MODULE_TYPE_BY_DIRECTORY[module_type_directory]

    derived
  end

  # Derives {#payload_type} from {#reference_name}.
  #
  # @return [String]
  # @return [nil] if {#payload_type_directory} is `nil`
  def derived_payload_type
    derived = nil
    directory = payload_type_directory

    if directory
      derived = directory.singularize
    end

    derived
  end

  # Derives {#real_path} by combining {Metasploit::Cache::Module::Path#real_path parent_path.real_path},
  # {#module_type_directory}, and {#reference_path} in the same way the module loader does in
  # metasploit-framework.
  #
  # @return [String] the real path to the file holding the ruby Module or ruby Class represented by this ancestor.
  # @return [nil] if {#parent_path} is `nil`.
  # @return [nil] if {Metasploit::Cache::Module::Path#real_path parent_path.real_path} is `nil`.
  # @return [nil] if {#module_type_directory} is `nil`.
  # @return [nil] if {#reference_name} is `nil`.
  def derived_real_path
    derived_real_path = nil

    if parent_path and parent_path.real_path and module_type_directory and reference_path
      derived_real_path = File.join(
          parent_path.real_path,
          module_type_directory,
          reference_path
      )
    end

    derived_real_path
  end

  # Derives {#real_path_modified_at} by getting the modification time of the file on-disk.
  #
  # @return [Time] modification time of {#real_path} if {#real_path} exists on disk and modification time can be
  #   queried by user.
  # @return [nil] if {#real_path} does not exist or user cannot query the file's modification time.
  def derived_real_path_modified_at
    real_path_string = real_path.to_s

    begin
      mtime = File.mtime(real_path_string)
    rescue Errno::ENOENT
      nil
    else
      mtime.utc
    end
  end

  # Derives {#real_path_sha1_hex_digest} by running the contents of {#real_path} through Digest::SHA1.hexdigest.
  #
  # @return [String] 40 character SHA1 hex digest if {#real_path} can be read.
  # @return [nil] if {#real_path} cannot be read.
  def derived_real_path_sha1_hex_digest
    begin
      sha1 = Digest::SHA1.file(real_path.to_s)
    rescue Errno::ENOENT
      hex_digest = nil
    else
      hex_digest = sha1.hexdigest
    end

    hex_digest
  end

  # Derives {#reference_name} from {#real_path} and {Metasploit::Cache::Module::Path#real_path}.
  #
  # @return [String]
  # @return [nil] if {#real_path} is `nil`.
  def derived_reference_name
    derived = nil
    reference_name_file_names = relative_file_names.drop(1)
    reference_name_base_name = reference_name_file_names[-1]

    if reference_name_base_name
      if File.extname(reference_name_base_name) == EXTENSION
        reference_name_file_names[-1] = File.basename(reference_name_base_name, EXTENSION)
        derived = reference_name_file_names.join(REFERENCE_NAME_SEPARATOR)
      end
    end

    derived
  end

  # @!method full_name=(full_name)
  #   Sets {#full_name}.
  #
  #   @param full_name [String] `"#{module_type}/#{reference_name}"`.
  #   @return [void]

  # Returns whether {#handler_type} is required or must be `nil`.
  #
  # @return (see handled?)
  # @see handled?
  def handled?
    self.class.handled?(
        :module_type => module_type,
        :payload_type => payload_type
    )
  end

  # @!method handler_type=(handler_type)
  #   Sets {#handler_type}.
  #
  #   @param handler_type [String, nil] The handler type (in the case of singles) or (in the case of stagers) the
  #     handler type alias.  Handler type is appended to the end of the single's or stage's {#reference_name} to get the
  #     {Metasploit::Cache::Module::Class#reference_name}; `nil` if {Metasploit::Cache::Module::Ancestor#handled?} is
  #     `false`.
  #   @return [void]

  # @!method module_type=(module_type)
  #   Sets {#module_type}.
  #
  #   @param module_type [String] key in {Metasploit::Cache::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE}. The type of
  #     the module. This would be called #type, but #type is reserved for ActiveRecord's single table inheritance.
  #   @return [void]

  # The directory for {#module_type} under {Metasploit::Cache::Module::Path parent_path.real_path}.
  #
  # @return [String]
  # @see Metasploit::Cache::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE
  def module_type_directory
    Metasploit::Cache::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE[module_type]
  end

  # @!method parent_path=(parent_path)
  #   Sets {#parent_path}.
  #
  #   @param parent_path [Metasploit::Cache::Module::Path] Path under which this ancestor exists on-disk.
  #   @return [void]

  # Return whether this forms part of a payload (either a single, stage, or stager).
  #
  # @return [true] if {#module_type} == 'payload'
  # @return [false] if {#module_type} != 'payload'
  def payload?
    if module_type == Metasploit::Cache::Module::Type::PAYLOAD
      true
    else
      false
    end
  end

  # The name used to forming the {Metasploit::Cache::Module::Class#reference_name} for payloads.
  #
  # @return [String] The {#reference_name} without the {#payload_type_directory} if {#payload_type} is `'single'`
  #   or `'stage'`
  # @return [String] The {#handler_type} if {#payload_type} is `'stager'`
  # @return [nil] if {#module_type} is not `'payload'`
  def payload_name
    payload_name = nil

    if module_type == Metasploit::Cache::Module::Type::PAYLOAD
      case payload_type
        when 'single', 'stage'
          if reference_name && payload_type_directory
            escaped_payload_type_directory = Regexp.escape(payload_type_directory)
            payload_type_directory_regexp = /^#{escaped_payload_type_directory}\//
            payload_name = reference_name.gsub(payload_type_directory_regexp, '')
          end
        when 'stager'
          payload_name = nil
      end
    end

    payload_name
  end

  # @!method payload_type=(payload_type)
  #   Sets {#payload_type}.
  #
  #   @param payload_type ['single', 'stage', 'stager'] if `Metasploit::Cache::Module::Ancestor#payload?` is `true`,
  #     the type of the payload; otherwise `nil`.
  #   @return [void]

  # The directory for {#payload_type} under {#module_type_directory} in {#real_path}.
  #
  # @return [String] first directory in reference_name
  # @return [nil] if {#payload?} is `false`.
  # @return [nil] if {#reference_name} is `nil`.
  def payload_type_directory
    directory = nil

    if payload? and reference_name
      head, _tail = reference_name.split(REFERENCE_NAME_SEPARATOR, 2)
      directory = head
    end

    directory
  end

  # @!method real_path=(real_path)
  #   Sets {#real_path}.
  #
  #   @param real_path [String] The real (absolute) path to module file on-disk.
  #   @return [void]

  # @!method real_path_modified_at=(real_path_modified_at)
  #   Sets {#real_path_modified_at}.
  #
  #   @param real_path_modified_at [String] The modification time of the module {#real_path file on-disk}.
  #   @return [void]

  # @!method real_path_sha1_hex_digest=(real_path_sha1_hex_digest)
  #   Sets {#real_path_sha1_hex_digest}.
  #
  #   @param real_path_sha1_hex_digest [String] The SHA1 hexadecimal digest of contents of the file at {#real_path}.
  #   @return [void]

  # @!method relationships=(relationships)
  #   Sets {#relationships}.
  #
  #   @param relationships [Enumerable<Metasploit::Cache::Model::Relationship>] Relates this
  #     {Metasploit::Cache::Module::Ancestor} to the
  #     {Metasploit::Cache::Module::Class Metasploit::Cache::Module::Classes} that
  #     {Metasploit::Cache::Module::Relationship#descendant descend} from the {Metasploit::Cache::Module::Ancestor}.
  #   @return [void]

  # File names on {#relative_pathname}.
  #
  # @return [Enumerator<String>]
  def relative_file_names
    relative_pathname = self.relative_pathname

    if relative_pathname
      relative_pathname.each_filename
    else
      # empty enumerator
      Enumerator.new { }
    end
  end

  # {#real_path} relative to {Metasploit::Cache::Module::Path#real_path}
  #
  # @return [Pathname]
  def relative_pathname
    relative_pathname = nil
    real_pathname = self.real_pathname

    if real_pathname
      parent_path = self.parent_path

      if parent_path
        parent_path_real_pathname = parent_path.real_pathname

        if parent_path_real_pathname
          relative_pathname = real_pathname.relative_path_from parent_path_real_pathname
        end
      end
    end

    relative_pathname
  end

  # @!method reference_name=(reference_name)
  #   Sets {#reference_name}.
  #
  #   @param reference_name [String] The name of the module under its {#module_type type}.
  #   @return [void]

  # The path relative to the {#module_type_directory} under the {Metasploit::Cache::Module::Path
  # parent_path.real_path}, including the file {EXTENSION extension}.
  #
  # @return [String] {#reference_name} + {EXTENSION}
  # @return [nil] if {#reference_name} is `nil`.
  def reference_path
    path = nil

    if reference_name
      path = "#{reference_name}#{EXTENSION}"
    end

    path
  end

  private

  # Whether this ancestor is being validated for loading.
  #
  # @return [true] if `#validation_context` is `:loading`
  # @return [false] otherwise
  def loading_context?
    validation_context == :loading
  end

  # Switch back to public for load hooks
  public

  Metasploit::Concern.run(self)
end
