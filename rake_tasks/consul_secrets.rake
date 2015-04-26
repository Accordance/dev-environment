require 'json'
require 'securerandom'
require 'pp'

namespace :secrets do
  desc "Configure secrets in Consul"
  task :configure, [:environment] do |_, args|
    env = Environment.get_env(args[:environment]).to_sym

    secrets = get_secrets(env)

    secrets.each do |secret|
      puts "Registering secret '#{secret["key"]}'"
      Consul.set_kv(env, secret["key"], secret["value"])
    end
  end

  def get_secrets(env)
    secrets_dir = "secrets/#{env}"
    FileUtils.mkdir_p secrets_dir unless Dir.exist?(secrets_dir)

    mask = "#{secrets_dir}/*_secret.json"

    result = []
    Dir.glob(mask) do |file|
      secret_content = File.read(file)
      secret = JSON.parse(secret_content)
      secret.each do |entry|
        result.push entry
      end
    end

    result
  end
end
