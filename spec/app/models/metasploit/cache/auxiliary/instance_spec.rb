RSpec.describe Metasploit::Cache::Auxiliary::Instance, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:auxiliary_class).class_name('Metasploit::Cache::Auxiliary::Class').inverse_of(:auxiliary_instance) }
    it { is_expected.to have_many(:actions).class_name('Metasploit::Cache::Actionable::Action').inverse_of(:actionable) }
    it { is_expected.to belong_to(:default_action).class_name('Metasploit::Cache::Actionable::Action').inverse_of(:actionable) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:auxiliary_class_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:default_action_id).of_type(:integer).with_options(null: true) }
      it { is_expected.to have_db_column(:description).of_type(:text).with_options(null: false) }
      it { is_expected.to have_db_column(:disclosed_on).of_type(:date).with_options(null: true) }
    end

    context 'indices' do
      it { is_expected.to have_db_index([:auxiliary_class_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_auxiliary_instance' do
      subject(:metasploit_cache_auxiliary_instance) {
        FactoryGirl.build(:metasploit_cache_auxiliary_instance)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:auxiliary_class) }

    # validate_lenght_of from shoulda-matchers assumes attribute is String and doesn't work on associations
    context 'validates length of actions is at least 1' do
      let(:error) {
        I18n.translate!(
          'activerecord.errors.models.metasploit/cache/auxiliary/instance.attributes.actions.too_short',
           count: 1
        )
      }

      context 'without actions' do
        subject(:auxiliary_instance) {
          FactoryGirl.build(
              :metasploit_cache_auxiliary_instance,
              actions_count: 0
          )
        }

        it 'adds error on #actions' do
          auxiliary_instance.valid?

          expect(auxiliary_instance.errors[:actions]).to include(error)
        end
      end

      context 'with actions' do
        subject(:auxiliary_instance) {
          FactoryGirl.build(
              :metasploit_cache_auxiliary_instance,
              actions_count: 1
          )
        }

        it 'does not adds error on #actions' do
          auxiliary_instance.valid?

          expect(auxiliary_instance.errors[:actions]).not_to include(error)
        end
      end
    end

    context 'actions_contains_default_action' do
      let(:error) {
        I18n.translate!(
            'activerecord.errors.models.metasploit/cache/auxiliary/instance.attributes.actions.does_not_contain_default_action'
        )
      }

      context 'with actions' do
        context 'with default_action' do
          context 'actions contains default_action' do
            subject(:auxiliary_instance) {
              FactoryGirl.build(
                             :metasploit_cache_auxiliary_instance,
                             actions_count: 1
              ).tap { |auxiliary_instance|
                auxiliary_instance.default_action = auxiliary_instance.actions.first
              }
            }

            it 'has actions' do
              expect(auxiliary_instance.actions.size).to be > 0
            end

            it 'has default_action' do
              expect(auxiliary_instance.default_action).not_to be_nil
            end

            it 'has default_action in actions' do
              expect(auxiliary_instance.actions).to include auxiliary_instance.default_action
            end

            it 'does not add error on default_action' do
              auxiliary_instance.valid?

              expect(auxiliary_instance.errors[:actions]).not_to include(error)
            end
          end

          context 'actions does not contain default_action' do
            subject(:auxiliary_instance) {
              FactoryGirl.build(
                             :metasploit_cache_auxiliary_instance,
                             actions_count: 1
              ).tap { |auxiliary_instance|
                auxiliary_instance.default_action = FactoryGirl.build(
                    :metasploit_cache_auxiliary_action,
                    actionable: auxiliary_instance
                )
              }
            }

            it 'has actions' do
              expect(auxiliary_instance.actions.size).to be > 0
            end

            it 'has default_action' do
              expect(auxiliary_instance.default_action).not_to be_nil
            end

            it 'does not have default_action in actions' do
              expect(auxiliary_instance.actions).not_to include auxiliary_instance.default_action
            end

            it 'adds error on default_action' do
              auxiliary_instance.valid?

              expect(auxiliary_instance.errors[:actions]).to include(error)
            end
          end
        end

        context 'without default_action' do
          subject(:auxiliary_instance) {
            FactoryGirl.build(
                :metasploit_cache_auxiliary_instance,
                actions_count: 1
            ).tap { |auxiliary_instance|
              auxiliary_instance.default_action = nil
            }
          }

          it 'has actions' do
            expect(auxiliary_instance.actions.size).to be > 0
          end

          it 'has no default_action' do
            expect(auxiliary_instance.default_action).to be_nil
          end

          it 'does not add error on :actions' do
            auxiliary_instance.valid?

            expect(auxiliary_instance.errors[:actions]).not_to include(error)
          end
        end
      end

      context 'without actions' do
        context 'with default_action' do
          subject(:auxiliary_instance) {
            FactoryGirl.build(
                :metasploit_cache_auxiliary_instance,
                actions_count: 0
            ).tap { |auxiliary_instance|
              auxiliary_instance.default_action = FactoryGirl.build(
                  :metasploit_cache_auxiliary_action,
                  actionable: auxiliary_instance
              )
            }
          }

          it 'has no actions' do
            expect(auxiliary_instance.actions.size).to eq(0)
          end

          it 'has default_action' do
            expect(auxiliary_instance.default_action).not_to be_nil
          end

          it 'adds error on :actions' do
            auxiliary_instance.valid?

            expect(auxiliary_instance.errors[:actions]).to include(error)
          end
        end

        context 'without default_action' do
          subject(:auxiliary_instance) {
            FactoryGirl.build(
                :metasploit_cache_auxiliary_instance,
                actions_count: 0
            ).tap { |auxiliary_instance|
              auxiliary_instance.default_action = nil
            }
          }

          it 'has no actions' do
            expect(auxiliary_instance.actions.size).to eq(0)
          end

          it 'has no default_action' do
            expect(auxiliary_instance.default_action).to be_nil
          end

          it 'does not add error on :actions' do
            auxiliary_instance.valid?

            expect(auxiliary_instance.errors[:actions]).not_to include(error)
          end
        end
      end
    end

    it { is_expected.to validate_presence_of :description }
  end
end