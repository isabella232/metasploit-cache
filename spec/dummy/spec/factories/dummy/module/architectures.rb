FactoryGirl.define do
  factory :dummy_module_architecture,
          class: Dummy::Module::Architecture,
          traits: [
              :metasploit_model_base,
              :metasploit_cache_module_architecture
          ] do
    transient do
      # have to use module_type from metasploit_cache_module_architecture trait to ensure module_instance will support
      # module architectures.
      module_class { FactoryGirl.create(:dummy_module_class, module_type: module_type) }
    end

    architecture { generate :dummy_architecture }
    module_instance {
      FactoryGirl.build(
          :dummy_module_instance,
          # disable module_instance factory from building module_architectures since this factory is already building
          # one
          module_architectures_length: 0,
          module_class: module_class
      )
    }

    after(:build) do |module_architecture|
      module_instance = module_architecture.module_instance

      if module_instance
        unless module_instance.module_architectures.include? module_architecture
          module_instance.module_architectures << module_architecture
        end
      end
    end
  end
end