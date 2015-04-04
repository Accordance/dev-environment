require 'json'
require 'yaml'

namespace :consul do
  desc "Build Consul environment"
  task :start => [ :build_dev_consul ] do
    run_docker load_container_template('consul')
    #  -e "SERVICE_TAGS=master,backups" -e "SERVICE_REGION=us2"
  end

  desc 'Destroy Consul environment'
  task :stop do
    remove_if_present "consul"
  end

  task :init, :environment do |t, args|
    env = get_env(args[:environment])

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

    puts apps

    secrets_dir = "secrets/#{env}"
    FileUtils.mkdir_p secrets_dir unless Dir.exists?(secrets_dir)
    apps.each do |app|
      token = register_token(env, app[:app], app[:rules])
      dir_name = "../#{app[:app]}"
      File.open("#{secrets_dir}/consul_token_#{app[:app]}", 'w') { |f| f.write(token) }
      next unless Dir.exists?(dir_name)
      File.open("#{dir_name}/consul_token.#{env}", 'w') { |f| f.write(token) }
    end
  end

  def register_token(env, name, rules)
    result = get_data(consul_uri(env, 'acl/list'))
    list = JSON.parse(result)
    list.each do |item|
      return item['ID'] if item['Name'] == name && item['Name'] != 'anonymous'
    end
    puts "Registering '#{name}' token"
    rules['Name'] = name
    if name == 'anonymous'
      rules['ID'] = 'anonymous'
      token_id = post_data(consul_uri(env, 'acl/update'), JSON.generate(rules))
    else
      token_id = post_data(consul_uri(env, 'acl/create'), JSON.generate(rules))
    end
    JSON.parse(token_id)['ID']
  end

  desc 'List all Consul tokens'
  task :list_tokens, :environment do |_, args|
    env = get_env(args[:environment])
    command = "curl #{consul_uri(env, 'acl/list')}"
    puts command
    result = `#{command}`
    puts result
  end

  desc 'Test dev consul'
  task :test do
  end

  desc 'Build dev consul'
  task :build_dev_consul do
    `docker build -t consul_acl ../docker-consul-acl/` if get_image_id('consul_acl') == ''
  end
end
