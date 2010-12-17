Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = %q{spree-adyen}
  s.version     = '0.0.1'
  s.summary     = 'Spree Extension that enables payment through the Adyen provider'
  #s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

  s.files        = Dir['CHANGELOG', 'README.markdown', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.30.0.beta1')
end
