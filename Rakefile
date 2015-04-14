LOG_LEVEL = ENV['LOG_LEVEL'] || 'INFO'

require_relative 'rake_tasks/lib/container_template'
Container::Templates::RakeTask.new(:container_templates)

Dir.glob('rake_tasks/*.rake').each { |r| load r }

desc "Build environment"
task :start => ['cntnr_tmplt:consul:start',
                'consul:init',
                'cntnr_tmplt:registrator:start',
                'cntnr_tmplt:redis:start',
                'cntnr_tmplt:orientdb:start']

desc 'Destroy environment'
task :stop => ['cntnr_tmplt:orientdb:stop',
               'cntnr_tmplt:nginx:stop',
               'cntnr_tmplt:redis:stop',
               'cntnr_tmplt:registrator:stop',
               'cntnr_tmplt:consul:stop']

desc 'Initialize data'
task :init => []

desc 'Start everything'
task default: [:start, :init, 'cntnr_tmplt:nginx:start']
