require 'rubygems'
require 'bundler/gem_tasks'

# ----- Utility Functions -----

def scope(path)
  File.join(File.dirname(__FILE__), path)
end

# ----- Default: Testing -----

task :default => :test

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  test_files = FileList[scope('test/test_*.rb')]
  t.test_files = test_files
  t.verbose = true
end
