# ActiveJob::Traceable

Patches ActiveJob to add an attribute `trace_id`, which is added as log's tag.
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

Create an initiazlier to tell ActiveJob how to get current `trace_id` and how to set it once deserialized:

```ruby
# config/initializers/activejob_traceable.rb
ActiveJob::Traceable.trace_id_getter = -> { CurrentScope.trace_id }
ActiveJob::Traceable.trace_id_setter = -> (trace_id) { CurrentScope.trace_id = trace_id }
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
