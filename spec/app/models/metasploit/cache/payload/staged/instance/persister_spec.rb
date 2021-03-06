RSpec.describe Metasploit::Cache::Payload::Staged::Instance::Persister, type: :model do
  shared_context 'metasploit_module_instance' do
    let(:existing_payload_staged_instance) {
      FactoryGirl.create(
          :metasploit_cache_payload_staged_instance,
          payload_staged_class_payload_stager_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
      )
    }

    let(:metasploit_module_instance) {
      double(
          'payload staged Metasploit Module instance',
          class: double(
              'payload staged Metasploit Module class',
              ancestor_by_source: {
                  stage: double(
                      'payload stage Metasploit Module module',
                      persister_by_source: {}
                  ).tap { |payload_stage_metasploit_module_module|
                    payload_stage_metasploit_module_module.persister_by_source[:ancestor] = Metasploit::Cache::Module::Ancestor::Persister.new(
                        ephemeral: payload_stage_metasploit_module_module,
                        real_path_sha1_hex_digest: existing_payload_staged_instance.payload_staged_class.payload_stage_instance.payload_stage_class.ancestor.real_path_sha1_hex_digest
                    )
                  },
                  stager: double(
                      'payload stager Metasploit Module module',
                      persister_by_source: {}
                  ).tap { |payload_stager_metasploit_module_module|
                    payload_stager_metasploit_module_module.persister_by_source[:ancestor] = Metasploit::Cache::Module::Ancestor::Persister.new(
                        ephemeral: payload_stager_metasploit_module_module,
                        real_path_sha1_hex_digest: existing_payload_staged_instance.payload_staged_class.payload_stager_instance.payload_stager_class.ancestor.real_path_sha1_hex_digest
                    )
                  }
              },
              persister_by_source: {}
          ).tap { |payload_staged_metasploit_module_class|
            payload_staged_metasploit_module_class.persister_by_source[:class] = Metasploit::Cache::Payload::Staged::Class::Persister.new(
                ephemeral: payload_staged_metasploit_module_class
            )
          }
      )
    }
  end

  it_should_behave_like 'Metasploit::Cache::Module::Persister'

  context 'resurrecting attributes' do
    context '#persistent' do
      include_context ':metasploit_cache_payload_handler_module'
      include_context 'Metasploit::Cache::Spec::Unload.unload'
      include_context 'metasploit_module_instance'

      subject(:persistent) {
        payload_staged_instance_persister.persistent
      }

      #
      # lets
      #

      let(:payload_staged_instance_persister) {
        described_class.new(
            ephemeral: metasploit_module_instance
        )
      }

      #
      # Callbacks
      #

      before(:each) do
        # create now that load_path is setup
        existing_payload_staged_instance
      end

      it { is_expected.to be_a Metasploit::Cache::Payload::Staged::Instance }

      it 'is pre-existing Metasploit::Cache::Payload::Staged::Instance' do
        expect(persistent).to eq(existing_payload_staged_instance)
      end

      context 'Metasploit::Cache::Paylaod::Staged::Instance#payload_stage_instance' do
        subject(:payload_staged_class) {
          persistent.payload_staged_class
        }

        it { is_expected.to be_persisted }

        context 'Metasploit::Cache::Payload::Staged::Class#payload_stage_instance' do
          subject(:payload_stage_instance) {
            payload_staged_class.payload_stage_instance
          }

          it { is_expected.to be_persisted }

          context 'Metasploit::Cache::Payload::Stage::Instance#payload_stage_class' do
            subject(:payload_stage_class) {
              payload_stage_instance.payload_stage_class
            }

            it { is_expected.to be_persisted }

            context 'Metasploit::Cache::Payload::Stage::Class#ancestor' do
              subject(:ancestor) {
                payload_stage_class.ancestor
              }

              it { is_expected.to be_persisted }
            end
          end
        end

        context 'Metasploit::Cache::Payload::Staged::Class#payload_stager_instance' do
          subject(:payload_stager_instance) {
            payload_staged_class.payload_stager_instance
          }

          it { is_expected.to be_persisted }

          context 'Metasploit::Cache::Payload::Stager::Instance#payload_stager_class' do
            subject(:payload_stager_class) {
              payload_stager_instance.payload_stager_class
            }

            it { is_expected.to be_persisted }

            context 'Metasploit::Cache::Payload::Stager::Class#ancestor' do
              subject(:ancestor) {
                payload_stager_class.ancestor
              }

              it { is_expected.to be_persisted }
            end
          end
        end
      end
    end
  end

  context '#persist' do
    include_context 'ActiveSupport::TaggedLogging'
    include_context ':metasploit_cache_payload_handler_module'
    include_context 'Metasploit::Cache::Spec::Unload.unload'

    subject(:persist) {
      payload_staged_instance_persister.persist(*args)
    }

    let(:payload_staged_instance_persister) {
      described_class.new(
          ephemeral: metasploit_module_instance,
          logger: logger
      )
    }

    context 'with :to' do
      let(:args) {
        [
            {
                to: payload_staged_instance
            }
        ]
      }

      let(:payload_stage_ancestor) {
        payload_staged_class.payload_stage_instance.payload_stage_class.ancestor
      }

      let(:payload_staged_class) {
        FactoryGirl.create(
            :full_metasploit_cache_payload_staged_class,
            payload_stager_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      let(:payload_staged_instance) {
        payload_staged_class.build_payload_staged_instance
      }

      let(:payload_stager_ancestor) {
        payload_staged_class.payload_stager_instance.payload_stager_class.ancestor
      }

      let(:metasploit_module_instance) {
        double('payload staged Metasploit Module instance')
      }

      it 'does not access default #persistent' do
        expect(payload_staged_instance_persister).not_to receive(:persistent)

        persist
      end

      it 'uses :to' do
        expect(payload_staged_instance).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        context 'failure' do
          #
          # Callbacks
          #

          before(:each) do
            payload_staged_instance.valid?

            expect(payload_staged_instance).to receive(:batched_save).and_return(false)
          end

          it 'tags log with Metasploit::Cache::Payload::Staged::Instance#payload_staged_class ' \
             'Metasploit::Cache::Payload::Staged::Class#payload_stage_instance ' \
             'Metasploit::Cache::Payload::Stage::Instance#payload_stage_class ' \
             'Metasploit::Cache::Payload::Stage::Class#ancestor Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{payload_stage_ancestor.real_pathname.to_s}]")
          end

          it 'tags log with Metasploit::Cache::Payload::Staged::Instance#payload_staged_class ' \
             'Metasploit::Cache::Payload::Staged::Class#payload_stager_instance ' \
             'Metasploit::Cache::Payload::Stager::Instance#payload_stager_class ' \
             'Metasploit::Cache::Payload::Stager::Class#ancestor Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{payload_stager_ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            # Right now, there are no validation errors because there are no attributes on
            # Metasploit::Cache::Payload::Staged::Instance and the associations are already set.
            expect(payload_staged_instance.errors.full_messages.to_sentence).to be_blank

            # ... so, fake some validation errors
            payload_staged_instance.errors.add(:base, :invalid)

            persist

            full_error_messages = payload_staged_instance.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(logger_string_io.string).to include("Could not be persisted to #{payload_staged_instance.class}: #{full_error_messages}")
          end
        end

        context 'success' do
          specify {
            expect {
              persist
            }.to change(Metasploit::Cache::Payload::Staged::Instance, :count).by(1)
          }
        end
      end
    end

    context 'without :to' do
      include_context 'metasploit_module_instance'

      #
      # lets
      #

      let(:args) {
        []
      }

      #
      # Callbacks
      #

      before(:each) do
        existing_payload_staged_instance
      end

      it 'defaults to #persistent' do
        expect(payload_staged_instance_persister).to receive(:persistent).and_call_original

        persist
      end

      it 'uses #batched_save' do
        expect(payload_staged_instance_persister.persistent).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end