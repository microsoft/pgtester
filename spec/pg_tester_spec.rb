require 'spec_helper'

describe PgTester do
  it 'has a version number' do
    expect(PgTester::VERSION).not_to be nil
  end

  let(:user) { 'buddy' }
  let(:database) { 'testbuddy' }
  let(:port) { 1234 }
  let(:host) { 'neeranator.com' }
  let(:data_dir)       { '/tmp/pg_tester' }
  let(:initdb_path)     { '/a_dir/bin/initdb' }
  let(:pgctl_path)      { '/a_dir/bin/pg_ctl' }
  let(:createuser_path) { '/a_dir/bin/create_user' }
  let(:createdb_path) { '/a_dir/bin/createdb' }
  let(:emptyinit) { '' }

  let(:opts) { {
    user:            user,
    database:        database,
    port:            port,
    host:            host,
    data_dir:        data_dir,
    initdb_path:     initdb_path,
    pgctl_path:      pgctl_path,
    createuser_path: createuser_path,
    createdb_path: createdb_path
  }}

  subject { described_class.new(opts) }

  describe '#initialize' do
    context 'with initdb_path as emtpy' do
      it 'should raise an error' do
        expect { described_class.new({:initdb_path => ""}) }.to raise_error
      end
    end


    context 'no options specified' do
      subject { described_class.new }

      before(:each) do
      end

      it 'should use pgtester user' do
        expect(subject.user).to eq('pgtester')
      end
      it 'should use pgtester database' do
        expect(subject.database).to eq('pgtester')
      end
      it 'should use port 6433' do
        expect(subject.port).to eq(6433)
      end
      it 'should use host localhost' do
        expect(subject.host).to eq('localhost')
      end
      it 'should use data_dir /tmp/pg_tester' do
        expect(subject.data_dir).to eq('/tmp/pg_tester')
      end
      it 'should shellout to find initdb' do
        # we have to return something otherwise exception will be raised
        expect_any_instance_of(described_class).to receive(:shell_out).with('which initdb').and_return 'something'
        expect_any_instance_of(described_class).to receive(:shell_out).at_least(:once)
        described_class.new
      end
      it 'should shellout to find pgctl_path' do
        expect_any_instance_of(described_class).to receive(:shell_out).with('which pg_ctl')
        expect_any_instance_of(described_class).to receive(:shell_out).at_least(:once)
        described_class.new(initdb_path: 'something')
      end
      it 'should shellout to find createuser' do
        expect_any_instance_of(described_class).to receive(:shell_out).with('which createuser')
        expect_any_instance_of(described_class).to receive(:shell_out).at_least(:once)
        described_class.new(initdb_path: 'something')
      end
      it 'should shellout to find createdb' do
        expect_any_instance_of(described_class).to receive(:shell_out).with('which createdb')
        expect_any_instance_of(described_class).to receive(:shell_out).at_least(:once)
        described_class.new(initdb_path: 'something')
      end
    end

    context 'with options specified' do
      subject { described_class.new(opts) }

      it 'should use specified user' do
        expect(subject.user).to eq(user)
      end
      it 'should use specified database' do
        expect(subject.database).to eq(database)
      end
      it 'should use specified port' do
        expect(subject.port).to eq(port)
      end
      it 'should use specified host' do
        expect(subject.host).to eq(host)
      end
      it 'should use specified data_dir' do
        expect(subject.data_dir).to eq(data_dir)
      end
      it 'should use specified initdb_path' do
        expect(subject.initdb_path).to eq(initdb_path)
      end
      it 'should use specified pgctl_path' do
        expect(subject.pgctl_path).to eq(pgctl_path)
      end
      it 'should use specified createuser_path' do
        expect(subject.createuser_path).to eq(createuser_path)
      end
      it 'should use specified createdb_path' do
        expect(subject.createdb_path).to eq(createdb_path)
      end
    end
  end

  describe 'postgresql operations' do
    context 'create/destroy data directory' do
      subject { described_class.new }
      it 'should create the data directory' do
        subject.create_data_dir
        expect(File.exists?(subject.data_dir)).to eq(true)
      end
      it 'should not create the data directory if it already exists' do
        subject.create_data_dir
        expect(File.exists?(subject.data_dir)).to eq(true)
      end
      it 'should create the remove directory' do
        subject.remove_data_dir
        expect(File.exists?(subject.data_dir)).to eq(false)
      end
    end

    context 'initialize the database' do
      subject { described_class.new }
      it 'should have the postgresql.conf inside the data directory' do
        subject.initdb
        expect(File.exists?("#{subject.data_dir}/postgresql.conf")).to eq(true)
      end
    end

    context 'run the database via pgctl' do 
      subject { described_class.new }
      it 'should have the postmaster.pid inside the data directory' do
        subject.initdb
        subject.rundb
        expect(File.exists?("#{subject.data_dir}/postmaster.pid")).to eq(true)
      end

      after(:each) do
        subject.teardown
      end
    end

    context 'setup test user' do 
      subject { described_class.new }
      it 'should create pgtester user' do
        allow(subject).to receive(:create_test_user) { 'CREATE USER' }
        expect(subject.create_test_user).to eq('CREATE USER')
      end
    end

    context 'setup test database' do 
      subject { described_class.new }
      it 'should create pgtester database' do
        allow(subject).to receive(:create_test_database) { 'CREATE DATABASE' }
        expect(subject.create_test_database).to eq('CREATE DATABASE')
      end
    end

    context 'run query' do
      subject { described_class.new }
      it 'check if postgresql query runs' do
        subject.setup
        expect(subject.exec('SELECT 1').getvalue(0,0)).to eq("1")
      end

      it 'check if postgresql query runs with params' do
        subject.setup
        result = subject.exec_params('SELECT $1::INTEGER AS a, $2::INTEGER AS b', [1, 2])
        expect(result.values).to eq([["1", "2"]])
      end

      after(:each) do
        subject.teardown
      end
    end

    context 'run query in block' do
      it 'should run exec query in a block' do
        described_class.new().exec('SELECT 2') do |result|
          expect(result.getvalue(0,0)).to eq("2")
        end
      end

      it 'should run exec query in a curly block' do
        described_class.new().exec('SELECT 3') { |result| expect(result.getvalue(0,0)).to eq("3") }
      end
    end
  end
end
