# Code shared between `Mdm::Reference` and `Metasploit::Framework::Reference`.
module Metasploit::Cache::Reference
  extend ActiveModel::Naming
  extend ActiveSupport::Concern

  include Metasploit::Model::Translation

  included do
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations
    include Metasploit::Cache::Derivation
    include Metasploit::Model::Search

    #
    # Derivations
    #

    derives :url, :validate => false

    #
    # Mass Assignment Security
    #

    attr_accessible :designation
    attr_accessible :url

    #
    # Search Attributes
    #

    search_attribute :designation, :type => :string
    search_attribute :url, :type => :string

    #
    # Validations
    #

    validates :designation,
              :presence => {
                  :if => :authority?
              },
              :nil => {
                  :unless => :authority?
              }
    validates :url,
              :presence => {
                  :unless => :authority?
              }
  end

  #
  # Associations
  #

  # @!attribute authority
  #   The {Metasploit::Cache::Authority authority} that assigned {#designation}.
  #
  #   @return [Metasploit::Cache::Authority, nil]

  # @!attribute [r] module_instances
  #   {Metasploit::Cache::Module::Instance Modules} that exploit this reference or describe a proof-of-concept (PoC)
  #   code that the module is based on.
  #
  #   @return [Array<Metasploit::Cache::Module::Instance>]

  #
  # Attributes
  #

  # @!attribute designation
  #   A designation (usually a string of numbers and dashes) assigned by {#authority}.
  #
  #   @return [String, nil]

  # @!attribute url
  #   URL to web page with information about referenced exploit.
  #
  #   @return [String, nil]

  #
  # Instance Methods
  #

  # @!method authority=(authority)
  #   Sets {#authority}.
  #
  #   @param authority [Metasploit::Cache::Authority, nil]  The {Metasploit::Cache::Authority authority} that assigned
  #     {#designation}.  `nil` if only a {#url} reference and not from an {Metasploit::Cache::Authority authority}.

  # Returns whether {#authority} is not `nil`.
  #
  # @return [true] unless {#authority} is `nil`.
  # @return [false] if {#authority} is `nil`.
  def authority?
    authority.present?
  end

  # Derives {#url} based how {#authority} routes {#designation designations} to a URL.
  #
  # @return [String, nil]
  def derived_url
    derived = nil

    if authority and designation.present?
      derived = authority.designation_url(designation)
    end

    derived
  end

  # @!method designation=(designation)
  #   Sets {#designation}.
  #
  #   @param designation [String, nil] a designation (usually a string of numbers and dashes) assigned by {#authority};
  #     `nil` if a {#url} only reference.
  #   @return [void]

  # @!method url=(url)
  #   Sets {#url}.
  #
  #   @param url [String, nil] URL to web page with information about referenced exploit. Should only be `nil` if
  #     {#authority} {Metasploit::Cache::Authority#obsolete} is `true`.
  #   @return [void]
end
