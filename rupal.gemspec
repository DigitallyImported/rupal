lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib) 
require 'paypal/version'

Gem::Specification.new do |s|
  s.name        = 'rupal'
  s.version     = PayPal::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = 'Nick Wilson'
  s.email       = 'wilson.nick@gmail.com'
  s.homepage    = 'https://github.com/AudioAddict/rupal'
  s.description = ''
  s.summary     = ''
  
  s.require_path  = 'lib'
  s.files         = Dir.glob("{lib,test}/**/*") + %w(README.md Rakefile)
  
  s.add_dependency 'retryable'
  s.add_dependency 'recursive-open-struct'
end