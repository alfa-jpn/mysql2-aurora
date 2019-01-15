# Mysql2::Aurora
mysql2 plugin supporting aurora failover.

[![Build Status](https://travis-ci.org/alfa-jpn/mysql2-aurora.svg?branch=master)](https://travis-ci.org/alfa-jpn/mysql2-aurora)
[![Coverage Status](https://coveralls.io/repos/github/alfa-jpn/mysql2-aurora/badge.svg?branch=master)](https://coveralls.io/github/alfa-jpn/mysql2-aurora?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/57d8ee7b6f30d413314b/maintainability)](https://codeclimate.com/github/alfa-jpn/mysql2-aurora/maintainability)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mysql2-aurora'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mysql2-aurora

## Usage
This gem extends Mysql2::Client. You can use `aurora_max_retry` option.

```ruby
Mysql2::Client.new(
  host:             'localhost',
  username:         'root',
  password:         'change_me',
  reconnect:        true,
  aurora_max_retry: 5
)
```

with Rails, in `database.yml`

```yml
development:
  adapter:          mysql2
  host:             localhost
  username:         root
  password:         change_me
  reconnect:        true
  aurora_max_retry: 5
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alfa-jpn/mysql2-aurora.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Testing

```shell
# Image build
docker-compose build

# Run tests
docker-compose run --rm app ./bin/test
```
