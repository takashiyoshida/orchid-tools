require 'Command'

module Git
  def Git.clone(target, workspace)
    cmd = Command.new("git svn clone #{target} #{workspace}")
    success = cmd.run
    entries = Dir.entries(workspace)
    success = (entries.count > 3) ? true : false
  end

  def Git.rebase(workspace, project)
    success = false
    Dir.chdir(workspace) do
      Dir.chdir(project) do
        puts "At #{workspace}/#{project}"
        cmd = Command.new("git svn rebase")
        success = cmd.run
      end
    end
    success
  end
end
