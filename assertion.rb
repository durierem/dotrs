#frozen_string_literal: true

# module Assertion: provide a basic implementation of assertion validation.
module Assertion

  # class AssertionError: an error indicating a violation of an assertion.
  class AssertionError < StdError
    def initialize(msg = '')
      super("assertion error (#{msg})")
    end
  end

  # check: raise an AssertionError with the message `msg` if and only if
  #        `expresion` is not true.
  def check(expression, msg = '')
    raise AssertionError.new(msg) unless expression
  end
end
