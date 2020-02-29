lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "simple_dsl_parser/version"

Gem::Specification.new do |spec|
  spec.name          = "simple_dsl_parser"
  spec.version       = SimpleDslParser::VERSION
  spec.authors       = ["xiongzenghui"]
  spec.email         = ["zxcvb1234001@163.com"]

  spec.summary       = 'a simple DSL Parser'
  spec.description   = 'a simple DSL Parser'
  spec.homepage      = "https://github.com/xzhhe/simple_dsl_parser"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
