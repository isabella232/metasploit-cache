FactoryGirl.define do
  #
  # Factories 
  #
  factory :metasploit_cache_nop_class,
          class: Metasploit::Cache::Nop::Class,
          traits: [
              :metasploit_cache_direct_class
          ] do
    #
    # Associations
    #

    association :ancestor, factory: :metasploit_cache_nop_ancestor

    factory :full_metasploit_cache_nop_class,
            traits: [
                :metasploit_cache_direct_class_ancestor_contents
            ]
  end
end