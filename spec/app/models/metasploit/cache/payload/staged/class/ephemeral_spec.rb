RSpec.describe Metasploit::Cache::Payload::Staged::Class::Ephemeral do
  context 'resurrecting attributes' do
    context '#payload_staged_class' do
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      subject(:payload_staged_class) {
        payload_staged_class_ephemeral.payload_staged_class
      }

      #
      # lets
      #

      let(:existing_payload_staged_class) {
        FactoryGirl.create(
            :metasploit_cache_payload_staged_class,
            payload_stager_instance_handler_load_pathname: payload_stager_instance_handler_load_pathname
        )
      }

      let(:payload_staged_class_ephemeral) {
        described_class.new(
            payload_staged_metasploit_module_class: double(
                'payload staged Metasploit Module class',
                ancestor_by_source: {
                    stage: double(
                        'payload stage Metasploit Module ancestor',
                        ephemeral_cache_by_source: {
                            ancestor: double(
                                'payload stage Metasploit::Cache::Module::Ancestor::Ephemeral',
                                real_path_sha1_hex_digest: existing_payload_staged_class.payload_stage_instance.payload_stage_class.ancestor.real_path_sha1_hex_digest
                            )
                        }
                    ),
                    stager: double(
                        'payload stager Metasploit Module ancestor',
                        ephemeral_cache_by_source: {
                            ancestor: double(
                                'payload stager Metasploit::Cache::Module::Ancestor::Ephemeral',
                                real_path_sha1_hex_digest: existing_payload_staged_class.payload_stager_instance.payload_stager_class.ancestor.real_path_sha1_hex_digest
                            )
                        }
                    )
                }
            )
        )
      }

      let(:payload_stager_instance_handler_load_pathname) {
        Metasploit::Model::Spec.temporary_pathname.join('lib')
      }

      #
      # Callbacks
      #

      around(:each) do |example|
        load_path_before = $LOAD_PATH.dup

        begin
          example.run
        ensure
          $LOAD_PATH.replace(load_path_before)
        end
      end

      before(:each) do
        payload_stager_instance_handler_load_pathname.mkpath

        $LOAD_PATH.unshift payload_stager_instance_handler_load_pathname.to_path

        # create now that load_path is setup
        existing_payload_staged_class
      end

      it 'is an instance of Metasploit::Cache::Payload::Staged::Class' do
        expect(payload_staged_class).to be_a Metasploit::Cache::Payload::Staged::Class
      end

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

  context 'validations' do
    it { is_expected.to validate_presence_of(:logger) }
    it { is_expected.to validate_presence_of(:payload_staged_metasploit_module_class) }
  end

  context '#persist' do
    include_context 'Metasploit::Cache::Spec::Unload.unload'

    subject(:persist) do
      payload_staged_class_ephemeral.persist(*args)
    end

    #
    # lets
    #

    let(:logger) {
      ActiveSupport::TaggedLogging.new(
          Logger.new(string_io)
      )
    }

    let(:payload_staged_class_ephemeral) {
      described_class.new(
          logger: logger,
          payload_staged_metasploit_module_class: double(
              'payload staged Metasploit Module class',
              ancestor_by_source: {
                  stage: double(
                      'payload stage Metasploit Module ancestor',
                      ephemeral_cache_by_source: {
                          ancestor: Metasploit::Cache::Module::Ancestor::Ephemeral.new(
                              real_path_sha1_hex_digest: payload_stage_ancestor.real_path_sha1_hex_digest
                          )
                      }
                  ),
                  stager: double(
                      'payload stage Metasploit Module ancestor',
                      ephemeral_cache_by_source: {
                          ancestor: Metasploit::Cache::Module::Ancestor::Ephemeral.new(
                              real_path_sha1_hex_digest: payload_stager_ancestor.real_path_sha1_hex_digest
                          )
                      }
                  )
              }
          )
      )
    }

    let(:payload_stager_instance_handler_load_pathname) {
      Metasploit::Model::Spec.temporary_pathname.join('lib')
    }

    let(:string_io) {
      StringIO.new
    }

    #
    # Callbacks
    #

    around(:each) do |example|
      load_path_before = $LOAD_PATH.dup

      begin
        example.run
      ensure
        $LOAD_PATH.replace(load_path_before)
      end
    end

    before(:each) do
      payload_stager_instance_handler_load_pathname.mkpath

      $LOAD_PATH.unshift payload_stager_instance_handler_load_pathname.to_path
    end

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
            payload_stager_instance_handler_load_pathname: payload_stager_instance_handler_load_pathname
        )
      }

      let(:payload_stage_ancestor) {
        passed_payload_staged_class.payload_stage_instance.payload_stage_class.ancestor
      }

      let(:payload_stager_ancestor) {
        passed_payload_staged_class.payload_stager_instance.payload_stager_class.ancestor
      }

      it 'does not access default #payload_staged_class' do
        expect(payload_staged_class_ephemeral).not_to receive(:payload_staged_class)

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

            expect(string_io.string).to include("[#{payload_stage_ancestor.real_pathname.to_s}]")
          end

          it 'tags log with Metasploit::Cache::Payload::Staged::Class#payload_stager_instance ' \
             'Metasploit::Cache::Payload::Stager::Instance#payload_stager_class ' \
             'Metasploit::Cache::Payload::Stager::Class#ancestor Metasploit::Cache::Module::Ancestor#real_path' do
            persist

            expect(string_io.string).to include("[#{payload_stager_ancestor.real_pathname.to_s}]")
          end

          it 'logs validation errors' do
            # Right now, there are no validation errors because there are no attributes on
            # Metasploit::Cache::Payload::Staged::Class and the associations are already set.
            expect(passed_payload_staged_class.errors.full_messages.to_sentence).to be_blank

            # ... so, fake some validation errors
            passed_payload_staged_class.errors.add(:base, :invalid)

            persist

            full_error_messages = passed_payload_staged_class.errors.full_messages.to_sentence

            expect(full_error_messages).not_to be_blank
            expect(string_io.string).to include("Could not be persisted to #{passed_payload_staged_class.class}: #{full_error_messages}")
          end
        end

        context 'success' do
          specify {
            expect {
              persist
            }.to change(Metasploit::Cache::Payload::Staged::Class, :count).by(1)
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
            :metasploit_cache_payload_staged_class,
            payload_stager_instance_handler_load_pathname: payload_stager_instance_handler_load_pathname
        )
      }

      it 'defaults to #payload_staged_class' do
        expect(payload_staged_class_ephemeral).to receive(:payload_staged_class).and_call_original

        persist
      end

      it 'uses #batched_save' do
        expect(payload_staged_class_ephemeral.payload_staged_class).to receive(:batched_save).and_call_original

        persist
      end
    end
  end
end