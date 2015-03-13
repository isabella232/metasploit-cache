FactoryGirl.define do
  #
  # Sequences
  #

  sequence :metasploit_cache_non_payload_ancestor_factory,
           Metasploit::Cache::Module::Ancestor::Spec.random_non_payload_factory

  sequence :metasploit_cache_module_ancestor_factory, Metasploit::Cache::Module::Ancestor::Spec.random_factory

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
      metasploit_module_relative_name { generate :metasploit_cache_module_ancestor_metasploit_module_relative_name }
      reference_name { generate :metasploit_cache_module_ancestor_reference_name }
      superclass { 'Metasploit::Model::Base' }
    end

    #
    # Callbacks
    #

    after(:build) do |module_ancestor, evaluator|
      context = Object.new
      cell = Cell::Base.cell_for(
          'metasploit/cache/module/ancestor',
          context,
          module_ancestor,
          metasploit_module_relative_name: evaluator.metasploit_module_relative_name,
          superclass: evaluator.superclass
      )

      # make directory
      module_ancestor.real_pathname.parent.mkpath

      module_ancestor.real_pathname.open('wb') { |f|
        f.write(cell.call)
      }
    end

    #
    # Associations
    #

    association :parent_path, :factory => :metasploit_cache_module_path

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
end