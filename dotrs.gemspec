# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |s|
  s.name        = 'dotrs'
  s.version     = Dotrs::VERSION
  s.summary     = 'Straighforward dotfiles management'
  s.description = 'Dotrs helps managing dotfiles with a GitHub repository.'
  s.author      = 'Rémi Durieu'
  s.homepage    = 'https://github.com/durierem/dotrs'
  s.license     = 'MIT'
  s.email       = 'remi.durieu@univ-rouen.fr'
  s.files       = [
    'bin/dotrs',
    Dir.glob('lib/**/*'),
    'LICENSE',
    'README.md'
  ].flatten
  s.executables << 'dotrs'

  s.required_ruby_version = '>= 2.7'

  s.add_runtime_dependency 'git', '~> 1.7'
  s.add_runtime_dependency 'toml-rb', '~> 2.0'
  s.add_runtime_dependency 'tty-tree', '~> 0.4'

  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rubocop', '~> 0.92'
end
