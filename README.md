# QcloudCos

腾讯云COS Ruby SDK

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qcloud-cos'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qcloud-cos

## Usage

### Object操作
用如下方式创建一个manager
```ruby
object_manager = QcloudCos::ObjectManager.new(
  access_id: "access_id",
  access_key: "access_key",
  bucket: 'bucket-appid',
  app_id: "app_id",
  region: "region",
)
```

#### [创建](https://cloud.tencent.com/document/product/436/7749)
```ruby
object_manager.put_object("/path.md", File.open("/tmp/src.md"), { "Content-Type" => "plain" })
```
#### [复制](https://cloud.tencent.com/document/product/436/10881)

```ruby
object_manager.copy_object("/src.md", "bucket.cos.region.myqcloud.com/dest.md")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xuxiangyang/qcloud-cos. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the QcloudCos project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/xuxiangyang/qcloud-cos/blob/master/CODE_OF_CONDUCT.md).
