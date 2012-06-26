# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler2'

Jeweler::Tasks.new do |gem|
  gem.name = "delayed_job_ironmq"
  gem.homepage = "https://github.com/thousandsofthem/delayed_job_ironmq"
  gem.description = %Q{IronMQ backend for delayed_job}
  gem.summary = %Q{IronMQ backend for delayed_job}
  gem.email = "info@iron.io"
  gem.authors = ["Alexander Shapiotko", "Iron.io, Inc"]
  gem.files.exclude('.gitignore', 'Gemfile', 'Gemfile.lock', 'Rakefile', 'delayed_job_ironmq.gemspec')
end

Jeweler::RubygemsDotOrgTasks.new