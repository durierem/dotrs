# frozen_string_literal: true

require_relative 'assertion_error'

# Internal: Provide a way to check contracts.
module Contract
  module_function

  # Internal: Raise an AssertionError if the given expression is not true.
  #
  # expression - The expression to evaluate.
  # (optional) message - The error message associated.
  #
  # Returns nothing.
  def check(expression, message = '')
    raise AssertionError, message unless expression
  end
end
