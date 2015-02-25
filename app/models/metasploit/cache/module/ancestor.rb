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

  # Maps directory to {#module_type} for converting a {#real_path} into a {#module_type} and {#reference_name}
  MODULE_TYPE_BY_DIRECTORY = DIRECTORY_BY_MODULE_TYPE.invert

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

  derives :reference_name, :validate => false

  # Don't validate attributes that require accessing file system to derive value
  derives :real_path_modified_at, :validate => false
  derives :real_path_sha1_hex_digest, :validate => false

  #
  # Mass Assignment Security
  #

  # parent_path_id is NOT accessible since it should be supplied from context
  # reference_name is accessible because it's needed to derive {#real_path}.
  attr_accessible :reference_name
  # real_path is accessible since {#reference_name} can be derived from real_path.
  attr_accessible :real_path
  # real_path_modified_at is NOT accessible since it's derived
  # real_path_sha1_hex_digest is NOT accessible since it's derived

  #
  # Validations
  #

  validates :module_type,
            inclusion: {
                in: Metasploit::Cache::Module::Type::ALL
            }
  validates :parent_path,
            presence: true
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
            }

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

  # The type of the module. This would be called #type, but #type is reserved for ActiveRecord's single table
  # inheritance.
  #
  # @return [String] value in {Metasploit::Cache::Module::Ancestor::MODULE_TYPE_BY_DIRECTORY}.
  def module_type
    MODULE_TYPE_BY_DIRECTORY[module_type_directory]
  end

  # The directory under {Metasploit::Cache::Module::Path parent_path.real_path}.
  #
  # @return [String]
  def module_type_directory
    relative_file_names.first
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
  # @return [String] The {#reference_name} without the {#payload_type_directory}
  # @return [nil] if {#module_type} is not `'payload'`
  def payload_name
    payload_name = nil

    if module_type == Metasploit::Cache::Module::Type::PAYLOAD && reference_name && payload_type_directory
      escaped_payload_type_directory = Regexp.escape(payload_type_directory)
      payload_type_directory_regexp = /^#{escaped_payload_type_directory}\//
      payload_name = reference_name.gsub(payload_type_directory_regexp, '')
    end

    payload_name
  end

  # The directory for payload type under {#module_type_directory} in {#real_path}.
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
