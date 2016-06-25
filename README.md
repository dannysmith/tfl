# TFL

[![Build Status](https://travis-ci.org/jameshill/tfl.svg?branch=master)](https://travis-ci.org/jameshill/tfl)

This is an unoffical library for scraping Transport for London contactless website. Allows a user to get journey information by providing their TFL username and password.

This gem is not actively maintained, and thus has/will not be published to Rubygems.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tfl', git: 'https://github.com/jameshill/tfl.git'
```

And then execute:

    $ bundle install

## Usage

```ruby
tfl = TFL::Client.new(username: 'joe@example.com', password: 'password')
```

```ruby
tfl.cards
=> [#<TFL::Card:0x007fa7fe2746f8 @id="Y86tolzG2MhXCmPc5hkaGiQqG24q", @network="MasterCard", @last_4_digits="1234", @expiry="01/2020">, #<TFL::Card:0x007fa7fe278708 @id="dhu65yBMbPwhO7seI2Bs7fXMkh7P", @network="Visa", @last_4_digits="4567", @expiry="12/2025">]
```

```ruby
journeys = tfl.journeys(date: Date.today)
=> [#<TFL::Journey:0x007fa7fbe331b8 @card_id="Y86tolzG2MhXCmPc5hkaGiQqG24q", @date=#<Date: 2016-06-06 ((2457546j,0s,0n),+0s,2299161j)>, @from="East Putney", @to="Old Street", @time="09:21 - 10:09", @fare=#<Money fractional:290 currency:GBP>>]
```

If no card is supplied `journeys` will lazily return the journeys on the date **only** for the first contactless card. To force the request of journeys on a specific date & card, supply the card too.


```ruby
journeys = tfl.journeys(date: Date.today, card: tfl.cards.last)
=> [#<TFL::Journey:0x007fa7fbe331b8 @card_id="Y86tolzG2MhXCmPc5hkaGiQqG24q", @date=#<Date: 2016-06-06 ((2457546j,0s,0n),+0s,2299161j)>, @from="East Putney", @to="Old Street", @time="09:21 - 10:09", @fare=#<Money fractional:290 currency:GBP>>]
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

