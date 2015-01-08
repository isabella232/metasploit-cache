FactoryGirl.define do
  factory :metasploit_cache_module_ancestor,
          class: Metasploit::Cache::Module::Ancestor do
    transient do
      # depends on module_type
      payload_type {
        if payload?
          generate :metasploit_cache_module_ancestor_payload_type
        else
          nil
        end
      }

      #
      # Callback helpers
      #

      before_write_template {
        ->(module_ancestor, evaluator){}
      }
      write_template {
        ->(module_ancestor, evaluator){
          Metasploit::Cache::Module::Ancestor::Spec::Template.write(module_ancestor: module_ancestor)
        }
      }
    end

    #
    # Callbacks
    #

    after(:build) do |module_ancestor, evaluator|
      instance_exec(module_ancestor, evaluator, &evaluator.before_write_template)
      instance_exec(module_ancestor, evaluator, &evaluator.write_template)
    end

    #
    # Associations
    #

    association :parent_path, :factory => :metasploit_cache_module_path

    #
    # Attributes
    #

    module_type { generate :metasploit_cache_module_type }

    # depends on module_type
    reference_name {
      if payload?
        payload_type_directory = payload_type.pluralize
        relative_payload_name = generate :metasploit_cache_module_ancestor_relative_payload_name

        [
            payload_type_directory,
            relative_payload_name
        ].join('/')
      else
        generate :metasploit_cache_module_ancestor_non_payload_reference_name
      end
    }

    # @note depends on derived_payload_type which depends on reference_name so this needs to be last because the order
    #   of declaration is the order that these blocks are run
    handler_type {
      # can't use #handled? because it will check payload_type on model, not ignored field in factory, so use
      # .handled?
      if Metasploit::Cache::Module::Ancestor.handled?(:module_type => module_type, :payload_type => derived_payload_type)
        generate :metasploit_cache_module_ancestor_handler_type
      else
        nil
      end
    }

    #
    # Child Factories
    #

    factory :non_payload_metasploit_cache_module_ancestor do
      transient do
        payload_type nil
      end

      #
      # Attributes
      #

      module_type { generate :metasploit_cache_non_payload_module_type }
    end

    factory :payload_metasploit_cache_module_ancestor do
      transient do
        payload_type { generate :metasploit_cache_module_ancestor_payload_type }
      end

      #
      # Attributes
      #

      module_type 'payload'

      reference_name {
        payload_type_directory = payload_type.pluralize
        relative_payload_name = generate :metasploit_cache_module_ancestor_relative_payload_name

        [
            payload_type_directory,
            relative_payload_name
        ].join('/')
      }

      factory :single_payload_metasploit_cache_module_ancestor do
        transient do
          payload_type 'single'
        end
      end

      factory :stage_payload_metasploit_cache_module_ancestor do
        transient do
          payload_type 'stage'
        end
      end

      factory :stager_payload_metasploit_cache_module_ancestor do
        transient do
          payload_type 'stager'
        end
      end
    end
  end

  sequence :metasploit_cache_module_ancestor_handler_type do |n|
    "metasploit_cache_module_ancestor_handler_type#{n}"
  end

  minimum_version = 1
  maximum_version = 4
  range = maximum_version - minimum_version + 1

  sequence :metasploit_cache_module_ancestor_metasploit_module_relative_name do |n|
    version = (n % range) + minimum_version

    "Metasploit#{version}"
  end

  sequence :metasploit_cache_module_ancestor_payload_type, Metasploit::Cache::Module::Ancestor::PAYLOAD_TYPES.cycle

  sequence :metasploit_cache_module_ancestor_reference_name do |n|
    [
        'metasploit',
        'cache',
        'module',
        'ancestor',
        'reference',
        "name#{n}"
    ].join('/')
  end

  sequence :metasploit_cache_module_ancestor_non_payload_reference_name do |n|
    [
        'metasploit',
        'cache',
        'module',
        'ancestor',
        'non',
        'payload',
        'reference',
        "name#{n}"
    ].join('/')
  end

  payload_type_directories = Metasploit::Cache::Module::Ancestor::PAYLOAD_TYPES.map(&:pluralize)

  sequence :metasploit_cache_module_ancestor_payload_reference_name do |n|
    payload_type_directory = payload_type_directories[n % payload_type_directories.length]

    [
        payload_type_directory,
        'metasploit',
        'cache',
        'module',
        'ancestor',
        'payload',
        'reference',
        "name#{n}"
    ].join('/')
  end

  sequence :metasploit_cache_module_ancestor_relative_payload_name do |n|
    [
        'metasploit',
        'cache',
        'module',
        'ancestor',
        'relative',
        'payload',
        "name#{n}"
    ].join('/')
  end
end