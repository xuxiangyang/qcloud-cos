require 'cgi'
require 'uri'
require 'openssl'
require 'digest'
require 'net/http'
module QcloudCos
  class Http
    attr_accessor :access_id, :access_key, :token

    def initialize(access_id, access_key, token: nil)
      @access_id = access_id
      @access_key = access_key
      @token = token
    end

    def post(url, body = nil, headers = {})
      request(Net::HTTP::Post, url, body, headers)
    end

    def put(url, body = nil, headers = {})
      request(Net::HTTP::Put, url, body, headers)
    end

    def delete(url, headers = {})
      request(Net::HTTP::Delete, url, nil, headers)
    end

    def get(url, headers = {})
      request(Net::HTTP::Get, url, nil, headers)
    end

    def request(request_klass, url, body = nil, headers = {})
      uri = URI.parse(url)
      headers["x-cos-security-token"] = token if token
      headers["Authorization"] = compute_auth(request_klass::METHOD, uri.request_uri, headers)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = request_klass.new(uri, headers)
        request.body = body
        http.request(request)
      end

      raise QcloudCos::Http::ResponseCodeError, response if response.code.to_i != 200

      response
    end

    def compute_auth(method, fullpath, headers = {})
      path, query_string = fullpath.split("?")

      q_sign_time = "#{Time.now.to_i};#{Time.now.to_i + 600}"
      q_header_list = headers.keys.map(&:downcase).sort.join(";")
      q_url_params = query_string.to_s.split("&").map { |s| s.split("=").first }.compact.map(&:downcase).sort.join(";")

      sign_key = OpenSSL::HMAC.hexdigest("SHA1", access_key, q_sign_time)
      http_parameters = query_string.to_s.split("&").map { |s| s.split("=") }.map { |field, value| [field.downcase, value] }.sort_by { |field, _| field.to_s }.map { |field, value| [field, value].compact.join("=") }.join("&")
      http_headers = headers.map { |h, v| [h.downcase, CGI.escape(v)].join("=") }.join("&")
      http_string = "#{method.downcase}\n#{path}\n#{http_parameters}\n#{http_headers}\n"
      string_to_sign = "sha1\n#{q_sign_time}\n#{Digest::SHA1.hexdigest(http_string)}\n"
      signature = OpenSSL::HMAC.hexdigest("SHA1", sign_key, string_to_sign)

      "q-sign-algorithm=sha1&q-ak=#{access_id}&q-sign-time=#{q_sign_time}&q-key-time=#{q_sign_time}&q-header-list=#{q_header_list}&q-url-param-list=#{q_url_params}&q-signature=#{signature}"
    end

    class ResponseCodeError < QcloudCos::Error
      attr_accessor :code, :body, :response
      def initialize(response)
        @response = response
        @code = response.code.to_i
        @body = response.body
        super("Wrong response code with code=#{code} and body=#{body}")
      end
    end
  end
end
