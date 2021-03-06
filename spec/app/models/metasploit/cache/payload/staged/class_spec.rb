RSpec.describe Metasploit::Cache::Payload::Staged::Class, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'association' do
    it { is_expected.to belong_to(:payload_stage_instance).class_name('Metasploit::Cache::Payload::Stage::Instance').inverse_of(:payload_staged_classes) }
    it { is_expected.to have_one(:payload_staged_instance).class_name('Metasploit::Cache::Payload::Staged::Instance').dependent(:destroy).inverse_of(:payload_staged_class).with_foreign_key(:payload_staged_class_id) }
    it { is_expected.to belong_to(:payload_stager_instance).class_name('Metasploit::Cache::Payload::Stager::Instance').inverse_of(:payload_staged_classes) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:payload_stage_instance_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:payload_stager_instance_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:payload_stage_instance_id).unique(false) }
      it { is_expected.to have_db_index(:payload_stager_instance_id).unique(false) }
      it { is_expected.to have_db_index([:payload_stager_instance_id, :payload_stage_instance_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'full_metasploit_cache_payload_staged_class' do
      context 'with :payload_stager_instance_handler_load_pathname' do
        include_context 'ActiveSupport::TaggedLogging'
        include_context ':metasploit_cache_payload_handler_module'
        include_context 'Metasploit::Cache::Spec::Unload.unload'

        #
        # lets
        #

        let(:metasploit_framework) {
          double('Metasploit Framework')
        }

        let(:payload_stage_ancestor) {
          payload_stage_class.ancestor
        }

        let(:payload_stage_ancestor_load) {
          Metasploit::Cache::Module::Ancestor::Load.new(
              logger: logger,
              # This should match the major version number of metasploit-framework
              maximum_version: 4,
              module_ancestor: payload_stage_ancestor,
              persister_class: Metasploit::Cache::Module::Ancestor::Persister
          )
        }

        let(:payload_stage_class) {
          payload_stage_instance.payload_stage_class
        }

        let(:payload_stage_class_load) {
          Metasploit::Cache::Payload::Unhandled::Class::Load.new(
              logger: logger,
              metasploit_module: payload_stage_ancestor_load.metasploit_module,
              payload_unhandled_class: payload_stage_class,
              payload_superclass: Metasploit::Cache::Direct::Class::Superclass
          )
        }

        let(:payload_stage_instance) {
          full_metasploit_cache_payload_staged_class.payload_stage_instance
        }

        let(:payload_stage_instance_load) {
          Metasploit::Cache::Module::Instance::Load.new(
              persister_class: Metasploit::Cache::Payload::Stage::Instance::Persister,
              logger: logger,
              metasploit_framework: metasploit_framework,
              metasploit_module_class: payload_stage_class_load.metasploit_class,
              module_instance: payload_stage_instance
          )
        }

        let(:payload_staged_class_load) {
          Metasploit::Cache::Payload::Staged::Class::Load.new(
              handler_module: payload_stager_instance_load.metasploit_module_instance.handler_klass,
              logger: logger,
              payload_stage_metasploit_module: payload_stage_ancestor_load.metasploit_module,
              payload_staged_class: full_metasploit_cache_payload_staged_class,
              payload_stager_metasploit_module: payload_stager_ancestor_load.metasploit_module,
              payload_superclass: Metasploit::Cache::Direct::Class::Superclass
          )
        }

        let(:payload_stager_ancestor) {
          payload_stager_class.ancestor
        }

        let(:payload_stager_ancestor_load) {
          Metasploit::Cache::Module::Ancestor::Load.new(
              logger: logger,
              # This should match the major version number of metasploit-framework
              maximum_version: 4,
              module_ancestor: payload_stager_ancestor,
              persister_class: Metasploit::Cache::Module::Ancestor::Persister
          )
        }

        let(:payload_stager_class) {
          payload_stager_instance.payload_stager_class
        }

        let(:payload_stager_class_load) {
          Metasploit::Cache::Payload::Unhandled::Class::Load.new(
              logger: logger,
              metasploit_module: payload_stager_ancestor_load.metasploit_module,
              payload_unhandled_class: payload_stager_class,
              payload_superclass: Metasploit::Cache::Direct::Class::Superclass
          )
        }

        let(:payload_stager_instance) {
          full_metasploit_cache_payload_staged_class.payload_stager_instance
        }

        let(:payload_stager_instance_handler_load_pathname) {
          Metasploit::Model::Spec.temporary_pathname.join('lib')
        }

        let(:payload_stager_instance_load) {
          Metasploit::Cache::Module::Instance::Load.new(
              persister_class: Metasploit::Cache::Payload::Stager::Instance::Persister,
              logger: logger,
              metasploit_framework: metasploit_framework,
              metasploit_module_class: payload_stager_class_load.metasploit_class,
              module_instance: payload_stager_instance
          )
        }

        context 'with payload stager handler_type_alias' do
          subject(:full_metasploit_cache_payload_staged_class) {
            FactoryGirl.build(
                :full_metasploit_cache_payload_staged_class,
                compatible_architectures: compatible_architectures,
                compatible_platforms: compatible_platforms,
                payload_stager_instance: FactoryGirl.create(
                    :metasploit_cache_payload_stager_instance,
                    :metasploit_cache_contributable_contributions,
                    :metasploit_cache_licensable_licensable_licenses,
                    :metasploit_cache_payload_handable_handler,
                    # Must be after all association building traits so assocations are populated for writing contents
                    :metasploit_cache_payload_stager_instance_payload_stager_class_ancestor_contents,
                    # Hash arguments are overrides and available to all traits
                    architecturable_architectures: compatible_architectures.map { |compatible_architecture|
                      Metasploit::Cache::Architecturable::Architecture.new(
                          architecture: compatible_architecture
                      )
                    },
                    handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname,
                    payload_stager_class: FactoryGirl.create(
                        :metasploit_cache_payload_stager_class,
                        ancestor: FactoryGirl.create(
                            :metasploit_cache_payload_stager_ancestor,
                            handler: FactoryGirl.build(
                                :metasploit_cache_payload_stager_ancestor_handler,
                                type_alias: handler_type_alias
                            )
                        )
                    ),
                    platformable_platforms: compatible_platforms.map { |compatible_platform|
                      Metasploit::Cache::Platformable::Platform.new(
                          platform: compatible_platform
                      )
                    }
                )
            )
          }

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

          let(:handler_type_alias) {
            FactoryGirl.generate :metasploit_cache_payload_stager_ancestor_handler_type_alias
          }

          it { is_expected.to be_valid }

          it 'is loadable' do
            expect(payload_staged_class_load).to be_valid
          end

          it 'uses handler_type_alias in name' do
            payload_staged_class_load

            expect(full_metasploit_cache_payload_staged_class.name.reference).to include(handler_type_alias)
          end

          context 'Metasploit::Cache::Payload::Staged::Class#payload_stage_instance' do
            it 'is loadable' do
              expect(payload_stage_instance_load).to be_valid
            end

            context 'Metasploit::Cache::Payload::Stage::Instance#payload_stage_class' do
              it 'is loadable' do
                expect(payload_stage_class_load).to be_valid
              end

              context 'Metasploit::Cache::Payload::Stage::Class#ancestor' do
                it 'is loadable' do
                  expect(payload_stage_ancestor_load).to be_valid
                end
              end
            end
          end

          context 'Metasploit::Cache::Payload::Staged::Class#payload_stager_instance' do
            it 'is loadable' do
              expect(payload_stager_instance_load).to be_valid
            end

            context 'Metasploit::Cache::Payload::Stager::Instance#payload_stager_class' do
              it 'is loadable' do
                expect(payload_stager_class_load).to be_valid
              end

              context 'Metasploit::Cache::Payload::Stager::Class#ancestor' do
                it 'is loadable' do
                  expect(payload_stager_ancestor_load).to be_valid
                end
              end
            end
          end
        end

        context 'without payload stager handler_type_alias' do
          subject(:full_metasploit_cache_payload_staged_class) {
            FactoryGirl.build(
                :full_metasploit_cache_payload_staged_class,
                payload_stager_instance_handler_load_pathname: payload_stager_instance_handler_load_pathname
            )
          }

          it { is_expected.to be_valid }

          it 'is loadable' do
            expect(payload_staged_class_load).to be_valid
          end

          context 'Metasploit::Cache::Payload::Staged::Class#payload_stage_instance' do
            it 'is loadable' do
              expect(payload_stage_instance_load).to be_valid
            end

            context 'Metasploit::Cache::Payload::Stage::Instance#payload_stage_class' do
              it 'is loadable' do
                expect(payload_stage_class_load).to be_valid
              end

              context 'Metasploit::Cache::Payload::Stage::Class#ancestor' do
                it 'is loadable' do
                  expect(payload_stage_ancestor_load).to be_valid
                end
              end
            end
          end

          context 'Metasploit::Cache::Payload::Staged::Class#payload_stager_instance' do
            it 'is loadable' do
              expect(payload_stager_instance_load).to be_valid
            end

            context 'Metasploit::Cache::Payload::Stager::Instance#payload_stager_class' do
              it 'is loadable' do
                expect(payload_stager_class_load).to be_valid
              end

              context 'Metasploit::Cache::Payload::Stager::Class#ancestor' do
                it 'is loadable' do
                  expect(payload_stager_ancestor_load).to be_valid
                end
              end
            end
          end
        end
      end
    end

    context 'metasploit_cache_payload_staged_class' do
      context 'with :payload_stager_instance_handler_load_pathname' do
        include_context ':metasploit_cache_payload_handler_module'

        subject(:metasploit_cache_payload_staged_class) {
          FactoryGirl.build(
              :metasploit_cache_payload_staged_class,
              payload_stager_instance_handler_load_pathname: payload_stager_instance_handler_load_pathname
          )
        }

        let(:payload_stager_instance_handler_load_pathname) {
          Metasploit::Model::Spec.temporary_pathname.join('lib')
        }

        it { is_expected.not_to be_valid }

        context 'Metasploit::Cache::Payload::Staged::Class#name' do
          subject(:name) {
            metasploit_cache_payload_staged_class.name
          }

          it { is_expected.to be_nil }
        end
      end

      context 'without :payload_stager_instance_handler_load_pathname' do
        subject(:metasploit_cache_payload_staged_class) {
          FactoryGirl.build(:metasploit_cache_payload_staged_class)
        }

        specify {
          expect {
            metasploit_cache_payload_staged_class
          }.to raise_error(
                   ArgumentError,
                   ':payload_stager_instance_handler_load_pathname must be set for ' \
                   ':metasploit_cache_payload_staged_class so it can set :handler_load_pathname for ' \
                   ':metasploit_cache_payload_handable_handler trait so it can set :load_pathname for ' \
                   ':metasploit_cache_payload_handler_module trait'
               )
        }
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :payload_stage_instance }
    it { is_expected.to validate_presence_of :payload_stager_instance }

    context 'validates compatible architectures' do
      include_context ':metasploit_cache_payload_handler_module'
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      subject(:base_errors) {
        payload_staged_class.errors[:base]
      }

      let(:error) {
        I18n.translate!('activerecord.errors.models.metasploit/cache/payload/staged/class.incompatible_architectures')
      }

      let(:payload_staged_class) {
        FactoryGirl.build(
            :metasploit_cache_payload_staged_class,
            payload_stage_instance: payload_stage_instance,
            payload_stager_instance: payload_stager_instance
        )
      }

      let(:payload_stage_instance) {
        FactoryGirl.build(
            :metasploit_cache_payload_stage_instance,
            :metasploit_cache_contributable_contributions,
            :metasploit_cache_licensable_licensable_licenses,
            :metasploit_cache_platformable_platformable_platforms
        ).tap { |payload_stage_instance|
          payload_stage_instance.architecturable_architectures << Metasploit::Cache::Architecturable::Architecture.new(
              architecturable: payload_stage_instance,
              architecture: first_stage_architecture
          )

          payload_stage_instance.architecturable_architectures << Metasploit::Cache::Architecturable::Architecture.new(
              architecturable: payload_stage_instance,
              architecture: second_stage_architecture
          )
        }
      }

      let(:payload_stager_instance) {
        FactoryGirl.build(
            :metasploit_cache_payload_stager_instance,
            :metasploit_cache_contributable_contributions,
            :metasploit_cache_licensable_licensable_licenses,
            :metasploit_cache_payload_handable_handler,
            :metasploit_cache_platformable_platformable_platforms,
            handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
        ).tap { |payload_stager_instance|
          payload_stager_instance.architecturable_architectures << Metasploit::Cache::Architecturable::Architecture.new(
              architecturable: payload_stager_instance,
              architecture: first_stager_architecture
          )
          payload_stager_instance.architecturable_architectures << Metasploit::Cache::Architecturable::Architecture.new(
              architecturable: payload_stager_instance,
              architecture: second_stager_architecture
          )
        }
      }

      context 'with intersecting architectures' do
        #
        # lets
        #

        let(:first_stage_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'armbe').first
        }

        let(:first_stager_architecture) {
          first_stage_architecture
        }

        let(:second_stage_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'armle').first
        }

        let(:second_stager_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'cbea').first
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.not_to include error }
      end

      context 'without intersecting architectures' do
        #
        # lets
        #

        let(:first_stage_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'armbe').first
        }

        let(:first_stager_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'cbea').first
        }

        let(:second_stage_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'armle').first
        }

        let(:second_stager_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'cbea64').first
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.to include error }
      end
    end

    context 'validates compatible platforms' do
      include_context ':metasploit_cache_payload_handler_module'
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      subject(:base_errors) {
        payload_staged_class.errors[:base]
      }

      let(:error) {
        I18n.translate!('activerecord.errors.models.metasploit/cache/payload/staged/class.incompatible_platforms')
      }

      let(:payload_staged_class) {
        FactoryGirl.build(
            :metasploit_cache_payload_staged_class,
            payload_stage_instance: payload_stage_instance,
            payload_stager_instance: payload_stager_instance
        )
      }

      let(:payload_stage_instance) {
        FactoryGirl.build(
            :metasploit_cache_payload_stage_instance,
            :metasploit_cache_architecturable_architecturable_architectures,
            :metasploit_cache_contributable_contributions,
            :metasploit_cache_licensable_licensable_licenses
        ).tap { |payload_stage_instance|
          payload_stage_instance.platformable_platforms << Metasploit::Cache::Platformable::Platform.new(
              platformable: payload_stage_instance,
              platform: stage_platform
          )
        }
      }

      let(:payload_stager_instance) {
        FactoryGirl.build(
            :metasploit_cache_payload_stager_instance,
            :metasploit_cache_architecturable_architecturable_architectures,
            :metasploit_cache_contributable_contributions,
            :metasploit_cache_licensable_licensable_licenses,
            :metasploit_cache_payload_handable_handler,
            handler_load_pathname: payload_stager_instance_handler_load_pathname
        ).tap { |payload_stager_instance|
          payload_stager_instance.platformable_platforms << Metasploit::Cache::Platformable::Platform.new(
              platformable: payload_stager_instance,
              platform: stager_platform
          )
        }
      }

      let(:payload_stager_instance_handler_load_pathname) {
        Metasploit::Model::Spec.temporary_pathname.join('lib')
      }

      context 'with same platform' do
        #
        # lets
        #

        let(:stage_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'AIX').first
        }

        let(:stager_platform) {
          stage_platform
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.not_to include error }
      end

      context 'with stage platform a child of stager platform' do
        let(:stage_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows 95').first
        }

        let(:stager_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows').first
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.not_to include error }
      end

      context 'with stager platform a child of stage platform' do
        let(:stage_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows').first
        }

        let(:stager_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows 95').first
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.not_to include error }
      end

      context 'without intersecting platforms' do
        let(:stage_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows 95').first
        }

        let(:stager_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows 98').first
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.to include error }
      end
    end

    context 'existing record' do
      include_context ':metasploit_cache_payload_handler_module'
      include_context 'Metasploit::Cache::Spec::Unload.unload'

      #
      # lets
      #

      let(:payload_stager_instance_handler_load_pathname) {
        Metasploit::Model::Spec.temporary_pathname.join('lib')
      }

      #
      # Callbacks
      #

      before(:each) do
        FactoryGirl.create(
            :full_metasploit_cache_payload_staged_class,
            payload_stager_instance_handler_load_pathname: payload_stager_instance_handler_load_pathname
        )
      end

      it { is_expected.to validate_uniqueness_of(:payload_stage_instance_id).scoped_to(:payload_stager_instance_id) }
    end
  end

  context 'compatible?' do
    include_context ':metasploit_cache_payload_handler_module'

    subject(:compatible?) {
      payload_staged_class.compatible?
    }

    let(:payload_staged_class) {
      FactoryGirl.build(
          :full_metasploit_cache_payload_staged_class,
          payload_stage_instance: FactoryGirl.create(
              :metasploit_cache_payload_stage_instance,
              :metasploit_cache_contributable_contributions,
              :metasploit_cache_licensable_licensable_licenses,
              # Must be after all association building traits so assocations are populated for writing contents
              :metasploit_cache_payload_stage_instance_payload_stage_class_ancestor_contents,
              # Hash arguments are overrides and available to all traits
              architecturable_architectures: stage_architectures.map { |architecture|
                Metasploit::Cache::Architecturable::Architecture.new(
                    architecture: architecture
                )
              },
              platformable_platforms: stage_platforms.map { |platform|
                Metasploit::Cache::Platformable::Platform.new(
                    platform: platform
                )
              }
          ),
          payload_stager_instance: FactoryGirl.create(
              :metasploit_cache_payload_stager_instance,
              :metasploit_cache_contributable_contributions,
              :metasploit_cache_licensable_licensable_licenses,
              :metasploit_cache_payload_handable_handler,
              # Must be after all association building traits so assocations are populated for writing contents
              :metasploit_cache_payload_stager_instance_payload_stager_class_ancestor_contents,
              # Hash arguments are overrides and available to all traits
              architecturable_architectures: stager_architectures.map { |architecture|
                Metasploit::Cache::Architecturable::Architecture.new(
                    architecture: architecture
                )
              },
              handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname,
              platformable_platforms: stager_platforms.map { |platform|
                Metasploit::Cache::Platformable::Platform.new(
                    platform: platform
                )
              }
          )
      )
    }

    context 'with compatible architectures' do
      let(:stage_architectures) {
        [
            FactoryGirl.generate(:metasploit_cache_architecture)
        ]
      }

      let(:stager_architectures) {
        stage_architectures
      }

      context 'with compatible platforms' do
        let(:stage_platforms) {
          [
              Metasploit::Cache::Platform.find_by!(fully_qualified_name: 'Windows')
          ]
        }

        let(:stager_platforms) {
          [
              Metasploit::Cache::Platform.find_by!(fully_qualified_name: 'Windows XP')
          ]
        }

        it { is_expected.to eq(true) }
      end

      context 'without compatible platforms' do
        let(:stage_platforms) {
          [
              Metasploit::Cache::Platform.find_by!(fully_qualified_name: 'Windows')
          ]
        }

        let(:stager_platforms) {
          [
              Metasploit::Cache::Platform.find_by!(fully_qualified_name: 'Linux')
          ]
        }

        it { is_expected.to eq(false) }
      end
    end

    context 'without compatible architectures' do
      let(:stage_architectures) {
        [
            Metasploit::Cache::Architecture.find_by!(abbreviation: 'x86')
        ]
      }

      let(:stager_architectures) {
        [
            Metasploit::Cache::Architecture.find_by!(abbreviation: 'mipsle')
        ]
      }

      context 'with compatible platforms' do
        let(:stage_platforms) {
          [
              Metasploit::Cache::Platform.find_by!(fully_qualified_name: 'Windows')
          ]
        }

        let(:stager_platforms) {
          [
              Metasploit::Cache::Platform.find_by!(fully_qualified_name: 'Windows XP')
          ]
        }

        it { is_expected.to eq(false) }
      end

      context 'without compatible platforms' do
        let(:stage_platforms) {
          [
              Metasploit::Cache::Platform.find_by!(fully_qualified_name: 'Windows')
          ]
        }

        let(:stager_platforms) {
          [
              Metasploit::Cache::Platform.find_by!(fully_qualified_name: 'Linux')
          ]
        }

        it { is_expected.to eq(false) }
      end
    end
  end
end