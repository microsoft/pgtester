# PgTester  [![Build Status](https://travis-ci.org/Microsoft/pgtester.svg?branch=master)](https://travis-ci.org/Microsoft/pgtester)   [![Dependency Status](https://www.versioneye.com/user/projects/5760240349310500442edfc3/badge.svg?style=flat)](https://www.versioneye.com/user/projects/5760240349310500442edfc3)

A handy gem to help with testing postgresql related scripts or anything PostgreSQL related.

## Installation

Add this line to your application's `Gemfile` (source <https://rubygems.org>):

```ruby
gem 'pg_tester'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install pg_tester
```

## Usage

Initialize a `PgTester` instance:

```ruby
require 'pg_tester'

psql = PgTester.new({

  port:             '312',
  host:             'localhost',
  db_name:          'testpostgresql',
  user_name:        'testpostgresql',
  data_dir:         '/tmp/',
  initdb_path:      '/usr/local/bin/initdb',
  pgctl_path:       '/usr/local/bin/which pg_ctl',
  createuser_path:  '/usr/local/bin/which createuser',
  createdb_path:    '/usr/local/bin/which createdb',
  })
```

### Case 1

Create a test PostgreSQL cluster in `/tmp`, connect as `testpostgresql` user and database name `testpostgresql`, and run queries against the test database:

```ruby
psql.setup 
result = psql.exec(query)
# ... do some expectation on result
```

Remember to teardown the database to stop PostgreSQL:

```ruby
psql.teardown # Cluster is torn down and dir in /tmp deleted
```

### Case 2 

Execute the block and teardown database after block execution:

```ruby
psql.exec(query) do |result|
  # ... do some expectation on result
end
```

### Case 3 

Pass custom arguments and execute query in block:

```ruby
PgTester.new({
  port:             '312',
  data_dir:         '/tmp/',
}).exec(query) { |result| # some expectation }
```

### Case 4 

Use inside `rspec` specs:

```ruby
context 'run query in block' do
  it 'should run exec query in a block' do
    PgTester.new().exec('SELECT 2') do |result|
      expect(result.getvalue(0,0)).to eq("2")
    end
  end

  it 'should run exec query in a curly block' do
    PgTester.new().exec('SELECT 3') { |result| expect(result.getvalue(0,0)).to eq("3") }
  end
end
```

## Tests

You can run the tests by doing

`bundle exec rspec`

## Contributing

Pull requests are welcome!

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
