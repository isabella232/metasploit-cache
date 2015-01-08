RSpec.describe Metasploit::Cache::Module::Class do
  it_should_behave_like 'Metasploit::Cache::Module::Class',
                        namespace_name: 'Metasploit::Cache' do
    def attribute_type(attribute)
      type_by_attribute = {
          :full_name => :text,
          :module_type => :string,
          :payload_type => :string,
          :reference_name => :text
      }

      type = type_by_attribute.fetch(attribute)

      type
    end
  end
end