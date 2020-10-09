# frozen_string_literal: true

# Internal: Provide an error indicating the violation of an assertion.
class AssertionError < ArgumentError
  def initialize(msg = '')
    super(msg)
  end
end
