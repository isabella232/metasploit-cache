require 'spec_helper'

RSpec.describe Metasploit::Model::Module::Action do
  it_should_behave_like 'Metasploit::Model::Module::Action',
                        namespace_name: 'Dummy'
end