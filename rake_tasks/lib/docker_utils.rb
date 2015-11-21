module Docker
  class Utils

    def self.dockerhost
      @boot2docker = @boot2docker || ENV['DOCKERHOST'] || (`boot2docker ip 2> /dev/null`).strip
      @boot2docker
    end

    def self.create_docker_command(info)
      docker_cmd = ['docker']
      docker_cmd.push info['action'] || 'run -d'
      docker_cmd.push "--name=\"#{info['name']}\""
      docker_cmd.push "--add-host=\"dockerhost:#{dockerhost}\""
      docker_cmd.push "--hostname=\"#{info['hostname']}\"" if info.key? 'hostname'
      docker_cmd.push info['environment'].map { |k, v| "-e #{k.to_s}=\"#{v}\"" } if info.key? 'environment'
      docker_cmd.push info['ports'].map { |port| "-p #{port}" } if info.key? 'ports'
      docker_cmd.push info['links'].map { |link| "--link #{link}" } if info.key? 'links'
      docker_cmd.push info['volumes_from'].map { |volume| "--volumes-from \"#{volume}\"" } if info.key? 'volumes_from'
      docker_cmd.push info['volumes'].map { |volume| "-v \"#{volume}\"" } if info.key? 'volumes'
      docker_cmd.push info['image']
      docker_cmd.push info['command'] if info.key? 'command'
      return docker_cmd.join(' ')
    end

    def self.stop_container(container_template)

      container_template.each do |template_id, _|
        name = template_id
        containers = `docker ps`
        ps = containers_by_name(name)
        ps.each do |line|
          if line != ''
            cmd = "docker kill #{line}"
            puts cmd if LOG_LEVEL == 'DEBUG'
            `#{cmd}`
          end
        end

        ps = containers_by_name(name)
        ps.each do |line|
          if line != ''
            cmd = "docker rm #{line}"
            puts cmd if LOG_LEVEL == 'DEBUG'
            `#{cmd}`
          end
        end
      end
    end

    def self.start_container(info)
      command = create_docker_command(info)
      puts command if LOG_LEVEL == 'DEBUG'
      if present?(info['name'])
        puts 'Detected it as running. Skipping ....' if LOG_LEVEL == 'DEBUG'
      else
        `#{command}`
      end
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

    def self.present?(name)
      ! containers_by_name(name).empty?
    end

    def self.containers_by_name(name)
      # `docker ps -a | grep #{name} | awk {'print $1'}`.chomp
      containers = `docker ps -a`
      ps = []
      containers.each_line { |line| if line.include?(name) then ps << line.strip.partition(" ").first end }
      ps
    end

    def self.get_image_id(name)
      # `docker images | grep #{name} | awk '{print $3}'`.chomp
      images = `docker images`
      img = []
      images.each_line { |line| if line.include?(name) then img << line.strip.partition(" ").first end }
      img.first
    end

  end
end
