LOG_LEVEL = ENV['LOG_LEVEL'] || 'INFO'
puts "Enabled DEBUG log output" if LOG_LEVEL == "DEBUG"

require_relative 'rake_tasks/lib/container_template'
Container::Templates::RakeTask.new(:container_templates)

Dir.glob('rake_tasks/*.rake').each { |r| load r }

desc "Build environment"
task start: [ 'container:consul:start',
              'consul:init',
              'secrets:configure',
              'container:registrator:start',
              'container:redis:start',
              'container:orientdb:start',
              'container:mongo:start',
              'portal:start',
              'container:nginx:start' ]

desc 'Destroy environment'
task stop:  [ 'container:nginx:stop',
              'portal:stop',
              'container:mongo:stop',
              'container:orientdb:stop',
              'container:nginx:stop',
              'container:redis:stop',
              'container:registrator:stop',
              'container:consul:stop' ]

desc 'Initialize data'
task init: [ 'orientdb:init', 'mongodb:init' ]

desc 'Start everything'
task default: [:start, :init]

desc 'host_os'
task :host_os do
  require 'rbconfig'

  puts host_os = RbConfig::CONFIG['host_os']
end
