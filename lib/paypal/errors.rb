module PayPal
  ApiError                = Class.new(RuntimeError)
  RequestError            = Class.new(ApiError)
  ResponseError           = Class.new(ApiError)
  
  # RetryRequest errors will retry immediately, failing that they will requeue
  RetryRequest            = Class.new(ResponseError)
  RequestTimeout          = Class.new(RetryRequest)
  ServiceUnavailableError = Class.new(RetryRequest)
  
  class Error
    attr_accessor :errorcode, :severitycode, :shortmessage, :longmessage
    alias :code :errorcode
    alias :severity :severitycode
    alias :short_message :shortmessage
    alias :long_message :longmessage
    
    def inspect
      to_s
    end
    
    def to_s
      "#{severity}(#{code}): #{short_message}"
    end
    
    def to_hash
      {
        :code => self.error, 
        :severity => self.severity, 
        :short_message => self.short_message, 
        :long_message => self.long_message
      }
    end
  end
end