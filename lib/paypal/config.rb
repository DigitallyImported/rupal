require 'yaml'
require 'recursive-open-struct'

module PayPal
  class << self
    
    def default_log_file
      path = File.join(ROOT, 'log')
      path = '.' unless File.directory?(path)
      File.expand_path(File.join(path, "#{LOG_PREFIX}-#{ENV}.log"))
    end
    
    def config_file
      File.expand_path(File.join(ROOT, 'config', CONFIG_NAME))
    end
  
    def load_config_file(file = nil)
      raise "Cannot load configuration file '#{file}'" if file and !File.readable?(file)
      
      file ||= config_file
      begin
        config = ::RecursiveOpenStruct.new(YAML.load_file(file)[ENV])
      rescue Errno::ENOENT
        config = ::RecursiveOpenStruct.new
      end
      
      set_defaults(config)
    end
    
    def set_defaults(config)
      config.dry_run ||= false
      config.retries ||= 3
      config.timeout ||= 60
      config.log_file ||= default_log_file
      config
    end
    
    def config(file = nil)
      @config ||= load_config_file(file)
      yield @config if block_given?
      @config
    end
  end
end