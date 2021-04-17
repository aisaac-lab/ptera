# frozen_string_literal: true

require_relative "lib/ptera/version"

Gem::Specification.new do |spec|
  spec.name          = "ptera"
  spec.version       = Ptera::VERSION
  spec.authors       = ["aisaac"]
  spec.email         = ["no@aisaac.jp"]

  spec.summary       = %q{simple}
  spec.description   = %q{simple}
  spec.homepage      = "https://aisaac.jp"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'capybara'
  spec.add_dependency 'selenium-webdriver'
end
