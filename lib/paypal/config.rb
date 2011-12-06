require 'yaml'
require 'ostruct'

module PayPal
  
  class RecursiveOpenStruct < OpenStruct
    def new_ostruct_member(name)
      name = name.to_sym
      unless self.respond_to?(name)
        class << self; self; end.class_eval do
          define_method(name) {
            v = @table[name]
            v.is_a?(Hash) ? RecursiveOpenStruct.new(v) : v
          }
          define_method("#{name}=") { |x| modifiable[name] = x }
          define_method("#{name}_as_a_hash") { @table[name] }
        end
      end
      name
    end
  end
  
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
        config = RecursiveOpenStruct.new(YAML.load_file(file)[ENV])
      rescue Errno::ENOENT
        config = RecursiveOpenStruct.new
      end
      
      set_defaults(config)
    end
    
    def set_defaults(config)
      config.dry_run ||= false
      config.retries ||= 3
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