module Environment
  def self.work_dir
    Dir.pwd
  end

  def self.hostip
    @host_ip = @host_ip || (`ifconfig en0 | grep inet | grep 'inet\s' | awk '{print $2}'`).chomp
    @host_ip
  end

  def self.get_env(environment)
    env = environment || 'development'
    env.to_sym
  end

  def self.get_data(url)
    command = "curl #{url}"
    command += " 2> /dev/null" unless LOG_LEVEL == 'DEBUG'
    puts command if LOG_LEVEL == 'DEBUG'
    result = `#{command}`
    validate!
    puts "Result: #{result}" if LOG_LEVEL == 'DEBUG'
    return result
  end

  def self.post_data(url, payload)
    command = "curl -X PUT -d '#{payload}' #{url}"
    command += " 2> /dev/null" unless LOG_LEVEL == 'DEBUG'
    puts command if LOG_LEVEL == 'DEBUG'
    result = `#{command}`
    validate!
    puts "Result: #{result}" if LOG_LEVEL == 'DEBUG'
    return result
  end

  def self.validate!
    if $?.to_i == 0
      puts 'OK' if LOG_LEVEL == 'DEBUG'
    else
      puts 'Failed' if LOG_LEVEL == 'DEBUG'
    end
  end

end