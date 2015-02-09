require 'spec_helper'

RSpec.describe Metasploit::Cache::Reference do
  it_should_behave_like 'Metasploit::Cache::Reference',
                        namespace_name: 'Dummy' do
    def attribute_type(attribute)
      type_by_attribute = {
          :designation => :string,
          :url => :text
      }

      type = type_by_attribute.fetch(attribute)

      type
    end

    def authority_with_abbreviation(abbreviation)
      Dummy::Authority.with_abbreviation(abbreviation)
    end
  end
end