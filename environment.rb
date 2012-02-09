#!/usr/bin/env ruby

# Repository's root URL
REPO_ROOT_URL = "http://10.216.1.183/svn"

# Configurations to be passed to git-svn
TRUNK = "trunk"
BRANCHES = "branches"
TAGS = "tags"

if $0 == __FILE__
  puts "REPO_ROOT_URL: #{REPO_ROOT_URL}"
  puts "TRUNK: #{TRUNK}"
  puts "BRANCHES: #{BRANCHES}"
  puts "TAGS: #{TAGS}"
end
