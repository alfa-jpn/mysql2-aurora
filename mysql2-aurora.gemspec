lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mysql2/aurora/version'

Gem::Specification.new do |spec|
  spec.name          = 'mysql2-aurora'
  spec.version       = Mysql2::Aurora::VERSION
  spec.authors       = ['alfa-jpn']
  spec.email         = ['alfa.jpn@gmail.com']
  spec.summary       = 'mysql2 plugin supporting aurora failover.'
  spec.description   = 'mysql2 plugin supporting aurora failover.'
  spec.homepage      = 'https://github.com/alfa-jpn/mysql2-aurora'
  spec.license       = 'MIT'
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(/^exe\//) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(/^(test|spec|features)\//) }
  end

  spec.required_ruby_version = '>= 2.4.6'

  spec.add_dependency 'mysql2', '~> 0.5.2'

  spec.add_development_dependency 'bundler',   '>= 1.16'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'pry',       '~> 0.12'
  spec.add_development_dependency 'rake',      '~> 13.0'
  spec.add_development_dependency 'rspec',     '~> 3.0'
  spec.add_development_dependency 'rubocop',   '~> 0.62'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'yard',      '~> 0.9'
end
