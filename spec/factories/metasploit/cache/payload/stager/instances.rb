FactoryGirl.define do
  factory :metasploit_cache_payload_stager_instance,
          class: Metasploit::Cache::Payload::Stager::Instance do
    transient do
      licensable_license_count 1
    end

    description { generate :metasploit_cache_payload_stager_instance_description }
    handler_type_alias { generate :metasploit_cache_payload_stager_handler_type_alias }
    name { generate :metasploit_cache_payload_stager_instance_name }
    privileged { generate :metasploit_cache_payload_stager_instance_privileged }

    #
    # Associations
    #

    association :handler, factory: :metasploit_cache_payload_handler
    association :payload_stager_class, factory: :metasploit_cache_payload_stager_class

    #
    # Callbacks
    #

    after(:build) do |stager_instance, evaluator|
      stager_instance.licensable_licenses = build_list(
        :metasploit_cache_payload_stager_license,
        evaluator.licensable_license_count,
        licensable: stager_instance
      )
    end

  end

  #
  # Sequences
  #

  sequence(:metasploit_cache_payload_stager_instance_description) { |n|
    "Metasploit::Cache::Payload::Stager::Instance#description #{n}"
  }

  sequence(:metasploit_cache_payload_stager_handler_type_alias) { |n|
    "metasploit_cache_payload_stager_handler_type_alias#{n}"
  }

  sequence(:metasploit_cache_payload_stager_instance_name) { |n|
    "Metasploit::Cache::Payload::Stager::Instance#name #{n}"
  }

  sequence :metasploit_cache_payload_stager_instance_privileged, Metasploit::Cache::Spec.sample_stream([false, true])
end