FactoryGirl.define do
  factory :metasploit_cache_payload_stage_instance,
          class: Metasploit::Cache::Payload::Stage::Instance do
    description { generate :metasploit_cache_payload_stage_instance_description }
    name { generate :metasploit_cache_payload_stage_instance_name }
    privileged { generate :metasploit_cache_payload_stage_instance_privileged }

    association :payload_stage_class, factory: :metasploit_cache_payload_stage_class
  end

  #
  # Sequences
  #

  sequence(:metasploit_cache_payload_stage_instance_description) { |n|
    "Metasploit::Cache::Payload::Stage::Instance#description #{n}"
  }

  sequence(:metasploit_cache_payload_stage_instance_name) { |n|
    "Metasploit::Cache::Payload::Stage::Instance#name #{n}"
  }

  sequence :metasploit_cache_payload_stage_instance_privileged, Metasploit::Cache::Spec.sample_stream([false, true])
end