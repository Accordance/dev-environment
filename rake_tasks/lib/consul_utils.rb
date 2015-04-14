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
        "http://consul01.ctct.net"
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

end