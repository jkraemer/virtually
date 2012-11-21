# encoding: utf-8

require File.expand_path("../lib/virtually/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "virtually"
  s.version     = Virtually::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jens Krämer"]
  s.email       = ["jk@jkraemer.net"]
  s.homepage    = "http://github.com/jkraemer/virtually"
  s.summary     = "High level API for libvirt"
  s.description = "Manage your libvirt based infrastructure with Ruby"

  s.required_rubygems_version = ">= 1.3.6"

  # lol - required for validation
  s.rubyforge_project         = "virtually"

  # If you have other dependencies, add them here
  s.add_dependency "ruby-libvirt", "~> 0.4.0"
  s.add_dependency "nokogiri"
  s.add_dependency "net-ssh"
  s.add_dependency "net-scp"

  s.add_dependency "test-unit"

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'

  # If you need an executable, add it here
  # s.executables = ["libvirt-hl"]

  # If you have C extensions, uncomment this line
  # s.extensions = "ext/extconf.rb"
end
