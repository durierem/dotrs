# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name        = 'dotrs'
  spec.version     = Dotrs::VERSION
  spec.summary     = 'Straighforward dotfiles management'
  spec.description = 'Dotrs helps managing dotfiles with a GitHub repository.'
  spec.author      = 'Rémi Durieu'
  spec.homepage    = 'https://github.com/Sevodric/dotrs'
  spec.license     = 'MIT'
  spec.email       = 'remi.durieu@univ-rouen.fr'
  spec.files       = [
    'bin/dotrs',
    Dir.glob('lib/**/*'),
    'LICENSE',
    'README.md'
  ].flatten
  spec.executables << 'dotrs'

  spec.required_ruby_version = '~> 2.7'

  spec.add_runtime_dependency 'git', '~> 1.7'
  spec.add_runtime_dependency 'toml-rb', '~> 2.0'
  spec.add_runtime_dependency 'tty-tree', '~> 0.4'

  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rubocop', '~> 0.92'
end
