require 'json'
require 'yaml'
require_relative 'lib/dev_environment'
require_relative 'lib/consul_utils'

namespace :consul do
  desc 'Initialize Consul Policies and Secrets'
  task :init, :environment do |t, args|
    # TODO: move this check to the "container checks"
    sleep 2

    env = Environment.get_env(args[:environment])

    apps = []
    Dir.glob('consul_policies/*.yml').each do |path|
      # path = File.join(File.dirname(__FILE__), '..', 'config.yml') unless File.exist?(path)
      policy = Consul.load_policy(path)
      apps.push policy
    end

    secrets_dir = "secrets/#{env}"
    FileUtils.mkdir_p secrets_dir unless Dir.exist?(secrets_dir)
    apps.each do |app|
      token = register_token(env, app[:app], app[:rules])
      dir_name = "../#{app[:app]}"
      File.open("#{secrets_dir}/consul_token_#{app[:app]}", 'w') { |f| f.write(token) }
      next unless Dir.exist?(dir_name)
      File.open("#{dir_name}/consul_token.#{env}", 'w') { |f| f.write(token) }
    end
  end

  def register_token(env, name, rules)
    result = Environment.get_data(Consul.consul_uri(env, 'acl/list'))
    list = JSON.parse(result)
    list.each do |item|
      return item['ID'] if item['Name'] == name && item['Name'] != 'anonymous'
    end
    puts "Registering '#{name}' token"
    rules['Name'] = name
    if name == 'anonymous'
      rules['ID'] = 'anonymous'
      token_id = Environment.post_data(Consul.consul_uri(env, 'acl/update'), JSON.generate(rules))
    else
      token_id = Environment.post_data(Consul.consul_uri(env, 'acl/create'), JSON.generate(rules))
    end
    JSON.parse(token_id)['ID']
  end

  desc 'List all Consul tokens'
  task :list_tokens, :environment do |_, args|
    env = Environment.get_env(args[:environment])

    result = Environment.get_data(Consul.consul_uri(env, 'acl/list'))
    puts result
  end

  desc 'Build dev consul'
  task :build_dev_consul do
    # TODO: refactor this into Docker module
    `docker build -t consul_acl ../docker-consul-acl/` if Docker::Utils.get_image_id('consul_acl') == ''
  end

  # Adding prerequisite for Consul creation
  Rake::Task['container:consul:start'].enhance ['consul:build_dev_consul']
end
