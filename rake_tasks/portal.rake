namespace :portal do

  desc 'Register a service with Consul'
  task :init, [:environment, :service, :port, :health_check] do |t, args|
    env = get_env(args[:environment])
    puts env
    service = args[:service]
    port = args[:port]
    health_check = args[:health_check]
    puts "#{service}:#{port}/#{health_check}"

    case env
    when :local
      if ! service.nil?
        env = :development
        post_data register_service(env), "{\"Datacenter\": \"dev\", \"Node\": \"devhost\", \"Address\": \"#{hostip}\", \"Service\": {\"Service\": \"#{service}\", \"tags\": [\"production\"], \"Port\": #{port}, \"check\": {\"http\": \"#{hostip}:#{port}/#{health_check}\", \"interval\": \"10s\", \"timeout\": \"1s\"}}}"
      end
    end
  end
end
