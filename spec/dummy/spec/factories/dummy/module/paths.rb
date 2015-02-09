FactoryGirl.define do
  # Used to test {Metasploit::Cache::Module::Path} and to ensure that traits work when used in factories.
  factory :dummy_module_path,
          :aliases => [
              :unnamed_dummy_module_path
          ],
          :class => Dummy::Module::Path,
          :traits => [
              :unnamed_metasploit_cache_module_path
          ] do
    factory :named_dummy_module_path,
            :traits => [
                :named_metasploit_cache_module_path
            ]
  end
end