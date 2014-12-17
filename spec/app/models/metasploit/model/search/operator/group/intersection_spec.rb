require 'spec_helper'

RSpec.describe Metasploit::Model::Search::Operator::Group::Intersection do
  it { should be_a Metasploit::Model::Search::Operator::Group::Base }

  context 'operation_class_name' do
    subject(:operation_class_name) {
      described_class.operation_class_name
    }

    it { should == 'Metasploit::Model::Search::Operation::Group::Intersection' }
  end
end