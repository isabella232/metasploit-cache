# Implementation of {Metasploit::Cache::EmailAddress} to allow testing of {Metasploit::Cache::EmailAddress} using an in-memory
# ActiveModel and use of factories.
class Dummy::EmailAddress < Metasploit::Model::Base
  include Metasploit::Cache::EmailAddress

  #
  # Attributes
  #

  # @!attribute [rw] domain
  #   The domain part of the email address after the `'@'`.
  #
  #   @return [String]
  attr_accessor :domain

  # @!attribute [rw] full
  #   The full email address.
  #
  #   @return [String] <{#local}>@<{#domain}
  attr_accessor :full

  # @!attribute [rw] local
  #   The local part of the email address before the `'@'`.
  #
  #   @return [String]
  attr_accessor :local
end
