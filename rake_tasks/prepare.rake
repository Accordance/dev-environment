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

    secrets_dir = "secrets/development"
    FileUtils.mkdir_p secrets_dir unless Dir.exists?(secrets_dir)

    active_dir_secret = [
      {
        key:   'active_dir/username',
        value: 'username'
      },
      {
        key:   'active_dir/password',
        value: 'password'
      },
      {
        key:   'active_dir/server',
        value: 'my.domain.com'
      },
      {
        key:   'active_dir/port',
        value: '123'
      },
      {
        key:   'active_dir/base',
        value: 'DC=domain,DC=com'
      },
      {
        key:   'active_dir/domain',
        value: 'domain.com'
      }
    ]
    File.open("#{secrets_dir}/active_dir_secret.json", 'w') { |f| f.write(JSON.pretty_generate(active_dir_secret)) }
  end
end
