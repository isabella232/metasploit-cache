# Methods for deriving full_name from module_type and reference_name in {Metasploit::Cache::Module::Ancestor},
# {Metasploit::Cache::Module::Class}, `Metasploit::Framework::Module::Ancestor`, and
# `Metasploit::Framework::Module::Class`.
module Metasploit::Cache::Derivation::FullName
  # Derives full_name by combining module_type and reference_name in the same way used to create modules using
  # Msf::ModuleManager#create in metasploit-framework.
  #
  # @return [String] <module_type>/<reference_name>
  # @return [nil] if module_type is `nil`.
  # @return [nil] if reference_name is `nil`.
  def derived_full_name
    derived = nil

    if module_type and reference_name
      derived = "#{module_type}/#{reference_name}"
    end

    derived
  end
end
