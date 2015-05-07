RSpec.describe Metasploit::Cache::Payload::Stage::Class, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:ancestor).class_name('Metasploit::Cache::Payload::Stage::Ancestor') }
    it { is_expected.to have_one(:payload_stage_instance).class_name('Metasploit::Cache::Payload::Stage::Instance').dependent(:destroy).inverse_of(:payload_stage_class) }
    it { is_expected.to belong_to(:rank).class_name('Metasploit::Cache::Module::Rank') }
  end

  context 'factories' do
    context 'metasploit_cache_payload_stage_class' do
      subject(:metasploit_cache_payload_stage_class) {
        FactoryGirl.build(:metasploit_cache_payload_stage_class)
      }

      it { is_expected.to be_valid }

      context 'loading' do
        include_context 'Metasploit::Cache::Spec::Unload.unload'

        let(:logger) {
          ActiveSupport::TaggedLogging.new(
              Logger.new(string_io)
          )
        }

        let(:module_ancestor_load) {
          Metasploit::Cache::Module::Ancestor::Load.new(
              logger: logger,
              maximum_version: 4,
              module_ancestor: metasploit_cache_payload_stage_class.ancestor
          )
        }

        let(:string_io) {
          StringIO.new
        }

        before(:each) do
          # To prove Payload::Direct::Class::Load is setting rank
          metasploit_cache_payload_stage_class.rank = nil
        end

        context 'Metasploit::Cache::Module::Ancestor::Load' do
          subject {
            module_ancestor_load
          }

          it { is_expected.to be_valid }
        end

        context 'Metasploit::Cache::Payload::Direct::Class::Load' do
          subject(:payload_direct_class_load) {
            Metasploit::Cache::Payload::Direct::Class::Load.new(
                logger: logger,
                metasploit_module: module_ancestor_load.metasploit_module,
                payload_direct_class: metasploit_cache_payload_stage_class,
                payload_superclass: Metasploit::Cache::Direct::Class::Superclass
            )
          }

          before(:each) do
            expect(module_ancestor_load).to be_valid
          end

          it { is_expected.to be_valid }

          specify {
            expect {
              payload_direct_class_load.valid?
            }.to change(described_class, :count).from(0).to(1)
          }
        end
      end
    end
  end
end