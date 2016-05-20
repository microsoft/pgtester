require "pg_tester/version"
require 'pg'
require 'fileutils'

class PgTester

  attr_reader :user, :database, :port, :host, :data_dir, :initdb_path, 
              :pgctl_path, :createuser_path, :createdb_path

  def initialize(opts={})
    @user            = opts.fetch(:user) { 'pgtester' }
    @database        = opts.fetch(:database) { 'pgtester' }
    @port            = opts.fetch(:port) { 6433 }
    @host            = opts.fetch(:host) { 'localhost' }
    @data_dir        = opts.fetch(:data_dir) { '/tmp/pg_tester' }
    @initdb_path     = opts.fetch(:initdb_path) { shell_out('which initdb') }
    @pgctl_path      = opts.fetch(:pgctl_path) { shell_out('which pg_ctl') }
    @createuser_path = opts.fetch(:createuser_path) { shell_out('which createuser') }
    @createdb_path   = opts.fetch(:createdb_path) { shell_out('which createdb') }
    @connection      = nil

    raise 'please install postgresql' unless @initdb_path && !@initdb_path.empty?
  end

  def create_data_dir()
    Dir.mkdir(@data_dir) unless File.exists? @data_dir
  end

  def remove_data_dir()
    FileUtils.remove_dir(@data_dir)
  end

  def initdb()
    shell_out "#{@initdb_path} #{@data_dir} -A trust -E utf-8"
  end

  def rundb()
    pid = Process.fork { shell_out "#{@pgctl_path} start -o '-p #{@port}' -D #{@data_dir}" }
    # give a second for postgresql to startup
    sleep(1)
    Process.detach(pid)
  end

  def setup_test_user()
    shell_out "#{@createuser_path} -s -p #{@port} -l #{user} -w"
  end

  def setup_test_database()
    shell_out "#{@createdb_path} -p #{@port} #{database} -O #{user}"
  end

  def setup_pg_connection()
    @connection = PG::Connection.open(:user => @user, :dbname => @database, :port => @port)
  end

  def setup()
    create_data_dir
    initdb
    rundb
    setup_test_user
    setup_test_database
    setup_pg_connection
  end

  def teardown()
    @connection.close() if @connection
    shell_out "#{@pgctl_path} stop -m fast -o '-p #{@port}' -D #{data_dir}"
    remove_data_dir
  end

  def exec(query)
    if block_given?
      setup
      yield(@connection.exec(query))
      teardown
    else
      raise 'please run setup' unless @connection
      return @connection.exec(query)
    end
  end

  def exec_params(query, params)
    if block_given?
      setup
      yield(@connection.exec_params(query, params))
      teardown
    else
      raise 'please run setup' unless @connection
      return @connection.exec_params(query, params)
    end 
  end

  private

  def shell_out(cmd)
    result = `#{cmd}`
    result.strip
  end

end
