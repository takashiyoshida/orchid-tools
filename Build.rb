require 'Command'

module Build
  def Build.cmake(project, build_type)
    success = false
    Dir.chdir(project) do
      cmd = Command.new("cmake --DCMAKE_BUILD_TYPE=#{build_type} ../../#{project}")
      success = cmd.run
      if not success
        puts "#{project} failed during cmake"
        puts "DEBUG: #{cmd}"
      end
    end
    success
  end

  def Build.make(project)
    success = false
    Dir.chdir(project) do
      cmd = Command.new("make")
      success = cmd.run
      if not success
        puts "#{project} failed during make"
        puts "DEBUG: #{cmd}"
      end
    end
    success
  end

  def Build.install(project)
    success = false
    Dir.chdir(project) do
      cmd = Command.new("sudo make install")
      success = cmd.run
      if not success
        puts "#{project} failed during install"
        puts "DEBUG: #{cmd}"
      end
    end
    success
  end
end
