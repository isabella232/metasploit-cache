# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metasploit/cache/version'

Gem::Specification.new do |spec|
  spec.name          = "metasploit-cache"
  spec.version       = Metasploit::Cache::VERSION
  spec.authors       = ["Luke Imhoff"]
  spec.email         = ["luke_imhoff@rapid7.com"]
  spec.summary       = "Metasploit Module cache"
  spec.description   = "Cache of Metasploit Module metadata, architectures, platforms, references, and authorities " \
                       "that can persist between reboots of metasploit-framework and Metasploit applications"
  spec.homepage      = "https://github.com/rapid7/metasploit-cache"
  spec.license       = "BSD-3-clause"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w{app/cells app/models app/validators lib}

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency 'metasploit-version', '~> 0.1.3'
  spec.add_development_dependency 'metasploit-yard', '~> 1.0'
  spec.add_development_dependency "rake", "~> 10.0"
  # 0.8.7.4 cannot parse required keyword arguments from Ruby 2.1
  spec.add_development_dependency 'yard', '> 0.8.7.4'
  spec.add_development_dependency 'yard-activerecord', '~> 0.0.14'
  spec.add_development_dependency 'yard-metasploit-erd', '~> 1.0'

  spec.add_runtime_dependency 'activerecord', '>= 4.0.9', '< 4.1.0'
  spec.add_runtime_dependency 'awesome_nested_set'
  spec.add_runtime_dependency 'file-find'
  # Allow patching of Metasploit::Cache models.
  spec.add_runtime_dependency 'metasploit-concern', '~> 1.0'
  spec.add_runtime_dependency 'metasploit-model', '~> 1.0'
  spec.add_runtime_dependency 'ruby-progressbar', '~> 1.7'
  spec.add_runtime_dependency 'thor', '~> 0.19.1'
  spec.add_runtime_dependency 'transaction_isolation', '> 1.0.4', '< 2'
  spec.add_runtime_dependency 'transaction_retry', '~> 1.0'
end
