require 'json'
require 'securerandom'

namespace :prepare do
  desc "Prepare development secrets"
  task :secrets do
    token = SecureRandom.uuid
    File.open("consul_token.development", 'w') { |f| f.write(token) }

    consul_config_file_path = '../docker-consul-acl/config/consul.json'
    consul_config_file = File.read(consul_config_file_path)
    consul_config = JSON.parse(consul_config_file)
    consul_config['acl_master_token'] = token
    File.open(consul_config_file_path, 'w') { |f| f.write(JSON.pretty_generate(consul_config)) }
  end
end
