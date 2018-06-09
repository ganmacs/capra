
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capra/version'

Gem::Specification.new do |spec|
  spec.name          = 'capra'
  spec.version       = Capra::VERSION
  spec.authors       = ['ganmacs']
  spec.email         = ['ganmacs@gmail.com']

  spec.summary       = 'TCP load balancer'
  spec.description   = 'TCP load balancer'
  spec.homepage      = 'https://github.com/ganmacs/capra'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'serverengine', '~> 2.0.6'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
