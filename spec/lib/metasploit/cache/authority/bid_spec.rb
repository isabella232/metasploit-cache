require 'spec_helper'

RSpec.describe Metasploit::Cache::Authority::Bid do
  context 'designation_url' do
    subject(:designation_url) do
      described_class.designation_url(designation)
    end

    let(:designation) do
      FactoryGirl.generate :metasploit_cache_reference_bid_designation
    end

    it 'should be under bid directory' do
      expect(designation_url).to eq("http://www.securityfocus.com/bid/#{designation}")
    end
  end
end