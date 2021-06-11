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
This gem extends Mysql2::Client. You can use `aurora_max_retry` and `aurora_disconnect_on_readonly` options.

```ruby
Mysql2::Client.new(
  host:             'localhost',
  username:         'root',
  password:         'change_me',
  reconnect:        true,
  aurora_max_retry: 5,
  aurora_disconnect_on_readonly: true
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
  aurora_disconnect_on_readonly: true

```

There are essentially two methods for handling and RDS Aurora failover. When there is an Aurora RDS failover event the primary writable server can change it's role to become a read_only replica. This can happen without active database connections droppping.
This leaves the connection in a state where writes will fail, but the application belives it's connected to a writeable server. Writes will now perpetually fail until the database connection is closed and re-established connecting back to the new primary.

To provide automatic recovery from this method you can use either a graceful retry, or an immediate disconnection option.

### Retry

Setting aurora_max_retry, mysql2 will not disconnect and automatically attempt re-connection to the database when a read_only error message is encountered.
This has the benefit that to the application the error is transparent and the query will be re-run against the new primary when the connection succeeds.

It is however not safe to use with transactions

Consider:

* Transaction is started on the primary server A
* Failover event occurs, A is now readonly
* Application issues a write statement, read_only exception is thrown
* mysql2-aurora gem handles this by reconnecting transparently to the new primary B
* Aplication continues issuing writes however on a new connection in auto-commit mode, no new transaction was started

The application remains un-aware it is now operating outside of a transaction, this can leave data in an inconcistent state, and issuing a ROLLBACK, or COMMIT will not have the expected outcome.

### Immediate disconnect

Setting aurora_disconnect_on_readonly to true, will cause mysql2 to close the connection to the database on read_only exception. The original exception will be thrown up the stack to the application.
With the database connection disconnected, the next statement will hit the disconnected error and the application can handle this as it would normally when been disconnected from the database.

This is safe with transactions.

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
