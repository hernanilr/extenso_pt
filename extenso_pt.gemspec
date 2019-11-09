# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'extenso_pt/version'

Gem::Specification.new do |spec|
  spec.name          = 'extenso_pt'
  spec.version       = ExtensoPt::VERSION
  spec.authors       = ['Hernâni Rodrigues Vaz']
  spec.email         = ['hernanirvaz@gmail.com']
  spec.homepage      = 'https://github.com/hernanilr/extenso_pt'
  spec.license       = 'MIT'

  spec.summary = 'Produz extenso em portugês de portugal, brasil '\
    'ou numeracao romana.'
  spec.description = spec.summary
  spec.description += ' Os valores podem ser um numerico, uma string de '\
    'digitos ou um conjunto destes agrupados em (array, range, hash). '\
    'O extenso pode ser produzido na escala longa (utilizada em todos os '\
    'países lusófonos) ou na escala curta (utilizada no Brasil). Pode ainda '\
    'produzir numeracao romana e vice versa.'

  spec.metadata['yard.run'] = 'yard' # use "yard" to build full HTML docs.
  spec.metadata['homepage_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject \
      { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'bigdecimal', '~> 1.4.4'
end
