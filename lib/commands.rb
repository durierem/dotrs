# frozen_string_literal: true

require_relative 'cmd/add'
require_relative 'cmd/apply'
require_relative 'cmd/diff'
require_relative 'cmd/init'
require_relative 'cmd/list'
require_relative 'cmd/pull'
require_relative 'cmd/push'
require_relative 'cmd/remove'

# Internal: Provide an interface to each of the commands classes.
module Commands
  Add = ::Add
  Apply = ::Apply
  Diff = ::Diff
  Init = ::Init
  List = ::List
  Pull = ::Pull
  Push = ::Push
  Remove = ::Remove
end
