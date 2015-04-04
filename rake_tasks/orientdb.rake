namespace :orientdb do
  desc "Build OrientDb environment"
  task :start do
    run_docker load_container_template('orientdb')
  end

  desc 'Destroy OrientDb environment'
  task :stop do
    remove_if_present "orientdb"
  end
end
