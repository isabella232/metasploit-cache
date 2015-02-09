shared_examples_for 'Metasploit::Cache::Module::Instance is stanced with module_type' do |context_module_type|
  context "with #{context_module_type.inspect}" do
    # define as a let so that lets from outer context can access option to set detail.
    let(:module_type) do
      context_module_type
    end

    it "should have #{context_module_type.inspect} for module_class.module_type" do
      expect(module_instance.module_class.module_type).to eq(module_type)
    end

    it { should be_stanced }

    context 'with nil stance' do
      let(:stance) do
        nil
      end

      it { should be_invalid }
    end

    context "with 'aggresive' stance" do
      let(:stance) do
        'aggressive'
      end

      it { should be_valid }
    end

    context "with 'passive' stance" do
      let(:stance) do
        'passive'
      end

      it { should be_valid }
    end
  end
end