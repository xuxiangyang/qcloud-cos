require 'active_support/all'
require "qcloud_cos/error"
require "qcloud_cos/version"
require 'qcloud_cos/http'
require 'qcloud_cos/object_manager'

module QcloudCos
  def configure
    @config ||= Configuration.new
    yield @config
    @config
  end

  def config
    @config
  end
end
