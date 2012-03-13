require 'Command'

module Subversion
  def Subversion.checkout(target, workspace)
    cmd = Command.new("svn checkout #{target} #{workspace}")
    success = cmd.run
  end

  def Subversion.update(workspace, project)
    success = false
    Dir.chdir(workspace) do
      Dir.chdir(project) do
        puts "At #{workspace}/#{project}"
        cmd = Command.new("svn update")
        success = cmd.run
      end
    end
    success
  end
end
