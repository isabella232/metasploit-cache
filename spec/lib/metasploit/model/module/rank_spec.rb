require 'spec_helper'

RSpec.describe Metasploit::Model::Module::Rank do
  it_should_behave_like 'Metasploit::Model::Module::Rank',
                        namespace_name: 'Dummy'

  # Not in 'Metasploit::Model::Module::Rank' shared example since sequence should not be overridden in namespaces.
  context 'sequences' do
    context 'metasploit_model_module_rank_name' do
      subject(:metasploit_model_module_rank_name) do
        FactoryGirl.generate :metasploit_model_module_rank_name
      end

      it 'should be key in Metasploit::Model::Module::Rank::NUMBER_BY_NAME' do
        expect(Metasploit::Model::Module::Rank::NUMBER_BY_NAME).to have_key(metasploit_model_module_rank_name)
      end
    end

    context 'metasploit_model_module_rank_number' do
      subject(:metasploit_model_module_rank_number) do
        FactoryGirl.generate :metasploit_model_module_rank_number
      end

      it 'should be value in Metasploit::Model::Module::Rank::NUMBER_BY_NAME' do
        expect(Metasploit::Model::Module::Rank::NUMBER_BY_NAME).to have_value(metasploit_model_module_rank_number)
      end
    end
  end
end