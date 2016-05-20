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

Initialize `PgTester` instance

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
```

Case 1

Create a test postgres cluster in /tmp, connection as testpostgresql user and database name testpostgresql and run queries against the test database.
```
psql.setup 
result = psql.exec(query)
# ... do some expectation on result
```

Remember to teardown the database to stop postgresql
```
psql.teardown # Cluster is torn down and dir in /tmp deleted
```

Case 2 

Execute the block and teardown database after block execution
```
psql.exec(query) do |result|
  # ... do some expectation on result
end
```

Case 3 

Pass custom arguments and execute query in block
```
PgTester.new({
  port:             '312',
  data_dir:         '/tmp/',
}).exec(query) { |result| # some expectation }
```

Case 4 

The rspec usage

```
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

Pull requests are welcome! 

## Tests

You can run the tests by doing

`bundle exec rspec`
