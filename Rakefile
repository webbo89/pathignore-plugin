require 'rake'
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = false
end

RDoc::Task.new

task :default => :test
