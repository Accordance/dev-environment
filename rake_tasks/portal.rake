require_relative 'lib/dev_environment'
require_relative 'lib/consul_utils'

namespace :portal do

  desc 'Start all Accordance services'
  task :start => [ 'container:atlas:start'
                 ]

  desc 'Stop all Accordance services'
  task :stop => [ 'container:atlas:stop'
                ]

  desc 'Register a service with Consul'
  task :register, [:environment, :service, :port, :health_check] do |_, args|
    env = Environment.get_env(args[:environment]).to_sym
    service = args[:service]
    port = args[:port]
    health_check = args[:health_check]
    puts "Registering server in env[#{env}]: #{service}:#{port}/#{health_check}"

    case env
    when :local
      if ! service.nil?
        env = :development
        Environment.post_data Consul.register_service(env), "{\"Datacenter\": \"dev\", \"Node\": \"devhost\", \"Address\": \"#{Environment.hostip}\", \"Service\": {\"Service\": \"#{service}\", \"tags\": [\"production\"], \"Port\": #{port}, \"check\": {\"http\": \"#{Environment.hostip}:#{port}/#{health_check}\", \"interval\": \"10s\", \"timeout\": \"1s\"}}}"
      end
    end
  end

  desc 'Deregister a service'
  task :deregister, [:environment, :service] do |_, args|
    env = Environment.get_env(args[:environment]).to_sym
    service = args[:service]

    case env
      when :local
        if ! service.nil?
          env = :development
          Environment.post_data Consul.deregister_service(env), "{\"Datacenter\": \"dev\", \"Node\": \"devhost\", \"ServiceID\": \"#{service}\"}"
        end
    end
  end

  desc 'Register Atlas'
  task :register_atlas do
    Rake::Task['portal:register'].invoke('local', 'atlas', '8080')
  end

  desc "Register secrets"
  task :register_secrets do |_, args|
    env = Environment.get_env(args[:environment])

    secret_file = "secrets/#{env}/orientdb.json"
    puts "Reading secrets from: #{secret_file}"
    file = File.read(secret_file)
    git_secrets = JSON.parse(file)

    git_secrets.each do |secret|
      `curl -v  --trace-ascii /dev/stderr -X PUT -d \"#{secret["value"]}\" #{Consul.get_kv(env, secret["key"])} 2> /dev/null`
      Environment.validate!
    end

  end
end
