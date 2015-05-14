namespace :mongodb do
  desc 'Load Documents data'
  task :init, :environment do |_, args|
    env = Environment.get_env(args[:environment])
    puts env

    case env
    when :development
      run_task "bundle exec rake mongo:create[#{Docker::Utils.dockerhost}]"
    end
  end

  desc 'Drop Documents data'
  task :drop, :environment do |_, args|
    env = Environment.get_env(args[:environment])
    puts env

    case env
    when :development
      run_task "bundle exec rake mongo:drop[#{Docker::Utils.dockerhost}]"
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
