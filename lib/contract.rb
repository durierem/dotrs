# frozen_string_literal: true

# Internal: Provide a way to check contracts.
module Contract
  module_function

  # Internal: Provide an error indicating the violation of an assertion.
  class AssertionError < ArgumentError
    # Internal: Initialize a new AssertionError.
    #
    # message - The String message associated with the error (default: '').
    def initialize(message = '')
      super(message)
    end
  end

  # Internal: Raise an AssertionError if the given expression is not true.
  #
  # expression - The expression to evaluate.
  # message - The String message attached to the AssertionError (default: '').
  #
  # Returns nothing.
  def check(expression, message = '')
    raise AssertionError, message unless expression
  end
end
