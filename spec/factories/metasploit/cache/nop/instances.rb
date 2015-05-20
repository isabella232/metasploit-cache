FactoryGirl.define do
  factory :metasploit_cache_nop_instance,
          class: Metasploit::Cache::Nop::Instance do
    transient do
      licenses_count 1
    end


    description { generate :metasploit_cache_nop_instance_description }
    name { generate :metasploit_cache_nop_instance_name }

    association :nop_class, factory: :metasploit_cache_nop_class

    after(:build) { |nop_instance, evaluator|
      nop_instance.licensable_licenses = build_list(
        :metasploit_cache_nop_license,
        evaluator.licenses_count,
        licensable: nop_instance
      )
    }

  end

  #
  # Sequences
  #

  sequence(:metasploit_cache_nop_instance_description) { |n|
    "Metasploit::Cache::Nop::Instance#description #{n}"
  }

  sequence(:metasploit_cache_nop_instance_name) { |n|
    "Metasploit::Cache::Nop::Instance#name #{n}"
  }
end