#  For details and documentation:
#  http://github.com/inkling/Subliminal
#
#  Copyright 2013 Inkling Systems, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.


# Subliminal's Rakefile.
# Defines tasks to install, uninstall, and test Subliminal.
# Invoke "rake" with no arguments to print usage.


PROJECT_DIR = File.dirname(__FILE__)
SCRIPT_DIR = "#{PROJECT_DIR}/Supporting Files/CI"

FILE_TEMPLATE_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/Templates/File Templates/Subliminal"
TRACE_TEMPLATE_DIR = "#{ENV['HOME']}/Library/Application Support/Instruments/Templates/Subliminal"
TRACE_TEMPLATE_NAME = "Subliminal.tracetemplate"
SCHEMES_DIR = "Subliminal.xcodeproj/xcuserdata/#{ENV['USER']}.xcuserdatad/xcschemes"

DOCSET_DIR = "#{ENV['HOME']}/Library/Developer/Shared/Documentation/DocSets"
DOCSET_NAME = "com.inkling.Subliminal.docset"
DOCSET_VERSION = "1.0"


task :default => :usage


### Usage

desc "Prints usage statement for people unfamiliar with Rake or this particular Rakefile"
task :usage, [:task_name] do |t, args|
  task_name = args[:task_name] ||= ""

  if !task_name.empty?
    case task_name

    when "usage"
      puts """
rake usage\tPrints usage statement for people unfamiliar with Rake or this particular Rakefile

rake usage[[<task>]]

Arguments:
  task\tThe name of the task to describe.\n\n"""

    when "uninstall"
      puts "rake uninstall\tUninstalls supporting files"

    when "install"
      puts """
rake install\tInstalls supporting files

rake install [DOCS=no] [DEV=yes]

Options:
  DOCS=no\tSkips the download and installation of Subliminal's documentation.
  DEV=yes\tInstalls files supporting the development of Subliminal.\n\n"""

    when "test", "test:unit", "test:integration", "test:integration:iphone", "test:integration:ipad"
      puts """
rake test\tRuns Subliminal's tests

rake test
rake test:unit
rake test:integration                  (LIVE=yes | LOGIN_PASSWORD=<password>)
rake test:integration[:iphone, :ipad]
rake test:integration:device           UDID=<udid>

Sub-tasks:
  :unit\tRuns the unit tests
  :integration\tRuns the integration tests
    :iphone\tFor the iPhone Simulator
    :ipad\tFor the iPad Simulator
    :device\tFor a device

\`test\` invokes \`test:unit\` and \`test:integration\`.
\`test:integration\` invokes \`test:integration:iphone\` and \`test:integration:ipad\`.
\`test:integration:device\` must be explicitly invoked.

To run the integration tests on a device, you will need a valid developer identity 
and provisioning profile. If you have a wildcard profile you will be able to run 
the tests without creating a profile specifically for the \"Subliminal Integration Tests\" app.

Subliminal's integration tests are currently configured to use the automatically-selected 
iPhone Developer identity with the wildcard \"iOS Team Provisioning Profile\" managed 
by Xcode.

\`integration\` options:
  LIVE=yes                  Indicates that the tests are being attended by a developer who can 
                            enter their password if instruments asks for authorization. For the tests 
                            to run un-attended, the current user's login password must be specified
                            by \`LOGIN_PASSWORD\`.

  LOGIN_PASSWORD=<password> Your login password. When instruments is launched, 
                            it may ask for permission to take control of your application 
                            (http://openradar.appspot.com/radar?id=1544403). 
                            To authorize instruments during an un-attended run, the tests 
                            require the current user's password. When running the tests live, 
                            \`LIVE=yes\` may be specified instead.
 
\`integration:device\` options:
  UDID=<udid>               The UDID of the device to target.\n\n"""

    when "build_docs"
      puts "rake build_docs\tBuilds Subliminal's documentation"

    else
      fail "Unrecognized task name."

    end
  else
    puts """
rake <task>[[arg[, arg2...]]] [<opt>=<value>[ <opt2>=<value2>...]]

Tasks:
  uninstall\tUninstalls supporting files
  install\tInstalls supporting files
  test\t\tRuns Subliminal's tests
  build_docs\tBuilds Subliminal's documentation

See 'rake usage[<task>]' for more information on a specific task.\n\n"""
  end
end

# Restarts Xcode (with the user's permission) if it's running, as required by several of the tasks below
# If a block is passed, it will be executed between quitting Xcode and restarting it
# Returns false if Xcode needed to be restarted and the user chose not to, true otherwise
def restart_xcode?(reason, cancel_button_title)
  frontmost_app = `osascript <<-EOT
    tell application "System Events"
      set app_name to name of first process whose frontmost is true
    end tell
EOT`.chomp

  reply=`osascript <<-EOT
    if application "Xcode" is not running then
      set reply to "Not Running"
    else
      tell application "System Events"
        activate
        set reply to button returned of (display dialog "#{reason}" \
                        buttons {"#{cancel_button_title}", "Restart Xcode"} \
                        default button "#{cancel_button_title}")
      end tell
    end if
EOT`.chomp
    
  return false if reply == "#{cancel_button_title}"

  # The block may require that Xcode has fully quit--wait before proceeding
  `osascript -e 'tell application "Xcode" to quit' -e 'delay 1.0'` if reply == "Restart Xcode"

  yield if block_given?

  if reply == "Restart Xcode"
    # once to restart, twice to come forward
    `osascript -e 'tell application "Xcode" to activate'`
    `osascript -e 'tell application "Xcode" to activate'`
    # but leave previously frontmost app up
    `osascript -e 'tell application "#{frontmost_app}" to activate'`
  end

  true
end


### Uninstallation

desc "Uninstalls supporting files"
task :uninstall do
  puts "\nUninstalling old supporting files..."

  uninstall_file_templates
  uninstall_trace_template
  # This setting may cascade from the tests;
  # respecting it allows us to avoid restarting Xcode when running tests locally.
  if ENV["DOCS"] != "no"
    fail "Could not uninstall docs" if !uninstall_docs?
  end
  # Note that we don't need to uninstall the schemes here, 
  # as they're contained within the project

  puts "Uninstallation complete.\n\n"
end

def uninstall_file_templates
  puts "- Uninstalling file templates..."

  `rm -rf "#{FILE_TEMPLATE_DIR}"`
end

def uninstall_trace_template
  puts "- Uninstalling trace template..."

  `rm -rf "#{TRACE_TEMPLATE_DIR}"`
end

def uninstall_docs?
  puts "- Uninstalling docs..."

  docset_file = "#{DOCSET_DIR}/#{DOCSET_NAME}"
  
  if File.exists?(docset_file)
    # Xcode will crash if a docset is deleted while the app's open
    restart_reason = "Subliminal will need to restart Xcode to uninstall Subliminal's documentation."
    return false if !restart_xcode?(restart_reason, "Uninstall Later") { `rm -rf #{docset_file}` }
  end

  true
end

def uninstall_schemes
  puts "- Uninstalling Subliminal's schemes..."

  # Though Xcode continues to show the schemes until restarted (it appears to cache working copies), 
  # it won't wig out if the schemes are deleted while open, so we don't need to restart it here
  `rm -f "#{SCHEMES_DIR}/"*.xcscheme`
end


### Installation

desc "Installs supporting files"
task :install => :uninstall do
  puts "\nInstalling supporting files..."

  install_file_templates(ENV["DEV"] == "yes")
  install_trace_template
  install_docs unless ENV["DOCS"] == "no"
  if ENV["DEV"] == "yes"
    fail "Could not install Subliminal's schemes." if !install_schemes?
  end

  puts "Installation complete.\n\n"
end

def install_file_templates(install_dev_templates)
  puts "- Installing file templates..."

  local_template_dir = "#{PROJECT_DIR}/Supporting Files/Xcode/File Templates/"

  `mkdir -p "#{FILE_TEMPLATE_DIR}" && \
  cp -r "#{local_template_dir}/Integration test class.xctemplate" "#{FILE_TEMPLATE_DIR}"`

  # install developer templates
  if $? == 0 && install_dev_templates
    `cp -r "#{local_template_dir}/Subliminal integration test class.xctemplate" "#{FILE_TEMPLATE_DIR}"`
  end
end

def install_trace_template
  puts "- Installing trace template..."

  `mkdir -p "#{TRACE_TEMPLATE_DIR}" && \
  cp "#{PROJECT_DIR}/Supporting Files/Instruments/"* "#{TRACE_TEMPLATE_DIR}"`

  # Update the template to reference its script and icon correctly
  # (as the user's home directory isn't known until now)
  `cd "#{TRACE_TEMPLATE_DIR}" &&\
  plutil -convert xml1 #{TRACE_TEMPLATE_NAME} &&\
  perl -pi -e "s|~|#{ENV['HOME']}|" #{TRACE_TEMPLATE_NAME} &&\
  plutil -convert binary1 #{TRACE_TEMPLATE_NAME}`
end

def install_docs
  puts "- Installing docs..."

  # download the latest docs
  docset_xar_name = "com.inkling.Subliminal-#{DOCSET_VERSION}.xar"

  docset_download_dir = "/tmp"
  docset_xar_file = "#{docset_download_dir}/#{docset_xar_name}"

  # Use a link to our GitHub repo once it goes public
  # docset_xar_URL_root = "https://github.com/inkling/subliminal/<to be determined>"
  docset_xar_URL_root = "http://f.cl.ly/items/0O3Q3N062F2G2v2b010m"
  `curl --progress-bar --output #{docset_xar_file} #{docset_xar_URL_root}/#{docset_xar_name}`

  # uncompress them
  `xar -C #{docset_download_dir} -xf #{docset_xar_file}`
  `rm #{docset_xar_file}`

  # move them to the documentation directory
  downloaded_docset_file = "#{docset_download_dir}/#{DOCSET_NAME}"
  installed_docset_file = "#{DOCSET_DIR}/#{DOCSET_NAME}"
  `mv #{downloaded_docset_file} #{installed_docset_file}`

  # load them
  `osascript -e 'tell application "Xcode" to load documentation set with path "#{installed_docset_file}"'`
end

# If Subliminal's schemes were shared, they'd show up in projects that used Subliminal
# so we instead add them (as non-shared schemes, within the project's `.xcuserdata` 
# directory) only when Subliminal itself is to be built, by the tests or a developer
def install_schemes?
  puts "- Installing Subliminal's schemes..."

  # Xcode will not show the schemes until restarted,
  # but we don't want to have to restart Xcode every time we run the tests locally,
  # so we only (re)install if any schemes are missing or out-of-date.
  schemes_need_reinstall = Dir["#{PROJECT_DIR}/Supporting Files/Xcode/Schemes/*"].any? { |file|
    installed_file = "#{SCHEMES_DIR}/#{File.basename(file)}"
    Dir[installed_file].empty? || !FileUtils.compare_file(installed_file, file)
  }
  if schemes_need_reinstall
    restart_reason = "Subliminal will need to restart Xcode to install Subliminal's schemes."
    return restart_xcode?(restart_reason, "Install Later") {
      `mkdir -p "#{SCHEMES_DIR}" && \
      cp "#{PROJECT_DIR}/Supporting Files/Xcode/Schemes/"* "#{SCHEMES_DIR}"`
    }
  end
  return true
end

### Testing

desc "Runs Subliminal's tests"
task :test => 'test:prepare' do
  puts "\nRunning tests...\n\n"

  # The unit tests guarantee the integrity of the integration tests
  # So no point in running the latter if the unit tests break the build
  Rake::Task['test:unit'].invoke
  Rake::Task['test:integration'].invoke

  puts "Tests passed.\n\n"
end

namespace :test do
  desc "Prepares to run Subliminal's tests"
  task :prepare do
    # We need to install Subliminal's trace template and its schemes
    # but can't declare install as a dependency because we have to set its env vars
    ENV['DEV'] = "yes"; ENV['DOCS'] = "no"
    Rake::Task['install'].invoke
  end

  desc "Runs the unit tests"
  task :unit => :prepare do    
    puts "- Running unit tests...\n\n"

    # Use system so we see the tests' output
    if system('xctool -project Subliminal.xcodeproj/ -scheme "Subliminal Unit Tests" clean test')
      puts "Unit tests passed.\n\n"
    else      
      fail "Unit tests failed."
    end
  end

  desc "Runs the integration tests"
  task :integration => :prepare do    
    puts "- Running integration tests...\n\n"

    # When the tests are running separately, 
    # we want them to (individually) fail rake
    # But here we want to run them both
    begin
      Rake::Task['test:integration:iphone'].invoke
    rescue Exception => e
      puts e
      iPhone_succeeded = false
    else
      iPhone_succeeded = true
    end

    begin
      Rake::Task['test:integration:ipad'].invoke      
    rescue Exception => e
      puts e
      iPad_succeeded = false
    else
      iPad_succeeded = true
    end

    # test:integration:device must be explicitly invoked
    # by a developer with a valid identity/provisioning profile
    # and device attached

    if iPhone_succeeded && iPad_succeeded
      puts "\nIntegration tests passed.\n\n"
    else
      fail "\nIntegration tests failed.\n\n"
    end
  end

  namespace :integration do
    def test_command
      command = "\"#{SCRIPT_DIR}/subliminal-test\"\
                -project Subliminal.xcodeproj\
                -scheme 'Subliminal Integration Tests'\
                --quiet_build"

      if ENV["LIVE"] == "yes"
        command << " --live"
      else
        login_password = ENV["LOGIN_PASSWORD"]
        if !login_password || login_password.length == 0
          fail "Neither \`LIVE=yes\` nor \`LOGIN_PASSWORD\` specified. See 'rake usage[test]`.\n\n"
        end
        command << " -login_password \"#{login_password}\""
      end

      command
    end

    desc "Runs the integration tests on iPhone"
    task :iphone => :prepare do
      puts "-- Running iPhone integration tests..."

      results_dir = "#{SCRIPT_DIR}/results/iphone"
      `rm -rf "#{results_dir}" && mkdir -p "#{results_dir}"`

      # Use system so we see the tests' output
      if system("#{test_command} -output \"#{results_dir}\" -sim_device 'iPhone'")
        puts "\niPhone integration tests passed.\n\n"
      else
        fail "\niPhone integration tests failed.\n\n"
      end
    end

    desc "Runs the integration tests on iPad"
    task :ipad => :prepare do
      puts "-- Running iPad integration tests..."

      results_dir = "#{SCRIPT_DIR}/results/ipad"
      `rm -rf "#{results_dir}" && mkdir -p "#{results_dir}"`

      # Use system so we see the tests' output
      if system("#{test_command} -output \"#{results_dir}\" -sim_device 'iPad'")
        puts "\niPad integration tests passed.\n\n"
      else
        fail "\niPad integration tests failed.\n\n"
      end
    end

    desc "Runs the integration tests on a device"
    task :device => :prepare do
      puts "-- Running the integration tests on a device"

      udid = ENV["UDID"]
      if !udid || udid.length == 0
        fail "Device UDID not specified. See 'rake usage[test]'.\n\n" 
      end

      results_dir = "#{SCRIPT_DIR}/results/device"
      `rm -rf "#{results_dir}" && mkdir -p "#{results_dir}"`

      # Use system so we see the tests' output
      if system("#{test_command} -output \"#{results_dir}\" -hw_id #{udid}")
        puts "\nDevice integration tests passed.\n\n"
      else
        fail "\nDevice integration tests failed.\n\n"
      end
    end
  end
end


### Building documentation

desc "Builds the documentation"
task :build_docs do    
  puts "\nBuilding documentation...\n\n"

  # Use system so we see the build's output
  if system('xctool -project Subliminal.xcodeproj/ -scheme "Subliminal Documentation" build')
    puts "Documentation built successfully.\n\n"
  else
    fail "Documentation failed to build."
  end
end
