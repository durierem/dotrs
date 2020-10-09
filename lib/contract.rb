# frozen_string_literal: true

require_relative 'assertion_error.rb'

# Internal: Provide a way to check contracts.
module Contract
  module_function

  # check: raise an AssertionError with the message `msg` if and only if
  #        `expresion` is not true.
  def check(expression, msg = '')
    raise AssertionError, msg unless expression
  end
end
