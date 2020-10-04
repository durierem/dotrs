#frozen_string_literal: true

# class AssertionError: an error indicating a violation of an assertion.
class AssertionError < ArgumentError
  def initialize(msg = '')
    super(msg)
  end
end
