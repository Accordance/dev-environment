require 'rake'
require 'rake/tasklib'
require 'pathname'
require 'erb'
require 'ostruct'
require_relative 'docker_utils'

module Container
  module Templates

    class RakeTask < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      # Default pattern for template files.
      # DEFAULT_PATTERN        = 'container_templates/**{,/*/**}/*.{yml,yaml}'
      DEFAULT_PATTERN = '**/*.{yml,yaml}'

      DEFAULt_PATH = 'container_templates'

      # Name of task. Defaults to `:container_templates`.
      attr_accessor :name

      # Path to Container templates. Defaults to the absolute path to the
      # relative location of container templates.
      attr_accessor :templates_path

      # Files matching this pattern will be loaded.
      # Defaults to `'**/*.{yml,yaml}'`.
      attr_accessor :pattern

      def initialize(*args, &task_block)
        @name           = args.shift || :container_templates
        @templates_path = DEFAULt_PATH
        @pattern        = DEFAULT_PATTERN

        load_templates @templates_path, @pattern
      end

      private

      def load_templates(path, pattern)
        curr = Pathname.new(Dir.pwd) + path
        # puts "Current: #{curr}"

        FileList[File.join(path, pattern)].each do |f|
          full_path     = File.expand_path(f)
          template_name = Pathname(strip_extension(full_path)).relative_path_from(curr)
          # puts "Found #{template_name}: #{friendly_name(template_name.to_s)}"

          load_template ('container:' + friendly_name(template_name.to_s)), full_path, template_name.to_s
        end
      end

      def strip_extension(filename)
        filename.gsub(/(\.yml|\.yaml|\.erb)/, '')
      end

      def friendly_name(filename)
        filename.gsub(/[^\w\s_-]+/, '_')
          .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
          .gsub(/\s+/, '_')
      end

      def load_template(name, path, template_name, *args)
        args || args = []

        desc "Starting #{template_name}"
        task (name + ":start").to_sym, *args do |_, task_args|
          puts "Starting: #{path}"
          Docker::Utils.start_container load_container_template(path)
        end

        desc "Stopping #{template_name}"
        task (name + ":stop").to_sym, *args do |_, task_args|
          puts "Stopping: #{path}"
          container_template = load_template_file(path)
          Docker::Utils.stop_container container_template
        end
      end

      def load_template_file(file_path)
        puts "Loading #{file_path}" if LOG_LEVEL == 'DEBUG'

        vars = {
          dockerhost: Docker::Utils.dockerhost,
          work_dir: Environment.work_dir,
          hostip: Environment.hostip
        }

        container_template = YAML.load_file(file_path)
        if Pathname.new(file_path).basename.to_s.include? '.erb'
          template           = ERB.new(container_template.to_yaml).result(OpenStruct.new(vars).instance_eval { binding })
          container_template = YAML.load(template)
        end

        return container_template
      end

      def load_container_template(file_path)
        container_template = load_template_file(file_path)

        container_template.each do |template_id, template|
          template['name'] = template_id
          if template.key? 'environment'
            environment                 = template['environment']
            # TODO: simplify this
            environment['LOG_LEVEL']    = LOG_LEVEL unless environment.key? 'LOG_LEVEL'

            # TODO: abstract the Consul token management
            environment['CONSUL_TOKEN'] = Consul.get_app_secret(template_id) if Consul.app_secret_exist? template_id
            puts environment
            environment['CONSUL_URI'] = Consul.consul('development')
          end
          return template
        end
      end
    end

  end
end
