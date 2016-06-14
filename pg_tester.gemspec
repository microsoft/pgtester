# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_tester/version'

Gem::Specification.new do |spec|
  spec.name          = "pg_tester"
  spec.version       = PgTester::VERSION
  spec.authors       = ["yann ARMAND", "neeran GUL"]
  spec.email         = ["yarmand@yammer-inc.com", "ngul@yammer-inc.com"]
  spec.license       = "MIT"
  spec.summary       = %q{Runs tests against a temporary postgresql instance}
  spec.description   = %q{Test postgresql scripts and run queries against a temporary postgresql instance}
  spec.homepage      = "https://github.com/Microsoft/pgtester"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_runtime_dependency 'pg', '~> 0.18', '>= 0.18.2'
end
