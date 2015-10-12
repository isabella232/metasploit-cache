# Connects an in-memory payload_single Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Payload::Single::Unhandled::Instance}.
class Metasploit::Cache::Payload::Single::Unhandled::Instance::Persister < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # CONSTANTS
  #

  # Modules used to synchronize attributes and associations before persisting to database.
  SYNCHRONIZERS = [
      Metasploit::Cache::Persister.synchronizer(:description, :name, :privileged),
      Metasploit::Cache::Architecturable::Persister::ArchitecturableArchitectures,
      Metasploit::Cache::Contributable::Persister::Contributions,
      Metasploit::Cache::Licensable::Persister::LicensableLicenses,
      Metasploit::Cache::Payload::Handable::Persister::Handler,
      Metasploit::Cache::Platformable::Persister::PlatformablePlatforms
  ]

  #
  # Attributes
  #

  # The in-memory payload_single Metasploit Module instance being cached.
  #
  # @return [Object]
  attr_accessor :ephemeral

  # Tagged logger to which to log {#persist} errors.
  #
  # @return [ActiveSupport::TaggerLogger]
  attr_accessor :logger

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this {#ephemeral}.
  #
  # @return [Metasploit::Cache::Payload::Single::Unhandled::Instance]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Payload::Single::Unhandled::Instance.joins(
          payload_single_unhandled_class: :ancestor
      ).where(
           Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).readonly(false).first
    }
  }

  #
  # Validations
  #

  validates :ephemeral,
            presence: true
  validates :logger,
            presence: true

  #
  # Instance Methods
  #

  # @note This persister should be validated with `#valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `payload_single_unhandled_instance` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Payload::Single::Unhandled::Instance] Sve cacheable data to
  #   {Metasploit::Cache::Payload::Single::Unhandled::Instance}. Giving `to` saves a database lookup if
  #   {#payload_single_unhandled_instance} is not loaded.
  # @return [Metasploit::Cache:Payload::Single::Unhandled::Instance] `#persisted?` will be `false` if saving fails.
  def persist(to: persistent)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_logger(to) do |tagged|
        persisted = Metasploit::Cache::Persister.persist destination: to,
                                                         logger: tagged,
                                                         source: ephemeral,
                                                         synchronizers: SYNCHRONIZERS
      end
    end

    persisted
  end

  private

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#auxiliary_instance}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    ephemeral.class.persister_by_source[:ancestor].real_path_sha1_hex_digest
  end
  
  # Tags log with {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  # {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param payload_single_unhandled_instance [Metasploit::Cache::Payload::Single::Unhandled::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(payload_single_unhandled_instance, &block)
    Metasploit::Cache::Module::Ancestor::Persister.with_tagged_logger(
        logger,
        payload_single_unhandled_instance.payload_single_unhandled_class.ancestor,
        &block
    )
  end
end