# Class-level metadata for an encoder  Metasploit Module.
class Metasploit::Cache::Encoder::Class < Metasploit::Cache::Direct::Class
  #
  # Associations
  #

  # Metadata for file that defined the ruby Class.
  belongs_to :ancestor,
             class_name: 'Metasploit::Cache::Encoder::Ancestor',
             inverse_of: :encoder_class

  # Reliability of Metasploit Module.
  belongs_to :rank,
             class_name: 'Metasploit::Cache::Module::Rank',
             inverse_of: :auxiliary_classes

  Metasploit::Concern.run(self)
end