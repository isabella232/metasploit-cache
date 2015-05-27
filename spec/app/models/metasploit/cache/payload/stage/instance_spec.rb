RSpec.describe Metasploit::Cache::Payload::Stage::Instance do
  it_should_behave_like 'Metasploit::Concern.run'

  context "associations" do
    it { is_expected.to have_many(:contributions).class_name('Metasploit::Cache::Contribution').dependent(:destroy).inverse_of(:contribution) }
    it { is_expected.to have_many(:licensable_licenses).class_name('Metasploit::Cache::Licensable::License')}
    it { is_expected.to have_many(:licenses).class_name('Metasploit::Cache::License')}
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:payload_stage_class_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:privileged).of_type(:boolean).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:payload_stage_class_id).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_payload_stage_instance' do
      subject(:metasploit_cache_payload_stage_instance) {
        FactoryGirl.build(:metasploit_cache_payload_stage_instance)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :payload_stage_class }
    it { is_expected.to validate_inclusion_of(:privileged).in_array([false, true]) }

    # validate_uniqueness_of needs a pre-existing record of the same class to work correctly when the `null: false`
    # constraints exist for other fields.
    context 'with existing record' do
      let!(:existing_payload_stage_instance) {
        FactoryGirl.create(
            :metasploit_cache_payload_stage_instance
        )
      }

      it { is_expected.to validate_uniqueness_of :payload_stage_class_id }
    end

    context "validate that there is at least one license per stage" do
      let(:error){
        I18n.translate!(
            'activerecord.errors.models.metasploit/cache/payload/stage/instance.attributes.licensable_licenses.too_short',
            count: 1
        )
      }

      context "without licensable licenses" do
        subject(:stage_instance){
          FactoryGirl.build(:metasploit_cache_payload_stage_instance, licenses_count: 0)
        }

        it "adds error on #licensable_licenses" do
          stage_instance.valid?

          expect(stage_instance.errors[:licensable_licenses]).to include(error)
        end
      end

      context "with licensable licenses" do
        subject(:stage_instance){
          FactoryGirl.build(:metasploit_cache_payload_stage_instance, licenses_count: 1)
        }

        it "does not add error on #licensable_licenses" do
          stage_instance.valid?

          expect(stage_instance.errors[:licensable_licenses]).to_not include(error)
        end
      end
    end
  end
end