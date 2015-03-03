FactoryGirl.define do
  factory :metasploit_cache_payload_single_ancestor,
          class: Metasploit::Cache::Payload::Single::Ancestor,
          parent: :metasploit_cache_payload_ancestor do
    transient do
      payload_type { 'single' }
    end
  end
end