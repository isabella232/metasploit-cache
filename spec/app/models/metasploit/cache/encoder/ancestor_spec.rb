RSpec.describe Metasploit::Cache::Encoder::Ancestor, type: :model do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor.restrict',
                        module_type: 'encoder',
                        module_type_directory: 'encoders'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to have_one(:encoder_class).class_name('Metasploit::Cache::Encoder::Class').with_foreign_key(:ancestor_id) }
    it { is_expected.to belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
  end

  context 'factories' do
    context 'metasploit_cache_encoder_ancestor' do
      subject(:metasploit_cache_encoder_ancestor) {
        FactoryGirl.build(:metasploit_cache_encoder_ancestor)
      }

      it_should_behave_like 'Metasploit::Cache::Module::Ancestor factory',
                            persister_class: Metasploit::Cache::Module::Ancestor::Persister do
        let(:module_ancestor) {
          metasploit_cache_encoder_ancestor
        }
      end
    end
  end
end