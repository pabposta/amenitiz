# frozen_string_literal: true

require 'rspec/core/rake_task'

task :test do
  RSpec::Core::RakeTask.new(:spec) do |task|
    task.pattern = 'test/*.rb'
  end
  Rake::Task['spec'].execute
end
