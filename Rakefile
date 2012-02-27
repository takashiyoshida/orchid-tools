require "yaml"

desc "Checkout Orchid project from repository"
task :checkout do
  yml = YAML::load_file("config.yml")

  gbaby = yml["repo_root_url"]
  target = yml["target"]
  workspace = yml["workspace"]
  projects = yml["projects"]

  projects.each do | project |
    success = checkout(gbaby, project, target, workspace)
    if not success
      puts "Failed to checkout #{project}. Stopping checkout."
      exit 1
    end
  end
end

desc "Builds Orchid project from local workspace"
task :build do
  yml = YAML::load_file("config.yml")
  
  workspace = yml["workspace"]
  build_order = yml["build_order"]
  build_type = yml["build_type"]
  build_dir = yml["build_dir"]

  build_order.each do | project |
    success = build(workspace, project, build_dir, build_type)
    if not success
      puts "Failed to build #{project}. Stopping build."
      exit 1
    end
  end
end

def checkout(repo_url, project, target, workspace)
  command = "svn checkout #{repo_url}/#{project}/#{target} #{workspace}/#{project}"
  puts command
  success = system(command)
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

def build(workspace, project, build_dir, build_type)
  success = false
  Dir.chdir(workspace) do
    success = make_dir(build_dir)
    if not success
      puts "Failed to create a '#{build_dir}' directory."
      return false
    end

    Dir.chdir(build_dir) do
      success = make_dir(project)
      if not success
        puts "Failed to create a '#{build_dir}/#{project}' directory."
        return false
      end

      success = cmake(project, build_type)
      if not success
        return false
      end

      success = make(project)
      if not success
        return false
      end

      success = install(project)
      if not success
        return false
      end
    end
  end
  success
end

def cmake(project, build_type)
  success = false
  Dir.chdir(project) do
    command = "cmake -DCMAKE_BUILD_TYPE=#{build_type} ../../#{project}"
    puts command
    success = system(command)
  end

  if not success
    puts "#{project} failed during cmake."
    puts "DEBUG: #{command}"
  end
  success
end

def make(project)
  success = false
  Dir.chdir(project) do
    command = "make"
    puts command
    success = system(command)
  end

  if not success
    puts "#{project} failed during make."
    puts "DEBUG: #{command}"
  end
  success
end

def install(project)
  success = false
  Dir.chdir(project) do
    command = "sudo make install"
    puts command
    success = system(command)
  end
  success
end
