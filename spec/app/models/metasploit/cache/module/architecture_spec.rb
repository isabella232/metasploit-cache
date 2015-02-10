RSpec.describe Metasploit::Cache::Module::Architecture do
 context 'associations' do
    it { should belong_to(:architecture).class_name('Metasploit::Cache::Architecture') }
    it { should belong_to(:module_instance).class_name('Metasploit::Cache::Module::Instance') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:architecture_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:module_instance_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:module_instance_id, :architecture_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_module_architecture' do
      subject(:metasploit_cache_module_architecture) do
        FactoryGirl.build(:metasploit_cache_module_architecture)
      end

      it { should be_valid }

      context '#module_instance' do
        subject(:module_instance) do
          metasploit_cache_module_architecture.module_instance
        end

        it { should be_valid }

        context '#module_architectures' do
          subject(:module_architectures) do
            module_instance.module_architectures
          end

          it 'has one entry' do
            expect(module_architectures.length).to eq(1)
          end

          it "should include metasploit_cache_module_architecture" do
            expect(module_architectures).to include metasploit_cache_module_architecture
          end
        end
      end
    end
  end

 context 'mass assignment security' do
   it { is_expected.to allow_mass_assignment_of(:architecture) }
   it { is_expected.to allow_mass_assignment_of(:module_instance) }
 end

  context 'validations' do
    it { should validate_presence_of(:architecture) }

    # Can't use validate_uniqueness_of(:architecture_id).scoped_to(:module_instance_id) because it will attempt to
    # INSERT with NULL module_instance_id, which is invalid.
    context 'validate uniqueness of architecture_id scoped to module_instance_id' do
      let(:existing_architecture) do
        FactoryGirl.generate :metasploit_cache_architecture
      end

      let(:existing_module_class) do
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: module_type
        )
      end

      let(:existing_module_instance) do
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            module_architectures_length: 0,
            module_class: existing_module_class,
        ).tap { |module_instance|
          module_instance.module_architectures << FactoryGirl.build(
              :metasploit_cache_module_architecture,
              architecture: existing_architecture,
              module_instance: module_instance
          )
        }
      end

      let(:module_type) do
        module_types.sample
      end

      let(:module_types) do
        module_architectures_module_types = Metasploit::Cache::Module::Instance.module_types_that_allow(:module_architectures)
        targets_module_types = Metasploit::Cache::Module::Instance.module_types_that_allow(:targets)

        # have to remove target module types so that target architectures don't interfere with module architectures
        module_architectures_module_types - targets_module_types
      end

      before(:each) do
        existing_module_instance.save!
      end

      context 'with batched' do
        include_context 'Metasploit::Cache::Batch.batch'

        context 'with same architecture_id' do
          subject(:new_module_architecture) do
            existing_module_instance.module_architectures.build.tap { |module_architecture|
              module_architecture.architecture = existing_architecture
            }
          end

          it 'does not record error on architecture_id' do
            new_module_architecture.valid?

            expect(new_module_architecture.errors[:architecture_id]).not_to include('has already been taken')
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_module_architecture.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without same architecture_id' do
          subject(:new_module_architecture) do
            FactoryGirl.build(
                :metasploit_cache_module_architecture,
                :architecture => new_architecture,
                :module_instance => existing_module_instance
            )
          end

          let(:new_architecture) do
            FactoryGirl.generate :metasploit_cache_architecture
          end

          before(:each) do
            existing_module_instance.module_architectures << new_module_architecture
          end

          it { should be_valid }
        end
      end

      context 'without batched' do
        context 'with same architecture_id' do
          subject(:new_module_architecture) do
            FactoryGirl.build(
                :metasploit_cache_module_architecture,
                :architecture => existing_architecture,
                :module_instance => existing_module_instance
            )
          end

          before(:each) do
            existing_module_instance.module_architectures << new_module_architecture
          end

          it { should_not be_valid }

          it 'should record error on architecture_id' do
            new_module_architecture.valid?

            expect(new_module_architecture.errors[:architecture_id]).to include('has already been taken')
          end
        end

        context 'without same architecture_id' do
          subject(:new_module_architecture) do
            FactoryGirl.build(
                :metasploit_cache_module_architecture,
                :architecture => new_architecture,
                :module_instance => existing_module_instance
            )
          end

          let(:new_architecture) do
            FactoryGirl.generate :metasploit_cache_architecture
          end

          before(:each) do
            existing_module_instance.module_architectures << new_module_architecture
          end

          it { should be_valid }
        end
      end
    end

    it { should validate_presence_of(:module_instance) }
  end
end