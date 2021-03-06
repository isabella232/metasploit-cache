require 'rspec/matchers'

# @note Matchers defined with `RSpec::Matchers.define` should be defined in `spec/support/matchers`.
#
# Namespace for custom RSpec matchers that are classes instead of defined using the `RSpec::Matchers.define` DSL.
module Metasploit::Cache::Spec::Matcher
  # Matches that the given `expect { }` raises an exception that the record is not unique based on the current adapter.
  #
  # @return [RSpec::Matchers::Builtin::RaiseError]
  def raise_record_not_unique
    RSpec::Matchers::BuiltIn::RaiseError.new do |error|
      adapter = ActiveRecord::Base.connection_config[:adapter]

      # Has to be marked nocov as only one when/else will be tested on each branch and the else will only be covered if
      # there is a build configuration error
      # :nocov:
      case adapter
      when "postgresql"
        expect(error).to be_an ActiveRecord::RecordNotUnique
      when "sqlite3"
        expect(error).to be_an ActiveRecord::StatementInvalid

        cause = error.cause

        expect(cause).to be_a SQLite3::ConstraintException
        # Local and travis-ci sqlite appear to return different mesages, so support both.
        expect(cause.message).to start_with('UNIQUE constraint failed').or(
                                     match_regex(/column(s .* are| .* is) not unique/)
                                 )
      else
        raise ArgumentError, "Expected error for #{adapter.inspect} adapter unknown"
      end
      # :nocov:
    end
  end
end