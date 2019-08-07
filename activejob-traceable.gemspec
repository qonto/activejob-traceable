# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activejob/traceable/version'

Gem::Specification.new do |spec|
  spec.name          = 'activejob-traceable'
  spec.version       = ActiveJob::Traceable::VERSION
  spec.authors       = ['Dmytro Zakharov']
  spec.email         = ['dmytro@qonto.eu']

  spec.summary       = 'Patches ActiveJob to add trace_id attribute.'
  spec.homepage      = 'https://github.com/qonto/activejob-traceable'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activejob'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.8'
end
