# frozen_string_literal: true

require 'date'
require_relative 'lib/version.rb'

Gem::Specification.new do |spec|
  spec.name        = 'dotrs'
  spec.version     = Dotrs::VERSION
  spec.date        = Date.today.to_s
  spec.summary     = 'Straighforward dotfiles management'
  spec.description = 'dotrs is a small program to help managing dotfiles ' \
                     'with a GitHub repository.'
  spec.author      = 'Rémi Durieu'
  spec.email       = 'remi.durieu@univ-rouen.fr'
  spec.files       = [
    'bin/dotrs',
    Dir.glob('lib/**/*'),
    'LICENSE',
    'README.md'
  ].flatten
  spec.homepage    = 'https://github.com/Sevodric/dotrs'
  spec.license     = 'MIT'
  spec.executables << 'dotrs'

  spec.add_runtime_dependency 'git', '~> 1.7'
  spec.add_development_dependency 'rubocop', '~> 0.92'
  spec.add_development_dependency 'test-unit', '~> 3.3'
end
