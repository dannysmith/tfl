# TFL

This is an unoffical library for scraping Transport for London contactless website. Allows a user to get journey information by providing their TFL username and password. 

## Todo

- Currently this only looks up and returns journeys for the *first* contactless card.
- It should be changed to return all the cards, and then to query specifically the journeys on each card.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tfl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tfl

## Usage

```ruby
tfl = TFL::Client.new(username: 'joe@example.com', password: 'password')
journeys = tfl.journeys(on: Date.today)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

