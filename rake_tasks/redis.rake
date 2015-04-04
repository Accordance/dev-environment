namespace :redis do
  desc "Build redis environment"
  task :start do
    run_docker load_container_template('redis')
  end

  desc 'Destroy Redis environment'
  task :stop do
    remove_if_present "redis.0"
  end
end
