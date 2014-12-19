require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Type do
  context 'CONSTANTS' do
    context 'ALL' do
      subject(:all) do
        described_class::ALL
      end

      it 'should not include ANY' do
        expect(all).to_not include(described_class::ANY)
      end

      it 'should include AUX' do
        expect(all).to include(described_class::AUX)
      end

      it 'should include ENCODER' do
        expect(all).to include(described_class::ENCODER)
      end

      it 'should include EXPLOIT' do
        expect(all).to include(described_class::EXPLOIT)
      end

      it 'should include NOP' do
        expect(all).to include(described_class::NOP)
      end

      it 'should include PAYLOAD' do
        expect(all).to include(described_class::PAYLOAD)
      end

      it 'should include POST' do
        expect(all).to include(described_class::POST)
      end
    end

    context 'ANY' do
      subject(:any) do
        described_class::ANY
      end

      it { should == '_any_' }
    end

    context 'AUX' do
      subject(:aux) do
        described_class::AUX
      end

      it { should == 'auxiliary' }
    end

    context 'ENCODER' do
      subject(:encoder) do
        described_class::ENCODER
      end

      it { should == 'encoder' }
    end

    context 'EXPLOIT' do
      subject(:exploit) do
        described_class::EXPLOIT
      end

      it { should == 'exploit' }
    end

    context 'NON_PAYLOAD' do
      subject(:non_payload) do
        described_class::NON_PAYLOAD
      end

      it 'should include AUX' do
        expect(non_payload).to include(described_class::AUX)
      end

      it 'should include ENCODER' do
        expect(non_payload).to include(described_class::ENCODER)
      end

      it 'should include EXPLOIT' do
        expect(non_payload).to include(described_class::EXPLOIT)
      end

      it 'should include NOP' do
        expect(non_payload).to include(described_class::NOP)
      end

      it 'should not include PAYLOAD' do
        expect(non_payload).not_to include(described_class::PAYLOAD)
      end

      it 'should include POST' do
        expect(non_payload).to include(described_class::POST)
      end
    end

    context 'NOP' do
      subject(:nop) do
        described_class::NOP
      end

      it { should == 'nop' }
    end

    context 'PAYLOAD' do
      subject(:payload_types) do
        described_class::PAYLOAD
      end

      it { should == 'payload' }
    end

    context 'POST' do
      subject(:post) do
        described_class::POST
      end

      it { should == 'post'}
    end
  end
end