
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ps_utilities/version"

Gem::Specification.new do |spec|
  spec.name          = "ps_utilities"
  spec.version       = PsUtilities::Version::VERSION
  spec.authors       = ["Lee Weisbecker","Bill Tihen"]
  spec.email         = ["leeweisbecker@gmail.com", 'btihen@gmail.com']

  spec.summary       = %q{Simple ruby wrapper for Powerschool API interaction.}
  spec.description   = %q{Uses oauth2 to connection to the Powerschool API. Heavily refactored code (not dependent on Rails) starting with: https://github.com/TomK32/powerschool}
  spec.homepage      = "https://github.com/LAS-IT/ps_utilities"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  # spec.require_paths = ["lib"]
  spec.files = Dir['lib/**/*.rb']

  spec.add_dependency "httparty", '~> 0.18'

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "webmock", "~> 3.8"
end
