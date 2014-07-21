# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apihub/lead_score/version'

Gem::Specification.new do |spec|
  spec.name          = "apihub-leadscore"
  spec.version       = APIHub::LeadScore::VERSION
  spec.authors       = ["Alex MacCaw"]
  spec.email         = ["alex@apihub.co"]
  spec.summary       = %q{Score email addresses}
  spec.homepage      = "https://apihub.co"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_dependency "apihub", "~> 0.0.5"
  spec.add_dependency "awesome_print"
end
