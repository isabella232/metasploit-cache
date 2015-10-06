# Ephemeral cache for connecting an in-memory Metasploit Module to its persisted {Metasploit::Cache::Module::Ancestor}.
class Metasploit::Cache::Module::Ancestor::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # Tagged logger to which to log {#persist_module_ancestor} errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # The Metasploit Module being cached.
  #
  # @return [Module]
  attr_accessor :metasploit_module

  # The SHA1 hexdigest of the path where {#metasploit_module} is defined on disk.
  #
  # @return [String]
  attr_accessor :real_path_sha1_hex_digest

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Module.
  #
  # @return [Metasploit::Cache::Module::Ancestor]
  resurrecting_attr_accessor :module_ancestor do
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Module::Ancestor.where(real_path_sha1_hex_digest: real_path_sha1_hex_digest).first
    }
  end

  #
  # Validations
  #

  validates :logger,
            presence: true
  validates :metasploit_module,
            presence: true
  validates :real_path_sha1_hex_digest,
            presence: true

  #
  # Instance Methods
  #

  # @note This ephemeral cache should be validated with `valid?` prior to calling {#persist} to ensure
  #   that {#logger} is present in case of error.
  # @note Validation errors for `module_ancestor` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # Persists ephemeral cache data from {#metasploit_module} and it's namespace to the persistent cache entry.
  #
  # @param options [Hash{Symbol => Metasploit::Cache::Module::Ancestor}]
  # @option options [Metasploit::Cache::Module::Ancestor] :to (module_ancestor) Save cacheable data to `module_ancestor`.
  # @return [Metasploit::Cache::Module::Ancestor] `#persisted?` will be `false` if saving fails
  def persist(options={})
    options.assert_valid_keys(:to)
    module_ancestor = options[:to] || self.module_ancestor

    # Ensure that connection is only held temporary by Thread instead of being memoized to Thread
    ActiveRecord::Base.connection_pool.with_connection do
      module_ancestor_class = module_ancestor.class

      saved = module_ancestor_class.isolation_level(:serializable) {
        module_ancestor_class.transaction {
          module_ancestor.batched_save
        }
      }

      unless saved
        logger.tagged(module_ancestor.real_pathname.to_s) { |tagged|
          tagged.error {
            "Could not be persisted: #{module_ancestor.errors.full_messages.to_sentence}"
          }
        }
      end
    end

    module_ancestor
  end
end