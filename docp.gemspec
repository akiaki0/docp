# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docp/version'

Gem::Specification.new do |spec|
  spec.name          = "docp"
  spec.version       = Docp::VERSION
  spec.authors       = ["akiaki0"]
  spec.email         = ["akiaki0pon@gmail.com"]

  spec.summary       = %q{html table parse gem}
  spec.description   = %q{html table parse gem}
  spec.homepage      = "https://github.com/akiaki0/docp"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency 'minitest-reporters', '1.0.5'
  spec.add_development_dependency 'mini_backtrace',     '0.1.3'
  spec.add_development_dependency 'guard-minitest',     '2.3.1'
end
