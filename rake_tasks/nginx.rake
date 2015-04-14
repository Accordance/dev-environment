namespace :nginx do
  desc 'Reload NginX config'
  task :reload do
    `docker kill -s HUP nginx`
  end
end
