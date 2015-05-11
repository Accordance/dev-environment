LOG_LEVEL = ENV['LOG_LEVEL'] || 'INFO'

require_relative 'rake_tasks/lib/container_template'
Container::Templates::RakeTask.new(:container_templates)

Dir.glob('rake_tasks/*.rake').each { |r| load r }

desc "Build environment"
task :start => ['container:consul:start',
                'consul:init',
                'secrets:configure',
                'container:registrator:start',
                'container:redis:start',
                'container:orientdb:start',
                'portal:start',
                'container:nginx:start']

desc 'Destroy environment'
task :stop => ['container:nginx:stop',
               'portal:stop',
               'container:orientdb:stop',
               'container:nginx:stop',
               'container:redis:stop',
               'container:registrator:stop',
               'container:consul:stop']

desc 'Initialize data'
task :init => [ 'orientdb:init' ]

desc 'Start everything'
task default: [:start, :init, 'container:nginx:start']
