RSpec.describe Metasploit::Cache::Payload::Stage::Instance::Persister, type: :model do
  it_should_behave_like 'Metasploit::Cache::Module::Persister'

  context 'resurrecting attributes' do
    context '#persistent' do
      subject(:persistent) {
        payload_stage_instance_persister.persistent
      }

      #
      # lets
      #

      let(:payload_stage_instance_persister) {
        described_class.new(
            ephemeral: metasploit_module_instance
        )
      }

      let(:metasploit_class) {
        double(
            'payload stage Metasploit Module class',
            persister_by_source: {},
            real_path_sha1_hex_digest: existing_payload_stage_instance.payload_stage_class.ancestor.real_path_sha1_hex_digest
        )
      }

      let(:metasploit_module_instance) {
        double('payload stage Metasploit Module instance').tap { |instance|
          allow(instance).to receive(:class).and_return(metasploit_class)
        }
      }

      #
      # let!s
      #

      let!(:existing_payload_stage_instance) {
        FactoryGirl.create(:full_metasploit_cache_payload_stage_instance)
      }

      #
      # Callbacks
      #

      before(:each) do
        metasploit_class.persister_by_source[:ancestor] = metasploit_class
      end

      it { is_expected.to be_a Metasploit::Cache::Payload::Stage::Instance }

      it 'has #payload_stage_class matching pre-existing Metasploit::Cache::Payload::Stage::Class' do
        expect(persistent.payload_stage_class).to eq(existing_payload_stage_instance.payload_stage_class)
      end
    end
  end

  context '#persist' do
    include_context 'ActiveSupport::TaggedLogging'

    subject(:persist) {
      payload_stage_instance_persister.persist(*args)
    }

    let(:payload_stage_instance_persister) {
      described_class.new(
          ephemeral: metasploit_module_instance,
          logger: logger
      )
    }

    let(:metasploit_module_instance) {
      double(
          'payload stage Metasploit Module instance',
          arch: [
              FactoryGirl.generate(:metasploit_cache_architecture_abbreviation)
          ],
          author: [
              double(
                  'Metasploit Module instance author',
                  email: "#{FactoryGirl.generate(:metasploit_cache_email_address_local)}@#{FactoryGirl.generate(:metasploit_cache_email_address_domain)}",
                  name: FactoryGirl.generate(:metasploit_cache_author_name)
              )
          ],
          class: metasploit_class,
          description: FactoryGirl.generate(:metasploit_cache_payload_stage_instance_description),
          disclosure_date: Date.today,
          name: FactoryGirl.generate(:metasploit_cache_payload_stage_instance_name),
          license: FactoryGirl.generate(:metasploit_cache_license_abbreviation),
          platform: double(
              'Platform List',
              platforms: [
                  double('Platform', realname: 'Windows XP')
              ]
          ),
          privileged: true
      )
    }

    context 'with :to' do
      let(:args) {
        [
            {
                to: payload_stage_instance
            }
        ]
      }

      let(:payload_stage_class) {
        FactoryGirl.create(:metasploit_cache_payload_stage_class)
      }

      let(:payload_stage_instance) {
        payload_stage_class.build_payload_stage_instance
      }

      let(:metasploit_class) {
        double(
            'payload stage Metasploit Module class',
            persister_by_source: {}
        )
      }

      it 'does not access default #persistent' do
        expect(payload_stage_instance_persister).not_to receive(:persistent)

        persist
      end

      it 'uses :to' do
        expect(payload_stage_instance).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        context 'failure' do
          before(:each) do
            payload_stage_instance.valid?

            expect(payload_stage_instance).to receive(:batched_save).and_return(false)
          end

          it 'tags log with Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{payload_stage_instance.payload_stage_class.ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            persist

            full_error_messages = payload_stage_instance.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(logger_string_io.string).to include("Could not be persisted to #{payload_stage_instance.class}: #{full_error_messages}")
          end
        end

        context 'success' do
          specify {
            expect {
              persist
            }.to change(Metasploit::Cache::Payload::Stage::Instance, :count).by(1)
          }
        end
      end
    end

    context 'without :to' do
      #
      # lets
      #

      let(:args) {
        []
      }

      let(:metasploit_class) {
        double(
            'payload stage Metasploit Module class',
            persister_by_source: {},
            real_path_sha1_hex_digest: existing_payload_stage_instance.payload_stage_class.ancestor.real_path_sha1_hex_digest
        )
      }

      #
      # let!s
      #

      let!(:existing_payload_stage_instance) {
        FactoryGirl.create(:full_metasploit_cache_payload_stage_instance)
      }

      #
      # Callbacks
      #

      before(:each) do
        metasploit_class.persister_by_source[:ancestor] = metasploit_class
      end

      it 'defaults to #persistent' do
        expect(payload_stage_instance_persister).to receive(:persistent).and_call_original

        persist
      end

      it 'uses #batched_save' do
        expect(payload_stage_instance_persister.persistent).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end