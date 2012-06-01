require 'active_support/core_ext/object/to_query'
require 'net/https'
require 'uri'
require 'retryable'

module PayPal
  class Request
    
    attr_accessor :data, :dry_run
    
    def initialize(data, dry_run = false)
      @dry_run = dry_run
      @data = build_request data
      PayPal.log.debug 'Request data:'
      PayPal.log.debug @data
    end
    
    def send_request
      PayPal.log.info('Dry run enabled, not actually sending.') and return if @dry_run
      raise RequestError.new 'No PayPal API url configured' unless PayPal.config.api.url
      
      retryable(:tries => PayPal.config.retries, :on => RetryRequest) do
        Response.new post(PayPal.config.api.url, @data)
      end
    end
    
    protected
    
    def build_request(data)
      raise RequestError.new 'No PayPal API configuration found' unless PayPal.config.api
      
      data.merge(
        :version => PayPal.config.api.version,
        :user => PayPal.config.api.user,
        :pwd => PayPal.config.api.pass,
        :signature => PayPal.config.api.signature
      ).inject({}) do |built, (k,v)|
        built[k.to_s.upcase] = v
        built
      end
    end
    
    def post(api_url, data)
      PayPal.log.info "POST to #{api_url}"
      
      url = URI.parse(api_url)
      url.path ='/' if url.path.empty?
      
      http = Net::HTTP.new(url.host, url.port)
      http.set_debug_output(HttpDebug.new)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      http.cert_store = store
      
      # set some timeouts
      http.open_timeout  = 60 # this blocks forever by default, lets be a bit less crazy.
      http.read_timeout  = PayPal.config.timeout
      http.ssl_timeout   = PayPal.config.timeout

      req = Net::HTTP::Post.new(url.path, 'User-Agent' => "AudioAddict/PayPal v#{PayPal::VERSION}")
      res = http.start { |http| http.request(req, data.to_query) }

      res.body
      
    rescue Timeout::Error
      PayPal.log.warn 'Request timed out'
      raise RetryRequest.new 'Request timed out'
    rescue EOFError, Errno::ECONNREFUSED, Errno::ECONNRESET => e
      PayPal.log.error e
      raise ServiceUnavailableError.new("Unable to send your request or the request was rejected by the server: #{e}")
    end
  end
end