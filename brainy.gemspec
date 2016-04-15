require_relative 'lib/brainy/version'

Gem::Specification.new do |s|
  s.name        = 'brainy'
  s.version     = Brainy::VERSION
  s.license     = 'MIT'
  s.summary     = 'An Artificial Neural Network'
  s.description = 'Brainy is an Artificial Neural Network (ANN) using the Backpropagation algorithm.'
  s.author      = 'Robert Scott Reis'
  s.email       = 'reis.robert.s@gmail.com'
  s.files       = Dir['{lib,spec}/**/*', 'README.md', 'LICENSE']
  s.homepage    = 'https://github.com/EvilScott/brainy'
  s.platform    = 'java'
  s.add_development_dependency 'rspec', ['~> 3.2']
  s.add_development_dependency 'rake', ['~> 10.4']
end
