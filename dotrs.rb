#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'src/global.rb'
require_relative 'src/actions.rb'

## TODO:
# => Backup the original dotfiles before overwriting them
# => Use FileUtils instead of calls to system
# => Use Git or Rugged (gems) to handle git operations
# => Use the name of the user repo instead of forcing '.dotfiles'
# => Create missing directories when applying

Global.parse_options

# Display version number if asked
if Global.options.include?(:version)
  puts "dotrs #{Global::VERSION}"
  exit
end

Actions.add if Global.options.include?(:add)
Actions.remove if Global.options.include?(:remove)
Actions.save if Global.options.include?(:save)
Actions.apply if Global.options.include?(:apply)
Actions.push if Global.options.include?(:push)
Actions.pull if Global.options.include?(:pull)
