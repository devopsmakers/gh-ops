lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gh/ops/version"

Gem::Specification.new do |spec|
  spec.name          = "gh-ops"
  spec.version       = Gh::Ops::VERSION
  spec.authors       = ["Tim Birkett"]
  spec.email         = ["tim.birkett@sainsburys.co.uk"]

  spec.summary       = "A cli for useful Gihub Operations"
  spec.homepage      = "https://github.com/devopsmakers/gh-ops"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency "octokit", "~> 4.14"
  spec.add_dependency "netrc", "~> 0.11.0"
  spec.add_dependency "thor", "~> 0.20.3"
  spec.add_dependency "activesupport", "~> 6.0"
  spec.add_dependency "git", "~> 1.5"
  spec.add_dependency "terminal-table", "~> 1.8"
  spec.add_dependency "rainbow", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
