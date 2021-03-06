RSpec.describe Metasploit::Cache::EmailAddress::Persister do
  context 'by_full' do
    subject(:by_full) {
      described_class.by_full(existing_full_set: existing_full_set)
    }

    #
    # let!s
    #

    let!(:existing_not_in_full_set) {
      FactoryGirl.create(:metasploit_cache_email_address)
    }

    context 'with :empty existing_full_set' do
      let(:existing_full_set) {
        Set.new
      }

      context 'with existing Metasploit::Cache::EmailAddress#full' do
        it 'returns existing Metasploit::Cache::EmailAddress' do
          expect(by_full[existing_not_in_full_set.full]).to eq existing_not_in_full_set
        end
      end

      context 'without existing Metasploit::Cache::EmailAddress#full' do
        let(:domain) {
          FactoryGirl.generate :metasploit_cache_email_address_domain
        }

        let(:full) {
          "#{local}@#{domain}"
        }

        let(:local) {
          FactoryGirl.generate :metasploit_cache_email_address_local
        }

        it 'returns a newly created Metasploit::Cache::EmailAddress' do
          expect {
            by_full[full]
          }.to change(Metasploit::Cache::EmailAddress, :count).by(1)

          expect(by_full[full]).to be_persisted
        end
      end
    end

    context 'with present :existing_full_set' do
      #
      # let
      #

      let(:existing_full_set) {
        Set.new [existing_in_full_set.full]
      }

      #
      # let!s
      #

      let!(:existing_in_full_set) {
        FactoryGirl.create(:metasploit_cache_email_address)
      }

      context 'with existing Metasploit::Cache::EmailAddress#full' do
        context 'in :existing_full_set' do
          it 'returns existing Metasploit::Cache::EmailAddress' do
            expect(by_full[existing_in_full_set.full]).to eq(existing_in_full_set)
          end
        end

        context 'not in :existing_full_set' do
          it 'returns existing Metasploit::Cache::EmailAddress' do
            expect(by_full[existing_not_in_full_set.full]).to eq existing_not_in_full_set
          end
        end
      end

      context 'without existing Metasploit::Cache::EmailAddress#full' do
        let(:domain) {
          FactoryGirl.generate :metasploit_cache_email_address_domain
        }

        let(:full) {
          "#{local}@#{domain}"
        }

        let(:local) {
          FactoryGirl.generate :metasploit_cache_email_address_local
        }

        it 'returns a newly created Metasploit::Cache::EmailAddress' do
          expect {
            by_full[full]
          }.to change(Metasploit::Cache::EmailAddress, :count).by(1)

          expect(by_full[full]).to be_persisted
        end
      end
    end
  end
end