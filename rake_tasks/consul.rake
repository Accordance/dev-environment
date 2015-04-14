require 'json'
require 'yaml'
require_relative '../rake_tasks/lib/dev_environment'
require_relative '../rake_tasks/lib/consul_utils'

namespace :consul do
  task :init, :environment do |t, args|
    # TODO: move this check to the "container checks"
    sleep 2

    env = Environment.get_env(args[:environment])

    apps = []
    Dir.glob('consul_policies/*.yml').each do |path|
      # path = File.join(File.dirname(__FILE__), '..', 'config.yml') unless File.exist?(path)
      raw_config = File.read(path)

      policy_def = YAML.load(raw_config)

      rules_str = ""
      policy_def['rules'].each do |rule|
        description = "    \# #{rule['description']}\n" if rule.has_key?('description')
        if rule.has_key?('key')
          rule = "key \"#{rule['key']}\" {\n#{description}    policy = \"#{rule['policy']}\"\n}\n"
        elsif rule.has_key?('service')
          rule = "service \"#{rule['service']}\" {\n#{description}    policy = \"#{rule['policy']}\"\n}\n"
        else
          fail 'Unknown ACL rule type'
        end
        rules_str += rule
      end

      app_entry = {
        app: policy_def['id'],
        rules: { "Type" => policy_def['type'], "Rules" => rules_str }
      }
      apps.push app_entry
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
    env = get_env(args[:environment])
    command = "curl #{Consul.consul_uri(env, 'acl/list')}"
    puts command
    result = `#{command}`
    puts result
  end

  desc 'Build dev consul'
  task :build_dev_consul do
    # TODO: refactor this into Docker module
    `docker build -t consul_acl ../docker-consul-acl/` if Docker::Utils.get_image_id('consul_acl') == ''
  end

  # Adding prerequisite for Consul creation
  Rake::Task["cntnr_tmplt:consul:start"].enhance ["consul:build_dev_consul"]
end
