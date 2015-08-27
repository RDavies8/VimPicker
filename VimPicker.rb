#/usr/bin/ruby
require 'set'
require 'fileutils'

VIM_FILES_DIR = Dir.home + "/Development/VimPackages"

def getVimPackages
  ignoredFiles = [".", "..", ".git", "README.md"].to_set
  packages = Dir.entries(VIM_FILES_DIR).select do |file|
    !ignoredFiles.include?(file)
  end
  return packages
end

def listPackages
  puts "Available Packages:"
  packages = getVimPackages
  package_num = 1
  packages.each do |package|
    puts "\t#{package_num}) #{package}"
    package_num += 1
  end
end

def pickPackage(package)
  if verifyPackage package then
    puts "Package Selected: #{package}"
    selectedPackageDir = VIM_FILES_DIR + "/" + package

    # Must remove .vim before link for some reason, otherwise wouldn't overwrite.
    if File.exist?(Dir.home + '/.vim') then
      FileUtils.rm Dir.home + '/.vim'
    end
    FileUtils.ln_sf selectedPackageDir, Dir.home + "/.vim"
    FileUtils.ln_s selectedPackageDir + "/vimrc", Dir.home + "/.vimrc", :force => true
  else # Not a Valid Package
    puts "Not a Valid VimPackage: " + package
  end
end

def pickPackageFromList
  listPackages
  packages = getVimPackages
  while true do
    print 'Select a package number: '
    input = $stdin.gets
    if is_num?(input)
      if input.to_i > 0 and input.to_i <= packages.size then
        break
      else
        puts 'Must put a value listed'
      end
    else
      puts 'Must put a valid number'
    end
  end
  pickPackage packages[input.to_i - 1].to_s
end

def printCurrentPackage
  if File.exist?(Dir.home + '/.vim') then
    puts 'Current Package: ' + File.basename(File.readlink(Dir.home + '/.vim'))
  else
    puts 'No package selected'
  end
end

def is_num?(str)
  !!Integer(str)
rescue ArguementError, TypeError
  false
end

def verifyPackage(package)
  return getVimPackages.include?(package)
end

def printHelpMessage
  puts "Inccorect Args"
end

#Run
puts "Ruby Script Worked!!"
if ARGV.empty? then
  printCurrentPackage
elsif ARGV[0] == "list"
  listPackages
elsif ARGV[0] == "pick"
  if ARGV.size == 1 then
    pickPackageFromList
  elsif ARGV.size == 2 then
    pickPackage(ARGV[1])
    exit
  else
    printHelpMessage
  end
else
  printHelpMessage
end
