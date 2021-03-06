FactoryGirl.define do
  #
  # Sequences
  #

  minimum_version = 1
  maximum_version = 4
  range = maximum_version - minimum_version + 1

  sequence :metasploit_cache_module_ancestor_metasploit_module_relative_name do |n|
    version = (n % range) + minimum_version

    "Metasploit#{version}"
  end

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

  #
  # Traits
  #

  trait :metasploit_cache_module_ancestor do
    transient do
      reference_name { generate :metasploit_cache_module_ancestor_reference_name }
    end

    #
    # Associations
    #

    association :parent_path, factory: :metasploit_cache_module_path

    #
    # Attributes
    #

    # depends on module_type and reference_name
    relative_path {
      if module_type
        module_type_directory = Metasploit::Cache::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE.fetch(module_type, module_type)

        "#{module_type_directory}/#{reference_name}#{Metasploit::Cache::Module::Ancestor::EXTENSION}"
      end
    }
  end

  trait :metasploit_cache_module_ancestor_contents do
    transient do
      content? { true }
      metasploit_module_relative_name { generate :metasploit_cache_module_ancestor_metasploit_module_relative_name }
      superclass { 'Metasploit::Model::Base' }
    end

    #
    # Callbacks
    #

    after(:build) do |module_ancestor, evaluator|
      # needed to allow for usage of trait with invalid relative_path, when `content?: false` should be set
      if evaluator.content?
        real_pathname = module_ancestor.real_pathname

        unless real_pathname
          raise ArgumentError,
                "#{module_ancestor.class}#real_pathname is `nil` and content cannot be written.  " \
                'If this is expected, set `content?: false` ' \
                'when using the :metasploit_cache_module_ancestor_contents trait.'
        end

        cell = Metasploit::Cache::Module::AncestorCell.(module_ancestor)

        # make directory
        real_pathname.parent.mkpath

        real_pathname.open('wb') do |f|
          f.write(
              cell.(
                  :show,
                  metasploit_module_relative_name: evaluator.metasploit_module_relative_name,
                  superclass: evaluator.superclass
              )
          )
        end
      end
    end
  end
end