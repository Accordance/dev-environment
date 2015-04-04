namespace :nginx do
  desc "Build NginX environment"
  task :start do
    run_docker load_container_template('nginx')
    validate!
  end

  desc 'Destroy NginX environment'
  task :stop do
    remove_if_present "nginx"
  end

  desc 'Reload NginX config'
  task :reload do
    `docker kill -s HUP nginx`
  end
end
