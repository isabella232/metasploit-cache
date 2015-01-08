require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Instance do
  #
  # Shared contexts
  #

  shared_context 'platforms' do
    #
    # lets
    #

    let(:platform) do
      Metasploit::Cache::Platform.where(fully_qualified_name: platform_fully_qualified_name).first
    end

    let(:platform_fully_qualified_name) do
      'Windows XP'
    end

    let(:other_module_class) do
      FactoryGirl.create(
          :metasploit_cache_module_class,
          module_type: other_module_type
      )
    end

    let(:other_module_type) do
      'payload'
    end

    let(:other_platform) do
      Metasploit::Cache::Platform.where(fully_qualified_name: other_platform_fully_qualified_name).first
    end

    #
    # let!s
    #

    let!(:other_module_instance) do
      FactoryGirl.build(
          :metasploit_cache_module_instance,
          module_class: other_module_class,
          module_platforms_length: 0
      ).tap { |module_instance|
        module_instance.module_platforms.build(
            {
                platform: other_platform
            },
            {
                without_protection: true
            }
        )
        module_instance.save!
      }
    end
  end

  #
  # Shared Examples
  #

  shared_examples_for 'intersecting platforms' do
    context 'with same platform' do
      let(:other_platform) do
        platform
      end

      it 'includes the Metasploit::Cache::Module::Instance' do
        expect(subject).to include(other_module_instance)
      end
    end

    context 'with ancestor platform' do
      let(:other_platform_fully_qualified_name) do
        'Windows'
      end

      it 'includes the Metasploit::Cache::Module::Instance' do
        expect(subject).to include(other_module_instance)
      end
    end

    context 'with descendant platform' do
      let(:other_platform_fully_qualified_name) do
        'Windows XP SP1'
      end

      it 'includes the Metasploit::Cache::Module::Instance' do
        expect(subject).to include(other_module_instance)
      end
    end

    context 'with cousin platform' do
      let(:other_platform_fully_qualified_name) do
        'Windows XP SP1'
      end

      let(:platform_fully_qualified_name) do
        'Windows 2000 SP1'
      end

      it 'does not include Metasploit::Cache::Module::Instance' do
        expect(subject).not_to include(other_module_instance)
      end
    end

    context 'with unrelated platform' do
      let(:other_platform_fully_qualified_name) do
        'UNIX'
      end

      it 'does not include Metasploit::Cache::Module::Instance' do
        expect(subject).not_to include(other_module_instance)
      end
    end
  end

  subject(:module_instance) do
    FactoryGirl.build(:metasploit_cache_module_instance)
  end

  it_should_behave_like 'Metasploit::Cache::Module::Instance',
                        namespace_name: 'Metasploit::Cache'

  it_should_behave_like 'Metasploit::Cache::Module::Instance::ClassMethods' do
    let(:singleton_class) do
      described_class
    end
  end

  context 'associations' do
    it { should have_many(:actions).class_name('Metasploit::Cache::Module::Action').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:architectures).class_name('Metasploit::Cache::Architecture').through(:module_architectures) }
    it { should have_many(:authors).class_name('Metasploit::Cache::Author').through(:module_authors) }
    it { should have_many(:authorities).class_name('Metasploit::Cache::Authority').through(:references) }
    it { should belong_to(:default_action).class_name('Metasploit::Cache::Module::Action') }
    it { should belong_to(:default_target).class_name('Metasploit::Cache::Module::Target') }
    it { should have_many(:email_addresses).class_name('Metasploit::Cache::EmailAddress').through(:module_authors) }
    it { should have_many(:module_architectures).class_name('Metasploit::Cache::Module::Architecture').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:module_authors).class_name('Metasploit::Cache::Module::Author').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should belong_to(:module_class).class_name('Metasploit::Cache::Module::Class') }
    it { should have_many(:module_platforms).class_name('Metasploit::Cache::Module::Platform').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:module_references).class_name('Metasploit::Cache::Module::Reference').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:platforms).class_name('Metasploit::Cache::Platform').through(:module_platforms) }
    it { should have_one(:rank).class_name('Metasploit::Cache::Module::Rank').through(:module_class) }
    it { should have_many(:references).class_name('Metasploit::Cache::Reference').through(:module_references) }
    it { should have_many(:targets).class_name('Metasploit::Cache::Module::Target').dependent(:destroy).with_foreign_key(:module_instance_id) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:default_action_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:default_target_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:description).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:disclosed_on).of_type(:date).with_options(:null => true) }
      it { should have_db_column(:license).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:module_class_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:privileged).of_type(:boolean).with_options(:null => false) }
      it { should have_db_column(:stance).of_type(:string).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index(:default_action_id).unique(true) }
      it { should have_db_index(:default_target_id).unique(true) }
      it { should have_db_index(:module_class_id).unique(true) }
    end
  end

  context 'scopes' do
    context 'compatible_privilege_with' do
      subject(:compatible_privilege_with) do
        described_class.compatible_privilege_with(module_instance)
      end

      #
      # let!s
      #

      let!(:module_instance) do
        FactoryGirl.create(
            :metasploit_cache_module_instance,
            privileged: privilege
        )
      end

      let!(:privileged) do
        FactoryGirl.create(
            :metasploit_cache_module_instance,
            privileged: true
        )
      end

      let!(:unprivileged) do
        FactoryGirl.create(
            :metasploit_cache_module_instance,
            privileged: false
        )
      end

      context 'with privileged' do
        let(:privilege) do
          true
        end

        it 'includes privileged Metasploit::Cache::Module::Instances' do
          expect(compatible_privilege_with).to include(privileged)
        end

        it 'includes unprivileged Metasploit::Cache::Module::Instances' do
          expect(compatible_privilege_with).to include(unprivileged)
        end
      end

      context 'without privileged' do
        let(:privilege) do
          false
        end

        it 'does not include privileged Metasploit::Cache::Module::Instances' do
          expect(compatible_privilege_with).not_to include(privileged)
        end

        it 'includes unprivileged Metasploit::Cache::Module::Instances' do
          expect(compatible_privilege_with).to include(unprivileged)
        end
      end
    end

    context 'intersecting_architecture_abbreviations' do
      subject(:intersecting_architecture_abbreviations) do
        described_class.intersecting_architecture_abbreviations(architecture_abbreviation)
      end

      let(:other_architecture) do
        Metasploit::Cache::Architecture.where(abbreviation: other_architecture_abbreviation).first
      end

      let(:architecture_abbreviation) do
        FactoryGirl.generate :metasploit_cache_architecture_abbreviation
      end

      let(:other_module_class) do
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'payload'
        )
      end

      #
      # let!s
      #

      let!(:other_module_instance) do
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            module_architectures_length: 0,
            module_class: other_module_class
        ).tap { |module_instance|
          module_architecture = module_instance.module_architectures.build
          module_architecture.architecture = other_architecture

          module_instance.save!
        }
      end

      context 'with intersection' do
        #
        # lets
        #

        let(:other_architecture_abbreviation) do
          architecture_abbreviation
        end

        it 'includes the Metasploit::Cache::Module::Instance' do
          expect(intersecting_architecture_abbreviations).to include(other_module_instance)
        end
      end

      context 'without intersection' do
        let(:other_architecture_abbreviation) do
          FactoryGirl.generate :metasploit_cache_architecture_abbreviation
        end

        it 'does not include the Metasploit::Cache::Module::Instance' do
          expect(intersecting_architecture_abbreviations).not_to include(other_module_instance)
        end
      end
    end

    context 'intersecting_architectures_with' do
      subject(:intersecting_architectures_with) do
        described_class.intersecting_architectures_with(architectured)
      end

      context 'with Metasploit::Cache::Module::Instance' do
        let(:architectured) do
          FactoryGirl.create(
              :metasploit_cache_module_instance,
              module_class: module_class
          )
        end

        let(:module_class) do
          FactoryGirl.create(
              :metasploit_cache_module_class,
              module_type: 'payload'
          )
        end

        it 'selects abbreviation from Metasploit::Cache::Module::Instance#architectures' do
          expect(architectured.architectures).to receive(:select).with(:abbreviation).and_call_original

          intersecting_architectures_with
        end

        it 'calls intersecting_architecture_abbreviations with Arel::SelectManager' do
          expect(described_class).to receive(:intersecting_architecture_abbreviations).with(
                                         an_instance_of(Arel::SelectManager)
                                     )

          intersecting_architectures_with
        end
      end

      context 'with Metasploit::Cache::Module::Target' do
        #
        # lets
        #

        let(:architecture) do
          FactoryGirl.generate :metasploit_cache_architecture
        end

        let(:other_module_class) do
          FactoryGirl.create(
              :metasploit_cache_module_class,
              module_type: 'payload'
          )
        end

        let(:other_architecture) do
          FactoryGirl.generate :metasploit_cache_architecture
        end

        #
        # let!s
        #

        let!(:architectured) do
          FactoryGirl.build(
              :metasploit_cache_module_target,
              target_architectures_length: 0
          ).tap { |module_target|
            target_architecture = module_target.target_architectures.build
            target_architecture.architecture = architecture

            module_instance = module_target.module_instance
            module_architecture = module_instance.module_architectures.build
            module_architecture.architecture = architecture

            module_target.save!
          }
        end

        let!(:other_module_instance) do
          FactoryGirl.build(
              :metasploit_cache_module_instance,
              module_architectures_length: 0,
              module_class: other_module_class
          ).tap { |module_instance|
            module_architecture = module_instance.module_architectures.build
            module_architecture.architecture = other_architecture

            module_instance.save!
          }
        end

        it 'selects abbreviation from Metasploit::Cache::Module::Target#architectures' do
          expect(architectured.architectures).to receive(:select).with(:abbreviation).and_call_original

          intersecting_architectures_with
        end

        it 'calls intersecting_architecture_abbreviations with Arel::SelectManager to perform a subselect' do
          expect(described_class).to receive(:intersecting_architecture_abbreviations).with(
                                         an_instance_of(Arel::SelectManager)
                                     ).and_call_original

          intersecting_architectures_with
        end

        context 'with intersection' do
          let(:other_architecture) do
            architecture
          end

          it 'includes the Metasploit::Cache::Module::Instance' do
            expect(intersecting_architectures_with).to include(other_module_instance)
          end
        end

        context 'without intersection' do
          let(:other_architecture) do
            FactoryGirl.generate :metasploit_cache_architecture
          end

          it 'does not include the Metasploit::Cache::Module::Instance' do
            expect(intersecting_architectures_with).not_to include(other_module_instance)
          end
        end
      end
    end

    context 'intersecting_platforms' do
      include_context 'platforms'

      subject(:intersecting_platforms) do
        described_class.intersecting_platforms(platforms)
      end

      let(:platforms) do
        [
            platform
        ]
      end

      it_should_behave_like 'intersecting platforms'
    end

    context 'intersecting_platform_fully_qualified_names' do
      include_context 'platforms'

      subject(:intersecting_platform_fully_qualified_names) do
        described_class.intersecting_platform_fully_qualified_names(platform_fully_qualified_names)
      end

      let(:other_platform_fully_qualified_name) do
        platform_fully_qualified_name
      end

      let(:platform_fully_qualified_names) do
        platform_fully_qualified_name
      end

      it_should_behave_like 'intersecting platforms'

      it 'calls intersecting_platforms with ActiveRecord::Relation<Metasploit::Cache::Platform>' do
        expect(described_class).to receive(:intersecting_platforms).with(an_instance_of(ActiveRecord::Relation))

        intersecting_platform_fully_qualified_names
      end

      it 'calls intersecting_platforms with Metasploit::Cache::Platforms with platform_fully_qualified_names' do
        expect(described_class).to receive(:intersecting_platforms) { |platforms|
          expect(platforms).to match_array([platform])
        }.and_call_original

        intersecting_platform_fully_qualified_names
      end
    end

    context 'intersecting_platforms_with' do
      include_context 'platforms'

      subject(:intersecting_platforms_with) do
        described_class.intersecting_platforms_with(module_target)
      end

      let(:module_target) do
        FactoryGirl.build(
            :metasploit_cache_module_target,
            target_platforms_length: 0
        ).tap { |module_target|
          module_target.target_platforms.build(
              {
                  platform: platform
              },
              {
                  without_protection: true
              }
          )

          module_target.module_instance.module_platforms.build(
              {
                  platform: platform
              },
              {
                  without_protection: true
              }
          )

          module_target.save!
        }
      end

      let(:other_platform_fully_qualified_name) do
        platform_fully_qualified_name
      end

      it_should_behave_like 'intersecting platforms'

      it 'calls #intersecting_platforms with module_target.platforms' do
        expect(described_class).to receive(:intersecting_platforms) { |platforms|
          expect(platforms).to match_array(module_target.platforms)
        }.and_call_original

        intersecting_platforms_with
      end
    end

    context 'payloads_compatible_with' do
      subject(:payloads_compatible_with) do
        described_class.payloads_compatible_with(module_target)
      end

      #
      # lets
      #

      let(:architecture) do
        FactoryGirl.generate :metasploit_cache_architecture
      end

      let(:module_target) do
        FactoryGirl.build(
            :metasploit_cache_module_target,
            target_architectures_length: 0,
            target_platforms_length: 0
        ).tap { |module_target|
          module_target.target_architectures.build(
              {
                  architecture: architecture
              },
              {
                  without_protection: true
              }
          )

          module_target.module_instance.module_architectures.build(
              {
                  architecture: architecture
              },
              {
                  without_protection: true
              }
          )

          module_target.target_platforms.build(
              {
                  platform: platform
              },
              {
                  without_protection: true
              }
          )

          module_target.module_instance.module_platforms.build(
              {
                  platform: platform
              },
              {
                  without_protection: true
              }
          )
        }
      end

      let(:platform) do
        Metasploit::Cache::Platform.where(fully_qualified_name: platform_fully_qualified_name).first
      end

      let(:platform_fully_qualified_name) do
        'Windows XP'
      end

      #
      # Callbacks
      #

      before(:each) do
        module_target.save!
      end

      it "calls with_module_type('payload')" do
        expect(described_class).to receive(:with_module_type).with('payload').and_call_original

        payloads_compatible_with
      end

      it 'calls compatible_privilege_with on the module_target.module_instance' do
        expect(described_class).to receive(:compatible_privilege_with).with(module_target.module_instance).and_call_original

        payloads_compatible_with
      end

      it 'calls intersecting_architectures_with on the module_target' do
        expect(described_class).to receive(:intersecting_architectures_with).with(module_target).and_call_original

        payloads_compatible_with
      end

      it 'calls intersecting_paltforms_with on the module_target' do
        expect(described_class).to receive(:intersecting_platforms_with).with(module_target).and_call_original

        payloads_compatible_with
      end
    end
  end

  context '.module_types_that_allow' do
    subject(:module_types_that_allow) do
      described_class.module_types_that_allow(attribute)
    end

    context 'with actions' do
      let(:attribute) do
        :actions
      end

      it { should include 'auxiliary' }
      it { should_not include 'encoder' }
      it { should_not include 'exploit' }
      it { should_not include 'nop' }
      it { should_not include 'payload' }
      it { should include 'post' }
    end

    context 'with module_architectures' do
      let(:attribute) do
        :module_architectures
      end

      it { should_not include 'auxiliary' }
      it { should include 'encoder' }
      it { should include 'exploit' }
      it { should include 'nop' }
      it { should include 'payload' }
      it { should include 'post' }
    end

    context 'with module_platforms' do
      let(:attribute) do
        :module_platforms
      end

      it { should_not include 'auxiliary' }
      it { should_not include 'encoder' }
      it { should include 'exploit' }
      it { should_not include 'nop' }
      it { should include 'payload' }
      it { should include 'post' }
    end

    context 'with module_references' do
      let(:attribute) do
        :module_references
      end

      it { should include 'auxiliary' }
      it { should_not include 'encoder' }
      it { should include 'exploit' }
      it { should_not include 'nop' }
      it { should_not include 'payload' }
      it { should include 'post' }
    end

    context 'with targets' do
      let(:attribute) do
        :targets
      end

      it { should_not include 'auxiliary' }
      it { should_not include 'encoder' }
      it { should include 'exploit' }
      it { should_not include 'nop' }
      it { should_not include 'payload' }
      it { should_not include 'post' }
    end

    context 'DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE' do
      let(:attribute) do
        :attribute
      end

      let(:module_type) do
        FactoryGirl.generate :metasploit_cache_module_type
      end

      before(:each) do
        expect(described_class::DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE).to receive(:fetch).with(
            attribute
        ).and_return(
            dynamic_length_validation_options_by_module_type
        )
      end

      context 'with :is' do
        let(:dynamic_length_validation_options_by_module_type) do
          {
              module_type => {
                  is: is
              }
          }
        end

        context '> 0' do
          let(:is) do
            1
          end

          it 'includes module type' do
            expect(module_types_that_allow).to include(module_type)
          end
        end

        context '<= 0' do
          let(:is) do
            0
          end

          it 'does not include module type' do
            expect(module_types_that_allow).not_to include(module_type)
          end
        end
      end

      context 'without :is' do
        context 'with :maximum' do
          let(:dynamic_length_validation_options_by_module_type) do
            {
                module_type => {
                    maximum: maximum
                }
            }
          end

          context '> 0' do
            let(:maximum) do
              1
            end

            it 'includes module type' do
              expect(module_types_that_allow).to include(module_type)
            end
          end

          context '<= 0' do
            let(:maximum) do
              0
            end

            it 'does not include module type' do
              expect(module_types_that_allow).not_to include(module_type)
            end
          end

        end

        context 'without :maximum' do
          let(:dynamic_length_validation_options_by_module_type) do
            {
                module_type => {}
            }
          end

          it 'includes module type' do
            expect(module_types_that_allow).to include(module_type)
          end
        end
      end
    end
  end

  context '#targets' do
    subject(:targets) do
      module_instance.targets
    end

    context 'with unsaved module_instance' do
      let(:module_instance) do
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            module_class: module_class
        )
      end

      let(:module_class) do
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: module_type
        )
      end

      let(:module_type) do
        module_types.sample
      end

      let(:module_types) do
        Metasploit::Cache::Module::Instance.module_types_that_allow(:targets)
      end

      context 'built without :module_instance' do
        subject(:module_target) do
          targets.build(
              name: name
          )
        end

        let(:name) do
          FactoryGirl.generate :metasploit_cache_module_target_name
        end

        context '#module_instance' do
          subject(:module_target_module_instance) do
            module_target.module_instance
          end

          it 'should be the original module instance' do
            expect(module_target_module_instance).to eq(module_instance)
          end
        end
      end
    end
  end
end