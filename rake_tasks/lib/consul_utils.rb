require_relative 'docker_utils'

module Consul
  def self.consul_uri(env, path)
    url = "#{consul(env)}/v1/#{path}"
    "#{url}?token=#{consul_token(env)}"
  end

  def self.consul(env)
    case env.to_sym
      when :development
        "http://#{Docker::Utils.dockerhost}:8500"
      when :production
        'http://consul01.ctct.net'
      else
        fail "Unknown environment: '#{env}'"
    end
  end

  def self.consul_token(env)
    return $consul_token unless $consul_token.nil?

    consul_file = "consul_token.#{env}"
    $consul_token = File.read(consul_file).chomp
  end

  def self.get_app_secret(app_id)
    File.read("secrets/development/consul_token_#{app_id}")
  end

  def self.app_secret_exist?(app_id)
    File.exist?("secrets/development/consul_token_#{app_id}")
  end

  def self.register_service(env)
    url = "#{consul(env)}/v1/catalog/register"
    "#{url}?token=#{consul_token(env)}"
  end

  def self.deregister_service(env)
    url = "#{consul(env)}/v1/catalog/deregister"
    "#{url}?token=#{consul_token(env)}"
  end

  def self.get_kv(env, path)
    url = "#{consul(env)}/v1/kv/#{path}"
    "#{url}?token=#{consul_token(env)}"
  end

  def self.set_kv(env, path, value)
    command = "curl -v  --trace-ascii /dev/stderr -X PUT -d \"#{value}\" #{Consul.get_kv(env, path)} 2> /dev/null"
    puts command if LOG_LEVEL == 'DEBUG'
    `#{command}`
    Environment.validate!
  end

  def self.load_policy(path)
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

    {
      app: policy_def['id'],
      rules: { "Type" => policy_def['type'], "Rules" => rules_str }
    }
  end
end
