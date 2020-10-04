#frozen_string_literal: true

require_relative 'assertion_error.rb'

# module Contract: provide a basic implementation of assertion validation.
module Contract
  module_function
  
  # check: raise an AssertionError with the message `msg` if and only if
  #        `expresion` is not true.
  def check(expression, msg = '')
    raise AssertionError.new(msg) unless expression
  end
end
