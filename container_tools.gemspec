$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "container-tools"
  s.version     = '0.1'
  s.authors     = ["Cloud Foundry Team"]
  s.email       = %w(cf-eng@pivotallabs.com)
  s.homepage    = "http://github.com/cloudfoundry/container_tools"
  s.summary     = %q{
   Tools to create a container
  }
  s.files         = %w(LICENSE Rakefile) + Dir["lib/**/*"]
  s.license       = "Apache 2.0"
  s.test_files    = Dir["spec/**/*"]
  s.require_paths = %w(lib)

  s.add_dependency "em-warden-client"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", ">2.14"
end

