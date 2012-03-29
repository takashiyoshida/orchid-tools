require 'yaml'
require 'Git'
require 'Subversion'
require 'Command'
require 'Build'

CONFIG_FILE = "config.yml"

namespace :env do

  desc "Check out Orchid project from repository"
  task :checkout, [:project] do |t, args|
    args.with_defaults(:project => "")
    projects = Array.new

    yml = YAML::load_file(CONFIG_FILE)
    if args.project.empty?
      projects = yml["svn"]["projects"]
    else
      projects.push(args.project)
    end

    projects.each do | project |
      success = checkout(yml["svn"], project)
      if not success
        puts "Failed to check out #{project}. Stopping checkout"
        exit 1
      end
    end
  end

  desc "Update workspace with the latest source code"
  task :update, [:project] do |t, args|
    args.with_defaults(:project => "")
    projects = Array.new

    yml = YAML::load_file(CONFIG_FILE)
    if args.project.empty?
      projects = yml["svn"]["projects"]
    else
      projects.push(args.project)
    end

    projects.each do | project |
      success = update(yml["svn"], project)
      if not success
        puts "Failed to update #{project}. Stopping update"
        exit 1
      end
    end
  end

  desc "Build Orchid project from local workspace"
  task :build, [:project] do |t, args|
    args.with_defaults(:project => "")
    build_order = Array.new

    yml = YAML::load_file(CONFIG_FILE)
    if args.project.empty?
      build_order = yml["build"]["order"]
    else
      build_order.push(args.project)
    end
    
    build_order.each do | project |
      success = build(yml, project)
      if not success
        puts "Failed to build #{project}. Stopping build"
        exit 1
      end
    end
  end

  desc "Remove unnecessary files from current workspace"
  task :tidy do
    cmd = Command.new('find . -name "*~" -exec rm {} \;')
    cmd.run

    cmd = Command.new('find . -name "*.log*" -exec rm {} \;')
    cmd.run
  end

  desc "Destroy current workspace"
  task :destroy do
    yml = YAML::load_file(CONFIG_FILE)
    cmd = Command.new("rm -rf " + yml["svn"]["workspace"])
    success = cmd.run
    if not success
      puts "Failed to destroy " + yml["svn"]["workspace"]
      exit 1
    end
  end
end

namespace :db do
  desc "Drop database"
  task :drop do
    yml = YAML::load_file(CONFIG_FILE)
    db_name = yml["database"]["db_name"]

    cmd = Command.new("dropdb #{db_name}")
    success = cmd.run

    if not success
      puts "Failed to drop database, '#{db_name}'"
      exit 1
    end
  end

  desc "Create database"
  task :create do
    yml = YAML::load_file(CONFIG_FILE)
    db_name = yml["database"]["db_name"]

    cmd = Command.new("createdb #{db_name}")
    success = cmd.run

    if not success
      puts "Failed to create database '#{db_name}'"
      exit 1
    end
  end

  desc "Initialize database"
  task :init, [:db_schema] do |t, args|
    args.with_defaults(:db_schema => "")

    yml = YAML::load_file(CONFIG_FILE)
    db_name = yml["database"]["db_name"]

    if args.db_schema.empty?
      workspace = yml["svn"]["workspace"]
      db_schema_path = "#{workspace}/deployment/PostgreSQL/#{db_name}.db"
    else
      db_schema_path = args.orchid_db
    end

    cmd = Command.new("psql #{db_name} < #{db_schema_path}")
    success = cmd.run

    if not success
      puts "Failed to initialize database '#{db_name}'"
      exit 1
    end
  end

  desc "Dump database"
  task :dump_db, [:db_name] do |t, args|
    args.with_defaults(:db_name => "")

    yml = YAML::load_file(CONFIG_FILE)
    host = yml["database"]["host"]
    port = yml["database"]["port"]
    username = yml["database"]["db_user"]

    if args.db_name.empty?
      db_name = yml["database"]["db_name"]
    else
      db_name = args.db_name
    end

    str = "pg_dump --host #{host} --port #{port} --username #{username} "
    str << "--format plain --clean --no-privileges "
    str << "#{db_name} --file=#{db_name}.db"

    cmd = Command.new(str)
    success = cmd.run
    if not success
      puts "Failed to dump database '#{db_name}'"
      exit 1
    end
  end

  desc "Dump table"
  task :dump_table, [:table_name] do |t, args|
    args.with_defaults(:table_name => "")
    if args.table_name.empty?
      puts "You must supply a table name"
      exit 1
    end
    
    yml = YAML::load_file(CONFIG_FILE)
    host = yml["database"]["host"]
    port = yml["database"]["port"]
    db_name = yml["database"]["db_name"]
    username = yml["database"]["db_user"]

    str = "pg_dump --host #{host} --port #{port} --username #{username} "
    str << "--format=plain --data-only --no-privileges "
    str << "--table=public.#{args.table_name} #{db_name} --file=#{args.table_name}.db"

    cmd = Command.new(str)
    success = cmd.run
    if not success
      puts "Failed to dump table '#{args.table_name}' from database"
      exit 1
    end
  end
end

namespace :test do
  desc "Start ActiveMQ"
  task :start_amq do
    yml = YAML::load_file(CONFIG_FILE)
    amq_bin_path = yml["test"]["amq_bin_path"]
    log_dir = yml["test"]["log_dir"]

    success = false
    Dir.chdir(amq_bin_path) do
      cmd = Command.new("./activemq-admin start > ../../#{log_dir}/activemq.log 2>&1 &")
      success = cmd.run
      if not success
        puts "Failed to start ActiveMQ"
        puts "DEBUG: #{cmd}"
        exit 1
      end
    end
  end

  desc "Stop ActiveMQ"
  task :stop_amq do
    stop_job("java")
  end

  desc "Start LDAP"
  task :start_ldap do
    yml = YAML::load_file(CONFIG_FILE)
    log_dir = yml["test"]["log_dir"]

    cmd = Command.new("sudo /usr/local/libexec/slapd -d 600 > #{log_dir}/slapd.log 2>&1 &")
    success = cmd.run
    if not success
      puts "Failed to start LDAP"
      puts "DEBUG: #{cmd}"
      exit 1
    end
  end

  desc "Stop LDAP"
  task :stop_ldap do
    cmd = Command.new("sudo killall slapd")
    success = cmd.run
    
    if not success
      puts "Failed to stop slapd"
      exit 1
    end
  end

  desc "Start Orchid service"
  task :start, [:service] do |t, args|
    args.with_defaults(:service => "")
    services = Array.new

    yml = YAML::load_file(CONFIG_FILE)
    log_dir = yml["test"]["log_dir"]

    if args.service.empty?
      services = yml["test"]["order"]
    else
      services.push(args.service)
    end

    services.each do | service |
      cmd = Command.new("#{service} > #{log_dir}/#{service}.log 2>&1 &")
      success = cmd.run

      if not success
        puts "Failed to start #{service}"
        exit 1
      end
      sleep 2
    end
  end

  desc "Stop Orchid service"
  task :stop, [:service] do |t, args|
    args.with_defaults(:service => "")
    services = Array.new

    yml = YAML::load_file(CONFIG_FILE)
    if args.service.empty?
      services = yml["test"]["order"].reverse
    else
      services.push(args.service)
    end

    services.each do | service |
      stop_job(service)
      if service == "omsa"
        stop_job("bin-omsa")
      end
      sleep 2
    end
  end

  desc "Restart Orchid service"
  task :restart, [:service] do |t, args|
    args.with_defaults(:service => "")

    if args.service.empty?
      Rake::Task["test:stop"].execute
      sleep 2
      Rake::Task["test:start"].execute
    else
      Rake::Task["test:stop"].invoke(args.service)
      sleep 2
      Rake::Task["test:start"].invoke(args.service)
    end
  end
end

def checkout(yml, project)
  success = false

  target = get_repo_target_url(yml["repo_url"], project, yml["target"])
  workspace = get_workspace_path(yml["workspace"], project)

  puts "target: #{target}"
  puts "workspace: #{workspace}"

  if yml["tool"] == "svn"
    success = Subversion.checkout(target, workspace)
  elsif yml["tool"] == "git-svn"
    success = Git.clone(target, workspace)
  else
    puts "Unrecognized tool option: '" + yml["tool"] + "'"
    success = false
  end
  success
end

def update(yml, project)
  success = false

  if yml["tool"] == "svn"
    success = Subversion.update(yml["workspace"], project)
  elsif yml["tool"] == "git-svn"
    success = Git.rebase(yml["workspace"], project)
  else
    puts "Unrecognized tool option: '" + yml["tool"] + "'"
    success = false
  end
  success
end

def build(yml, project)
  success = false

  Dir.chdir(yml["svn"]["workspace"]) do
    success = make_dir(yml["build"]["build_dir"])
    if not success
      puts "Failed to create '#{build_dir}' directory"
      return success
    end

    Dir.chdir(yml["build"]["build_dir"]) do
      success = make_dir(project)
      if not success
        puts "Failed to create '" + yml["build"]["build_dir"] + "/#{project}' directory"
        return success
      end

      success = Build.cmake(project, yml["build"]["build_type"])
      if not success
        return success
      end

      success = Build.make(project)
      if not success
        return success
      end

      success = Build.install(project)
      if not success
        return success
      end
    end
    success
  end
end

def stop_job(job)
  success = false
  cmd = Command.new("killall #{job}")
  success = cmd.run

  if not success
    puts "Failed to stop #{job}"
  end
  success
end

def make_dir(dirname)
  success = true
  if File.exists? dirname
    if not File.directory? dirname
      puts "#{dirname} already exists, but is not a directory."
      success = false
    end
  else
    Dir.mkdir(dirname)
  end
  success
end

def get_repo_target_url(repo_url, project, target)
  target_url = "#{repo_url}/#{project}/#{target}"
end

def get_workspace_path(workspace, project)
  workspace_path = "#{workspace}/#{project}"
end
