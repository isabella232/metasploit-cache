require 'spec_helper'

RSpec.describe Metasploit::Cache::Search::Operator::Deprecated::Ref do
  subject(:operator) do
    described_class.new(
        :klass => klass
    )
  end

  let(:klass) do
    Class.new
  end

  context '#children' do
    include_context 'Metasploit::Model::Search::Operator::Group::Union#children'

    let(:abbreviation_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :abbreviation,
          :klass => authority_class,
          :type => :string
      )
    end

    let(:authority_class) do
      Class.new
    end

    let(:authorities_abbreviation_operator) do
      Metasploit::Model::Search::Operator::Association.new(
          :association => :authorities,
          :klass => klass,
          :source_operator => abbreviation_operator
      )
    end

    let(:designation_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :designation,
          :klass => reference_class,
          :type => :string
      )
    end

    let(:reference_class) do
      Class.new
    end

    let(:references_designation_operator) do
      Metasploit::Model::Search::Operator::Association.new(
          :association => :references,
          :klass => klass,
          :source_operator => designation_operator
      )
    end

    let(:references_url_operator) do
      Metasploit::Model::Search::Operator::Association.new(
          :association => :references,
          :klass => klass,
          :source_operator => url_operator
      )
    end

    let(:url_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :url,
          :klass => reference_class,
          :type => :string
      )
    end

    before(:each) do
      allow(operator).to receive(:operator).with('authorities.abbreviation').and_return(authorities_abbreviation_operator)
      allow(operator).to receive(:operator).with('references.designation').and_return(references_designation_operator)
      allow(operator).to receive(:operator).with('references.url').and_return(references_url_operator)
    end

    context "with '-'" do
      let(:formatted_value) do
        "#{head}-#{tail}"
      end

      context "with 'URL'" do
        let(:head) do
          'URL'
        end

        context 'with blank url' do
          let(:tail) do
            ''
          end

          it { should be_empty }
        end

        context 'without blank url' do
          let(:tail) do
            FactoryGirl.generate :metasploit_cache_reference_url
          end

          context 'authorities.abbreviation' do
            subject(:operation) do
              child('authorities.abbreviation')
            end

            it 'should not be in children' do
              expect(operation).to be_nil
            end
          end

          context 'references.designation' do
            subject(:operation) do
              child('references.designation')
            end

            it 'should not be in children' do
              expect(operation).to be_nil
            end
          end

          context 'references.url' do
            subject(:operation) do
              child('references.url')
            end

            context 'Metasploit::Model::Search::Operation::Association' do
              subject(:source_operation) {
                operation.source_operation
              }

              it "uses portion of formatted value after 'URL-' for value" do
                expect(source_operation.value).to eq(tail)
              end
            end
          end
        end
      end

      context "without 'URL'" do
        let(:head) do
          FactoryGirl.generate :metasploit_cache_authority_abbreviation
        end

        let(:tail) do
          FactoryGirl.generate :metasploit_cache_reference_designation
        end

        context 'with blank head' do
          let(:head) do
            ''
          end

          context 'authorities.abbreviation' do
            subject(:operation) do
              child('authorities.abbreviation')
            end

            it 'should not be in children' do
              expect(operation).to be_nil
            end
          end

          context 'references.designation' do
            subject(:operation) do
              child('references.designation')
            end

            context 'Metasploit::Model::Search::Operation::Association#source_operation' do
              subject(:source_operation) {
                operation.source_operation
              }

              it "uses portion of formatted value after '-' for value" do
                expect(source_operation.value).to eq(tail)
              end
            end
          end

          context 'references.url' do
            subject(:operation) do
              child('references.url')
            end

            it 'should not be in children' do
              expect(operation).to be_nil
            end
          end
        end

        context 'without blank head' do
          context 'authorities.abbreviation' do
            subject(:operation) do
              child('authorities.abbreviation')
            end

            context 'Metasploit::Model::Search::Operation::Association#source_operation' do
              subject(:source_operation) {
                operation.source_operation
              }

              it "uses portion of formatted value before '-' as value" do
                expect(source_operation.value).to eq(head)
              end
            end
          end

          context 'references.designation' do
            subject(:operation) do
              child('references.designation')
            end

            context 'Metasploit::Model::Search::Operation::Association#source_operation' do
              subject(:source_operation) {
                operation.source_operation
              }

              it "uses portion of formatted value after '-' as value" do
                expect(source_operation.value).to eq(tail)
              end
            end
          end

          context 'references.url' do
            subject(:operation) do
              child('references.url')
            end

            it 'should not be in children' do
              expect(operation).to be_nil
            end
          end
        end

        context 'with blank tail' do
          let(:tail) do
            ''
          end

          context 'authorities.abbreviation' do
            subject(:operation) do
              child('authorities.abbreviation')
            end

            context 'Metasploit::Model::Search::Operation::Association#source_operation' do
              subject(:source_operation) {
                operation.source_operation
              }

              it "use portion of formatted value before '-' for value" do
                expect(source_operation.value).to eq(head)
              end
            end
          end

          context 'references.designation' do
            subject(:operation) do
              child('references.designation')
            end

            it 'should not be in children' do
              expect(operation).to be_nil
            end
          end

          context 'references.url' do
            subject(:operation) do
              child('references.url')
            end

            it 'should not be in children' do
              expect(operation).to be_nil
            end
          end
        end

        context 'without blank tail' do
          context 'authorities.abbreviation' do
            subject(:operation) do
              child('authorities.abbreviation')
            end

            context 'Metasploit::Model::Search::Operation::Association#source_operation' do
              subject(:source_operation) {
                operation.source_operation
              }

              it "uses portion of format value before '-' for value" do
                expect(source_operation.value).to eq(head)
              end
            end
          end

          context 'references.designation' do
            subject(:operation) do
              child('references.designation')
            end

            context 'Metasploit::Model::Search::Operation::Association#source_operation' do
              subject(:source_operation) {
                operation.source_operation
              }

              it "uses portion of format value after '-' for value" do
                expect(source_operation.value).to eq(tail)
              end
            end
          end

          context 'references.url' do
            subject(:operation) do
              child('references.url')
            end

            it 'should not be in children' do
              expect(operation).to be_nil
            end
          end
        end
      end
    end

    context "without '-'" do
      context 'with blank' do
        let(:formatted_value) do
          ''
        end

        it { should be_empty }
      end

      context 'without blank' do
        let(:formatted_value) do
          'ref_value'
        end

        context 'authorities.abbreviation' do
          subject(:operation) do
            child('authorities.abbreviation')
          end

          context 'Metasploit::Model::Search::Operation::Association#source_operation' do
            subject(:source_operation) {
              operation.source_operation
            }

            it 'uses formatted value for value' do
              expect(source_operation.value).to eq(formatted_value)
            end
          end
        end

        context 'references.designation' do
          subject(:operation) do
            child('references.designation')
          end

          context 'Metasploit::Model::Search::Operation::Association#source_operation' do
            subject(:source_operation) {
              operation.source_operation
            }

            it 'uses formatted value for value' do
              expect(source_operation.value).to eq(formatted_value)
            end
          end
        end

        context 'references.url' do
          subject(:operation) do
            child('references.url')
          end

          context 'Metasploit::Model::Search::Operation::Association#source_operation' do
            subject(:source_operation) {
              operation.source_operation
            }

            it 'uses formatted value for value' do
              expect(source_operation.value).to eq(formatted_value)
            end
          end
        end
      end
    end
  end
end