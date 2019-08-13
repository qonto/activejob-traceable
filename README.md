# ActiveJob::Traceable

Patches ActiveJob to add attribute `tracing_info`, which is added as log's tag.
The purpose of this patch is to be able to trace which workers are called as a result of user's HTTP request.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activejob-traceable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activejob-traceable

## Configuration

Create an initializer to tell ActiveJob how to get current `tracing_info` and how to set it once deserialized:

```ruby
# config/initializers/activejob_traceable.rb

ActiveJob::Traceable.tracing_info_getter = lambda do
  {
    actor_id: CurrentScope.actor_id,
    correlation_id: CurrentScope.correlation_id
  }
end

ActiveJob::Traceable.tracing_info_setter = lambda do |attributes|
  CurrentScope.actor_id = attributes[:actor_id]
  CurrentScope.correlation_id = attributes[:correlation_id]
end
```

## Usage

Once configured, works out of the box.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/qonto/activejob-traceable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
