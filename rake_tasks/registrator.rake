namespace :registrator do
  desc "Build Registrator environment"
  task :start do
    run_docker load_container_template('registrator')
  end

  desc 'Destroy Registrator environment'
  task :stop do
    remove_if_present "registrator"
  end
end
