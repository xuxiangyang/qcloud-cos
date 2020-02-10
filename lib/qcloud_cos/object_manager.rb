require 'uri'
module QcloudCos
  class ObjectManager
    attr_accessor :bucket, :region, :access_id, :access_key, :http, :token
    def initialize(bucket: nil, region: nil, access_id: nil, access_key: nil, token: nil)
      @bucket = bucket
      @region = region
      @access_id = access_id
      @access_key = access_key
      @token = token
      @http = QcloudCos::Http.new(access_id, access_key, token: token)
    end

    def put_object(path, file_or_bin, headers = {})
      data = file_or_bin.respond_to?(:read) ? IO.binread(file_or_bin) : file_or_bin
      http.put(compute_url(path), data, headers)
    end

    def copy_object(path, copy_source, headers = {})
      headers['x-cos-copy-source'] = copy_source
      body = http.put(compute_url(path), nil, headers).body
      ActiveSupport::HashWithIndifferentAccess.new(ActiveSupport::XmlMini.parse(body))
    end

    def delete_object(path)
      http.delete(compute_url(path))
    end

    def delete_objects(pathes, quiet = false)
      data = {
        "Quiet" => quiet,
        "Object" => pathes.map { |p| { "Key" => p } },
      }
      http.post(compute_url("/?delete"), data.to_xml(root: "Delete", skip_instruct: true, skip_types: false), "Content-Type" => "application/xml")
    end

    def host
      "#{bucket}.cos.#{region}.myqcloud.com"
    end

    def compute_url(path)
      URI.join("https://#{host}", path).to_s
    end
  end
end
