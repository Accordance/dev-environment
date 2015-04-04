require 'pp'
require 'erb'

LOG_LEVEL = ENV['LOG_LEVEL'] || 'INFO'

Dir.glob('rake_tasks/*.rake').each { |r| load r }

def dockerhost
  @boot2docker = @boot2docker || (`boot2docker ip 2> /dev/null`).chomp
  @boot2docker
end

def work_dir
  Dir.pwd
end

def hostip
  @host_ip = @host_ip || (`ifconfig en0 | grep inet | grep 'inet\s' | awk '{print $2}'`).chomp
  @host_ip
end

def validate!
  if $?.to_i == 0
    puts 'OK'
  else
    puts 'Failed'
  end
end

def consul_token(env)
  return $consul_token unless $consul_token.nil?

  consul_file = "consul_token.#{env}"
  $consul_token = File.read(consul_file).chomp
end

def consul_app_secret(app_id)
  File.read("secrets/development/consul_token_#{app_id}")
end

def consul_app_secret_exist?(app_id)
  File.exist?("secrets/development/consul_token_#{app_id}")
end

def consul(env)
  case env.to_sym
  when :development
    "http://#{dockerhost}:8500"
  when :production
    "http://consul01.ctct.net"
  else
    fail "Unknown environment: '#{env}'"
  end
end

def get_kv(env, path)
  url = "#{consul(env)}/v1/kv/#{path}"
  "#{url}?token=#{consul_token(env)}"
end

def register_service(env)
  url = "#{consul(env)}/v1/catalog/register"
  "#{url}?token=#{consul_token(env)}"
end

def consul_uri(env, path)
  url = "#{consul(env)}/v1/#{path}"
  "#{url}?token=#{consul_token(env)}"
end

def get_env(environment)
  env = environment || 'development'
  env.to_sym
end

def if_present(name)
  `docker ps | grep #{name} | awk {'print $1'}`.chomp != ''
end

def remove_if_present(name)
  ps = `docker ps | grep #{name} | awk {'print $1'}`.chomp
  ps.each_line do |line|
    sh("docker kill #{line}") unless line == ''
  end

  ps = `docker ps -a | grep #{name} | awk {'print $1'}`.chomp
  ps.each_line do |line|
    sh("docker rm #{line}") unless line == ''
  end
end

def get_image_id(name)
  `docker images | grep #{name} | awk '{print $3}'`.chomp
end

def get_data(url)
  command = "curl #{url}"
  command += " 2> /dev/null" unless LOG_LEVEL == 'DEBUG'
  puts command if LOG_LEVEL == 'DEBUG'
  result = `#{command}`
  validate!
  puts "Result: #{result}" if LOG_LEVEL == 'DEBUG'
  return result
end

def post_data(url, payload)
  command = "curl -X PUT -d '#{payload}' #{url}"
  command += " 2> /dev/null" unless LOG_LEVEL == 'DEBUG'
  puts command if LOG_LEVEL == 'DEBUG'
  result = `#{command}`
  validate!
  puts "Result: #{result}" if LOG_LEVEL == 'DEBUG'
  return result
end

def create_docker_command(info)
  docker_cmd = ['docker']
  docker_cmd.push info['action'] || 'run -d'
  docker_cmd.push "--name=\"#{info['name']}\""
  docker_cmd.push "--add-host=\"dockerhost:#{dockerhost}\""
  docker_cmd.push "--hostname=\"#{info['hostname']}\"" if info.key? 'hostname' 
  docker_cmd.push info['environment'].map { |k,v| "-e #{k.to_s}=\"#{v}\"" } if info.key? 'environment'
  docker_cmd.push info['ports'].map { |port| "-p #{port}"} if info.key? 'ports'
  docker_cmd.push info['links'].map { |link| "--link #{link}"} if info.key? 'links'
  docker_cmd.push info['volumes_from'].map { |volume| "--volumes-from \"#{volume}\""} if info.key? 'volumes_from'
  docker_cmd.push info['volumes'].map { |volume| "-v \"#{volume}\""} if info.key? 'volumes'
  docker_cmd.push info['image']
  docker_cmd.push info['command'] if info.key? 'command'
  return docker_cmd.join(' ')
end

def run_docker(info)
  command = create_docker_command(info)
  puts command if LOG_LEVEL == 'DEBUG'
  `#{command}` unless if_present(info['name'])
  Array(info['checks']).each do |check|
    try = check['retry'] || 3
    try = try.to_i
    while true
      `#{check['script']}`
      break if $?.to_i == 0
      sleep check['interval'].to_i
      try -= 1
      fail 'Health check failed all retries' if try == 0
    end
  end
end

# Loads only a single/first template from the file
def load_container_template(name)
  container_templates = 'container_templates'
  file_path = File.join(container_templates, "#{name}.yml")
  unless File.exist? file_path
    file_path = File.join(container_templates, "#{name}.erb.yml")
    fail "Can't find container template \"#{name}\"" unless File.exist? file_path
    erb = true
  end
  container_template = YAML.load_file(file_path)
  if erb
    template = ERB.new container_template.to_yaml
    container_template = YAML.load(template.result(binding))
  end

  container_template.each do |template_id, template|
    template['name'] = template_id
    if template.key? 'environment'
      environment = template['environment']
      environment['LOG_LEVEL'] = LOG_LEVEL unless environment.key? 'LOG_LEVEL'
      environment['CONSUL_TOKEN'] = consul_app_secret(template_id) if consul_app_secret_exist? template_id
    end
    return template
  end
end

desc "Build environment"
task :start => [ 'consul:start', 'consul:init', 'registrator:start', 'redis:start' ]

desc 'Destroy environment'
task :stop => [ 'nginx:stop', 'redis:stop', 'registrator:stop', 'consul:stop' ]

desc 'Initialize data'
task :init => []

desc 'Start everything'
task default: [:start, :init, 'nginx:start']
