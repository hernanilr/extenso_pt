# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'extenso_pt/version'

Gem::Specification.new do |spec|
  spec.name          = 'extenso_pt'
  spec.version       = ExtensoPt::VERSION
  spec.authors       = ['Hernâni Rodrigues Vaz']
  spec.email         = ['hernanirvaz@gmail.com']

  spec.summary       = 'Produz valores monetários por extenso em portugês de portugal ou brasil.'
  spec.description   = spec.summary + ' Os valores podem ser um numerico, uma string de digitos ou um conjunto destes (array, range, hash). O extenso pode ser produzido na escala longa (utilizada em todos os países lusófonos) ou na escala curta (utilizada no Brasil). Pode ainda escolher a moeda e a fração da moeda.'

  spec.homepage      = 'https://github.com/hernanilr/extenso_pt'
  spec.license       = 'MIT'

  spec.metadata['yard.run'] = 'yard' # use "yard" to build full HTML docs.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bigdecimal', '~> 1.4.4'
  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
