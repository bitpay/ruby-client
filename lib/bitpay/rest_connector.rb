# license Copyright 2011-2019 BitPay, Inc., MIT License
# see http://opensource.org/licenses/MIT
# or https://github.com/bitpay/php-bitpay-client/blob/master/LICENSE

module BitPay
  module RestConnector
    def send_request(verb, path, facade: 'merchant', params: {}, token: nil)
      token ||= get_token(facade)
      case verb.upcase
      when "GET"
        return get(path: path, token: token)
      when "POST"
        return post(path: path, token: token, params: params)
      else
        raise(BitPayError, "Invalid HTTP verb: #{verb.upcase}")
      end
    end

    def get(path:, token: nil, public: false)
      urlpath = '/' + path
      token_prefix = if urlpath.include? '?' then '&token=' else '?token=' end
      urlpath = urlpath + token_prefix + token if token
      request = Net::HTTP::Get.new urlpath
      unless public
        request['X-Signature'] = KeyUtils.sign(@uri.to_s + urlpath, @priv_key) 
        request['X-Identity'] = @pub_key
      end
      process_request(request)
    end

    def post(path:, token: nil, params:)
      urlpath = '/' + path
      request = Net::HTTP::Post.new urlpath
      params[:token] = token if token
      params[:guid]  = SecureRandom.uuid
      params[:id] = @client_id
      request.body = params.to_json
      if token
        request['X-Signature'] = KeyUtils.sign(@uri.to_s + urlpath + request.body, @priv_key)
        request['X-Identity'] = @pub_key
      end
      process_request(request)
    end

    def delete(path:, token: nil)
      urlpath = '/' + path
      urlpath = urlpath + '?token=' + token if token
      request = Net::HTTP::Delete.new urlpath
      request['X-Signature'] = KeyUtils.sign(@uri.to_s + urlpath, @priv_key) 
      request['X-Identity'] = @pub_key
      process_request(request)
    end

    private

    ## Processes HTTP Request and returns parsed response
    # Otherwise throws error
    #
    def process_request(request)
      request['User-Agent'] = @user_agent
      request['Content-Type'] = 'application/json'
      request['X-BitPay-Plugin-Info'] = 'Rubylib' + VERSION

      begin
        response = @https.request request
      rescue => error
        raise BitPay::ConnectionError, "#{error.message}"
      end

      if response.kind_of? Net::HTTPSuccess
        return JSON.parse(response.body)
      elsif JSON.parse(response.body)["error"]
        raise(BitPayError, "#{response.code}: #{JSON.parse(response.body)['error']}")
      else
        raise BitPayError, "#{response.code}: #{JSON.parse(response.body)}"
      end

    end

    ## Fetches the tokens hash from the server and
    #  updates @tokens
    #
    def refresh_tokens
      response = get(path: 'tokens')["data"]
      token_array = response || {}
      tokens = {}
      token_array.each do |t|
        tokens[t.keys.first] = t.values.first
      end
      @tokens = tokens
      return tokens
    end

    ## Makes a request to /tokens for pairing
    #     Adds passed params as post parameters
    #     If empty params, retrieves server-generated pairing code
    #     If pairingCode key/value is passed, will pair client ID to this account
    #   Returns response hash
    #

    def get_token(facade)
      token = @tokens[facade] || refresh_tokens[facade] || raise(BitPayError, "Not authorized for facade: #{facade}")
    end

  end
end
