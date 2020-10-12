# frozen_string_literal: true

require_relative 'lib/version.rb'

Gem::Specification.new do |spec|
  spec.name        = 'dotrs'
  spec.version     = Dotrs::VERSION
  spec.date        = '2020-10-10'
  spec.summary     = 'Straighforward dotfiles management'
  spec.description = 'Straighforward dotfiles management'
  spec.author      = 'Rémi Durieu'
  spec.email       = 'remi.durieu@univ-rouen.fr'
  spec.files       = [
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
