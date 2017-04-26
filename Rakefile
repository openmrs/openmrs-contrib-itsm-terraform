require 'rbconfig'

case RbConfig::CONFIG['host_os']
  when /mswin|windows/i
    os = :windows
  when /linux|arch/i
    os = :linux
  when /darwin/i
    os = :osx
  else
    abort("Unsupported OS #{RbConfig::CONFIG['host_os']}")
end

task :install do
  puts "Installing stuff"
end

task :setup do
  puts "Running on OS: #{os}"
  sh "git crypt unlock"
end

task :clean do
  puts "very clean"
end

task :default => [:terraform]
task :run => :terraform
task :t => :terraform
task :terraform, [:num1, :num] do |t, args|
  # ARGV.each { |a| task a.to_sym do ; end }
  puts "magic runs #{num1}"
end
