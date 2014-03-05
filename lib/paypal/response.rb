require 'date'

module PayPal
  class Response
    
    attr_accessor :ack, :correlation_id, :timestamp, :version, :build, :dry_run
    
    def initialize(response_data, dry_run = false)
      @dry_run = dry_run
      if @dry_run
        @ack = 'Success'
        @correlation_id = ''
        @timestamp = DateTime.now
        @version = PayPal.config.version
        @build = ''
      else
        parse_response response_data
      end
    end
  
    def success
      ack == 'Success' || ack == 'SuccessWithWarning'
    end
    alias :success? :success
    
    def failure
      ack == 'Failure' || ack == 'FailureWithWarning'
    end
    
    alias :failure? :failure
    
    def with_warning
      !! ack.match(/WithWarning$/)
    end
    alias :with_warning? :with_warning
    
    def data
      @data ||= {}
    end
    
    def errors
      @errors ||= []
    end
    
    def has_error_code?(code)
      errors.each { |e| return true if e.code.to_s == code.to_s }
      false
    end
    
    protected
    
    def parse_response(response_data)
      PayPal.log.debug 'Parsing response data...'
      @data = parse response_data
      raise ResponseError.new 'Invalid response from server' unless @data.include? :ack
      
      @ack = @data.delete :ack
      @correlation_id = @data.delete :correlationid
      @timestamp = DateTime.parse(@data.delete :timestamp) rescue nil
      @version = @data.delete :version
      @build = @data.delete :build
      
      PayPal.log.info "ACK=#{ack}, CORRELATIONID=#{correlation_id}, TIMESTAMP=#{timestamp}, VERSION=#{version}, BUILD=#{build}"
      
      if failure?  
        @errors = []
        @data.each_pair do |k, v|
          m = k.to_s.match /^L_([^0-9]*)([0-9]*)$/i
          if m
            index = m[2].to_i
            @errors[index] = Error.new if @errors[index].nil?
            @errors[index].send "#{m[1]}=", v
            @data.delete k
          end
        end
        
        PayPal.log.error 'Errors:'
        PayPal.log.error @errors
      end
      
      if has_error_code? '10001' or has_error_code? '10001'
        raise ApiError.new(errors.first || 'Internal API Error') 
      end
      
      PayPal.log.debug 'Data:'
      PayPal.log.debug @data
    end
    
    # stolen from CGI::parse, modified slightly to auto downcase/to_sym keys and ditch Array wrapped values
    def parse(query)
      params = Hash.new([].freeze) 
      query.split(/[&;]/n).each do |pairs|
        key, value = pairs.split('=',2).collect{|v| CGI::unescape(v) }
        params[key.downcase.to_sym] = value
      end
      params
    end
  end
  
end
