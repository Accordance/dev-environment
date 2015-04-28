namespace :orientdb do
  desc 'Load Graph data'
  task :init, :environment do |_, args|
    env = Environment.get_env(args[:environment])
    puts env

    case env
    when :development
      run_task "bundle exec rake orientdb:create[#{Docker::Utils.dockerhost}]"
      run_task "bundle exec rake orientdb:create_schema[#{Docker::Utils.dockerhost}]"
      run_task "bundle exec rake data_graph:import[#{Docker::Utils.dockerhost}]"
    end
  end

  desc 'Load Graph data'
  task :drop, :environment do |_, args|
    env = Environment.get_env(args[:environment])
    puts env

    case env
    when :development
      run_task "bundle exec rake orientdb:drop[#{Docker::Utils.dockerhost}]"
    end
  end

  def run_task(command)
    Dir.chdir("../data-source") do
      pwd = Dir.pwd
      puts "In folder #{pwd}"

      pid = fork { system(command) }
      _, status = Process.waitpid2(pid)
    end
  end
end
