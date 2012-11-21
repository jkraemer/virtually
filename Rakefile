require "bundler"
Bundler.setup

require 'rake/testtask'

desc 'Test the library.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test' << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task :default => :test

gemspec = eval(File.read("virtually.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["virtually.gemspec"] do
  system "gem build virtually.gemspec"
  system "gem install virtually-#{Virtually::VERSION}.gem"
end
