RSpec.describe Metasploit::Cache::Spec::Unload do
  context 'CONSTANTS' do
    context 'LOADED_MODULE_CHILD_CONSTANT_REGEXP' do
      subject(:loaded_module_child_constant_regexp) {
        described_class::LOADED_MODULE_CHILD_CONSTANT_REGEXP
      }

      let(:module_ancestor) {
        FactoryGirl.build(:metasploit_cache_auxiliary_ancestor) { |module_ancestor|
          # validation to populate real_path_sha1_hex_digest
          module_ancestor.valid?
        }
      }

      it 'matches name generated by Metasploit::Cache::Module::Namespace.names' do
        expect(loaded_module_child_constant_regexp).to match(Metasploit::Cache::Module::Namespace.names(module_ancestor).last)
      end
    end

    context 'PERSISTENT_CHILD_CONSTANT_NAMES' do
      subject(:persistent_child_constant_names) {
        described_class::PERSISTENT_CHILD_CONSTANT_NAMES
      }

      it { is_expected.to include :Error }
      it { is_expected.to include :Loader }
      it { is_expected.to include :MetasploitClassCompatibilityError }
      it { is_expected.to include :Namespace }
      it { is_expected.to include :VersionCompatibilityError }
    end
  end

  context 'define_task' do
    subject(:define_task) {
      described_class.define_task
    }

    it 'defines Suite and Each tasks' do
      expect(Metasploit::Cache::Spec::Unload::Each).to receive(:define_task)
      expect(Metasploit::Cache::Spec::Unload::Suite).to receive(:define_task)

      define_task
    end
  end

  context 'each' do
    #
    # Methods
    #

    def each(&block)
      described_class.each(&block)
    end

    #
    # lets
    #

    let(:first_non_persistent) {
      Module.new
    }

    let(:persistent_loader) {
      Module.new
    }

    let(:second_non_persistent) {
      Module.new
    }

    #
    # Callbacks
    #

    before(:each) do
      hide_const('Msf::Modules')
      stub_const('Msf::Modules::Loader', persistent_loader)
      stub_const('Msf::Modules::FirstNonPersistent', first_non_persistent)
      stub_const('Msf::Payloads::SecondNonPersistent', second_non_persistent)
    end

    it 'does not yield constants in PERSISTENT_CHILD_CONSTANT_NAMES' do
      expect(described_class.to_enum(:each).to_a).not_to include(:Loader)
    end

    it 'yields constants not in PERSISTENT_CHILD_CONSTANT_NAMES' do
      leaked_constants = described_class.to_enum(:each).to_a

      expect(leaked_constants).to include([Msf::Modules, :FirstNonPersistent])
      expect(leaked_constants).to include([Msf::Payloads,:SecondNonPersistent])
    end

    it 'returns number of leaked constants' do
      expect(
          each {

          }
      ).to eq(
                     {
                         Msf::Modules => 1,
                         Msf::Payloads => 1
                     }
                 )
    end
  end

  context 'each_parent_constant' do
    context 'with Metasploit::Cache::Payload::Handler::Namespace defined' do
      before(:each) do
        stub_const('Metasploit::Cache::Payload::Handler::Namespace', Module.new)
      end

      context 'with Msf::Modules defined' do
        before(:each) do
          stub_const('Msf::Modules', Module.new)
        end

        context 'with Msf::Payloads defined' do
          before(:each) do
            stub_const('Msf::Payloads', Module.new)
          end

          it 'yields all three' do
            expect { |b|
              described_class.each_parent_constant(&b)
            }.to yield_successive_args(Metasploit::Cache::Payload::Handler::Namespace, Msf::Modules, Msf::Payloads)
          end
        end

        context 'without Msf::Payloads defined' do
          before(:each) do
            hide_const('Msf::Payloads')
          end

          it 'yields only Metasploit::Cache::Payload::Handler::Namesapce and Msf::Modules' do
            expect { |b|
              described_class.each_parent_constant(&b)
            }.to yield_successive_args(Metasploit::Cache::Payload::Handler::Namespace, Msf::Modules)
          end

          it 'does not load Msf::Payloads' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Msf::Payloads }
          end
        end
      end

      context 'without Msf::Modules defined' do
        before(:each) do
          hide_const('Msf::Modules')
        end

        context 'with Msf::Payloads defined' do
          before(:each) do
            stub_const('Msf::Payloads', Module.new)
          end

          it 'yields only Metasploit::Cache::Payload::Handler::Namesapce and Msf::Payloads' do
            expect { |b|
              described_class.each_parent_constant(&b)
            }.to yield_successive_args(Metasploit::Cache::Payload::Handler::Namespace, Msf::Payloads)
          end

          it 'does not load Msf::Modules' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Msf::Modules }
          end
        end

        context 'without Msf::Payalods defined' do
          before(:each) do
            hide_const('Msf::Payloads')
          end

          it 'yields only Metasploit::Cache::Payload::Handler::Namesapce' do
            expect { |b|
              described_class.each_parent_constant(&b)
            }.to yield_successive_args(Metasploit::Cache::Payload::Handler::Namespace)
          end

          it 'does not load Msf::Modules' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Msf::Modules }
          end

          it 'does not load Msf::Payloads' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Msf::Payloads }
          end
        end
      end
    end

    context 'without Metasploit::Cache::Payload::Handler::Namespace' do
      before(:each) do
        hide_const('Metasploit::Cache::Payload::Handler::Namespace')
      end

      context 'with Msf::Modules defined' do
        before(:each) do
          stub_const('Msf::Modules', Module.new)
        end

        context 'with Msf::Payloads defined' do
          before(:each) do
            stub_const('Msf::Payloads', Module.new)
          end

          it 'yields only Msf::Modules and Msf::Payloads' do
            expect { |b|
              described_class.each_parent_constant(&b)
            }.to yield_successive_args(Msf::Modules, Msf::Payloads)
          end

          it 'does not load Metasploit::Cache::Payload::Handler::Namespace' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Metasploit::Cache::Payload::Handler::Namespace }
          end
        end

        context 'without Msf::Payloads defined' do
          before(:each) do
            hide_const('Msf::Payloads')
          end

          it 'yields only Msf::Modules' do
            expect { |b|
              described_class.each_parent_constant(&b)
            }.to yield_successive_args(Msf::Modules)
          end

          it 'does not load Metasploit::Cache::Payload::Handler::Namespace' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Metasploit::Cache::Payload::Handler::Namespace }
          end

          it 'does not load Msf::Payloads' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Msf::Payloads }
          end
        end
      end

      context 'without Msf::Modules defined' do
        before(:each) do
          hide_const('Msf::Modules')
        end

        context 'with Msf::Payloads defined' do
          before(:each) do
            stub_const('Msf::Payloads', Module.new)
          end

          it 'yields only Msf::Payloads' do
            expect { |b|
              described_class.each_parent_constant(&b)
            }.to yield_successive_args(Msf::Payloads)
          end

          it 'does not load Metasploit::Cache::Payload::Handler::Namespace' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Metasploit::Cache::Payload::Handler::Namespace }
          end

          it 'does not load Msf::Modules' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Msf::Modules }
          end
        end

        context 'without Msf::Payalods defined' do
          before(:each) do
            hide_const('Msf::Payloads')
          end

          it 'does not yield' do
            expect { |b|
              described_class.each_parent_constant(&b)
            }.not_to yield_control
          end

          it 'does not load Metasploit::Cache::Payload::Handler::Namespace' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Metasploit::Cache::Payload::Handler::Namespace }
          end

          it 'does not load Msf::Modules' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Msf::Modules }
          end

          it 'does not load Msf::Payloads' do
            expect {
              described_class.to_enum(:each_parent_constant).to_a
            }.not_to change { defined? Msf::Payloads }
          end
        end
      end
    end
  end

  context 'unload' do
    subject(:unload) {
      Metasploit::Cache::Spec::Unload.unload
    }

    #
    # lets
    #

    let(:first_non_persistent) {
      Module.new
    }

    let(:persistent_loader) {
      Module.new
    }

    let(:second_non_persistent) {
      Module.new
    }

    #
    # Callbacks
    #

    before(:each) do
      hide_const('Msf::Modules')
      stub_const('Msf::Modules::Loader', persistent_loader)

      Msf::Modules::FirstNonPersistent = first_non_persistent
      Msf::Modules::SecondNonPersistent = second_non_persistent
    end

    it 'does not remove constants in PERSISTENT_CHILD_CONSTANT_NAMES' do
      expect {
        unload
      }.not_to change { defined? Msf::Modules::Loader }
    end

    it 'removes constants not in PERSISTENT_CHILD_CONSTANT_NAMES' do
      unload

      expect(defined? Msf::Modules::FirstNonPersistent).to be_nil
      expect(defined? Msf::Modules::SecondNonPersistent).to be_nil
    end
  end
end