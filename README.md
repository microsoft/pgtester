# PgTester

A handy gem to help with testing postgresql related scripts or anything postgresql related

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_tester'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_tester

## Usage


```
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

## use case 1
psql.setup # This will create a test postgres cluster in /tmp, connection as testpostgresql user and database name testpostgresql
result = psql.exec(query)
# ... do some expectation on result
psql.teardown # Cluster is torn down and dir in /tmp deleted

## use case 2 -- this setup, execute the block and teardown
psql.exec(query) do |result|
  # ... do some expectation on result
end

## use case 3 -- all in one using default
PgTester.new({
  port:             '312',
  data_dir:         '/tmp/',
}).exec(query) { |result| # some expectation }

## use case 4 -- the rspec usage

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

## Contributing

Pull requests are welcome! You can run the tests by doing

`bundle exec rspec`
