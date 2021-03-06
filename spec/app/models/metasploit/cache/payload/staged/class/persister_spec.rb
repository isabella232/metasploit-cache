RSpec.describe Metasploit::Cache::Payload::Staged::Class::Persister, type: :model do
  it_should_behave_like 'Metasploit::Cache::Module::Persister'

  context 'resurrecting attributes' do
    context '#persistent' do
      include_context ':metasploit_cache_payload_handler_module'
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      subject(:persistent) {
        payload_staged_class_persister.persistent
      }

      #
      # lets
      #

      let(:existing_payload_staged_class) {
        FactoryGirl.create(
            :full_metasploit_cache_payload_staged_class,
            payload_stager_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      let(:payload_staged_class_persister) {
        described_class.new(
            ephemeral: double(
                'payload staged Metasploit Module class',
                ancestor_by_source: {
                    stage: double(
                        'payload stage Metasploit Module ancestor',
                        persister_by_source: {
                            ancestor: double(
                                'payload stage Metasploit::Cache::Module::Ancestor::Persister',
                                real_path_sha1_hex_digest: existing_payload_staged_class.payload_stage_instance.payload_stage_class.ancestor.real_path_sha1_hex_digest
                            )
                        }
                    ),
                    stager: double(
                        'payload stager Metasploit Module ancestor',
                        persister_by_source: {
                            ancestor: double(
                                'payload stager Metasploit::Cache::Module::Ancestor::Persister',
                                real_path_sha1_hex_digest: existing_payload_staged_class.payload_stager_instance.payload_stager_class.ancestor.real_path_sha1_hex_digest
                            )
                        }
                    )
                }
            )
        )
      }

      #
      # Callbacks
      #

      before(:each) do
        # create now that load_path is setup
        existing_payload_staged_class
      end

      it 'is an instance of Metasploit::Cache::Payload::Staged::Class' do
        expect(persistent).to be_a Metasploit::Cache::Payload::Staged::Class
      end

      context 'Metasploit::Cache::Payload::Staged::Class#payload_stage_instance' do
        subject(:payload_stage_instance) {
          persistent.payload_stage_instance
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
          persistent.payload_stager_instance
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

  context '#persist' do
    include_context 'ActiveSupport::TaggedLogging'
    include_context ':metasploit_cache_payload_handler_module'
    include_context 'Metasploit::Cache::Spec::Unload.unload'

    subject(:persist) do
      payload_staged_class_persister.persist(*args)
    end

    #
    # lets
    #

    let(:payload_staged_class_persister) {
      described_class.new(
          logger: logger,
          ephemeral: double(
              'payload staged Metasploit Module class',
              ancestor_by_source: {
                  stage: double(
                      'payload stage Metasploit Module ancestor',
                      persister_by_source: {
                          ancestor: Metasploit::Cache::Module::Ancestor::Persister.new(
                              real_path_sha1_hex_digest: payload_stage_ancestor.real_path_sha1_hex_digest
                          )
                      }
                  ),
                  stager: double(
                      'payload stage Metasploit Module ancestor',
                      persister_by_source: {
                          ancestor: Metasploit::Cache::Module::Ancestor::Persister.new(
                              real_path_sha1_hex_digest: payload_stager_ancestor.real_path_sha1_hex_digest
                          )
                      }
                  )
              }
          )
      )
    }

    context 'with :to' do
      #
      # lets
      #

      let(:args) {
        [
            {
                to: passed_payload_staged_class
            }
        ]
      }

      let(:passed_payload_staged_class) {
        FactoryGirl.build(
            :metasploit_cache_payload_staged_class,
            payload_stager_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      let(:payload_stage_ancestor) {
        passed_payload_staged_class.payload_stage_instance.payload_stage_class.ancestor
      }

      let(:payload_stager_ancestor) {
        passed_payload_staged_class.payload_stager_instance.payload_stager_class.ancestor
      }

      it 'does not access default #persistent' do
        expect(payload_staged_class_persister).not_to receive(:persistent)

        persist
      end

      it 'uses :to' do
        expect(passed_payload_staged_class).to receive(:batched_save).and_call_original

        persist
      end

      context 'batched save' do
        context 'failure' do
          #
          # Callbacks
          #

          before(:each) do
            passed_payload_staged_class.valid?

            expect(passed_payload_staged_class).to receive(:batched_save).and_return(false)
          end

          it 'tags log with Metasploit::Cache::Payload::Staged::Class#payload_stage_instance ' \
             'Metasploit::Cache::Payload::Stage::Instance#payload_stage_class ' \
             'Metasploit::Cache::Payload::Stage::Class#ancestor Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{payload_stage_ancestor.real_pathname.to_s}]")
          end

          it 'tags log with Metasploit::Cache::Payload::Staged::Class#payload_stager_instance ' \
             'Metasploit::Cache::Payload::Stager::Instance#payload_stager_class ' \
             'Metasploit::Cache::Payload::Stager::Class#ancestor Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(logger_string_io.string).to include("[#{payload_stager_ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            persist

            full_error_messages = passed_payload_staged_class.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(logger_string_io.string).to include("Could not be persisted to #{passed_payload_staged_class.class}: #{full_error_messages}")
          end
        end

        context 'success' do
          context 'with handler_type_alias' do
            let(:compatible_architectures) {
              [
                  FactoryGirl.generate(:metasploit_cache_architecture)
              ]
            }

            let(:compatible_platforms) {
              [
                  FactoryGirl.generate(:metasploit_cache_platform)
              ]
            }

            let(:passed_payload_staged_class) {
              FactoryGirl.build(
                  :metasploit_cache_payload_staged_class,
                  compatible_architectures: compatible_architectures,
                  compatible_platforms: compatible_platforms,
                  payload_stager_instance: payload_stager_instance
              )
            }

            let(:payload_stage_ancestor) {
              passed_payload_staged_class.payload_stage_instance.payload_stage_class.ancestor
            }

            let(:payload_stager_ancestor) {
              FactoryGirl.create(:full_metasploit_cache_payload_stager_ancestor)
            }

            let(:payload_stager_class) {
              FactoryGirl.create(
                  :metasploit_cache_payload_stager_class,
                  ancestor: payload_stager_ancestor
              )
            }

            let(:payload_stager_instance) {
              FactoryGirl.create(
                  :metasploit_cache_payload_stager_instance,
                  :metasploit_cache_contributable_contributions,
                  :metasploit_cache_licensable_licensable_licenses,
                  :metasploit_cache_payload_handable_handler,
                  # Hash arguments are overrides and available to all traits
                  architecturable_architectures: compatible_architectures.map { |compatible_architecture|
                    Metasploit::Cache::Architecturable::Architecture.new(
                        architecture: compatible_architecture
                    )
                  },
                  handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname,
                  payload_stager_class: payload_stager_class,
                  platformable_platforms: compatible_platforms.map { |compatible_platform|
                    Metasploit::Cache::Platformable::Platform.new(
                        platform: compatible_platform
                    )
                  }
              )
            }

            specify {
              expect {
                persist
              }.to change(Metasploit::Cache::Payload::Staged::Class, :count).by(1)
            }
          end

          context 'without handler_type_alias' do
            specify {
              expect {
                persist
              }.to change(Metasploit::Cache::Payload::Staged::Class, :count).by(1)
            }
          end
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

      let(:payload_stage_ancestor) {
        existing_payload_staged_class.payload_stage_instance.payload_stage_class.ancestor
      }

      let(:payload_stager_ancestor) {
        existing_payload_staged_class.payload_stager_instance.payload_stager_class.ancestor
      }

      #
      # let!s
      #

      let!(:existing_payload_staged_class) {
        FactoryGirl.create(
            :full_metasploit_cache_payload_staged_class,
            payload_stager_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        )
      }

      it 'defaults to #persistent' do
        expect(payload_staged_class_persister).to receive(:persistent).and_call_original

        persist
      end

      it 'uses #batched_save' do
        expect(payload_staged_class_persister.persistent).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end