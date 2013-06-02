PROJECT_DIR = File.dirname(__FILE__)
SCRIPT_DIR = "#{PROJECT_DIR}/Supporting Files/CI"

FILE_TEMPLATE_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/Templates/File Templates/Subliminal"
TRACE_TEMPLATE_DIR = "#{ENV['HOME']}/Library/Application Support/Instruments/Templates/Subliminal"
TRACE_TEMPLATE_NAME = "Subliminal.tracetemplate"

DOCSET_DIR = "#{ENV['HOME']}/Library/Developer/Shared/Documentation/DocSets"
DOCSET_NAME = "com.inkling.Subliminal.docset"
DOCSET_VERSION = "1.0"


task :default => :usage

### Usage

desc "Prints usage statement for people unfamiliar with Rake or this particular Rakefile"
task :usage, :task_name do |t, args|
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

rake install [docs=no] [dev=yes]

Options:
  docs=no\tSkips the download and installation of Subliminal's documentation.
  dev=yes\tInstalls files supporting the development of Subliminal.\n\n"""

    when "test", "test:unit", "test:integration", "test:integration:iphone", "test:integration:ipad"
      puts """
rake test\tRuns Subliminal's tests

rake test:unit
rake test:integration[:iphone, :ipad]
rake test:integration:device udid=<udid>

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

`integration:device` options:
  udid=<udid>\tThe UDID of the device to target.\n\n"""

    when "build_docs"
      puts "rake build_docs\tBuilds Subliminal's documentation"

  	else
  		fail "Unrecognized task name."

		end
	else
		puts """
rake <task> [<opt>=<value>[ <opt2>=<value2>...]]

Tasks:
  uninstall\tUninstalls supporting files
  install\tInstalls supporting files
  test\t\tRuns Subliminal's tests
  build_docs\tBuilds Subliminal's documentation

See 'rake usage[<task>]' for more information on a specific task.\n\n"""
	end
end


### Uninstallation

desc "Uninstalls supporting files"
task :uninstall do
	puts "\nUninstalling old supporting files..."

	uninstall_file_templates
	uninstall_trace_template
	fail "Could not uninstall docs" if !uninstall_docs
end

def uninstall_file_templates
	puts "- Uninstalling file templates..."

	`rm -rf "#{FILE_TEMPLATE_DIR}"`
end

def uninstall_trace_template
	puts "- Uninstalling trace template..."

	`rm -rf "#{TRACE_TEMPLATE_DIR}"`
end

def uninstall_docs
	puts "- Uninstalling docs..."

	docset_file = "#{DOCSET_DIR}/#{DOCSET_NAME}"
	
	if File.exists?(docset_file)
		# Xcode will crash if a docset is deleted while the app's open
		reply=`osascript <<-EOT
					if application "Xcode" is not running then
						set reply to "Not Running"
					else
						tell application "System Events"
							activate
							set reply to button returned of (display dialog "Subliminal will need to restart Xcode to uninstall Subliminal's documentation." \
															buttons {"Uninstall Later", "Restart Xcode"} \
															default button "Uninstall Later")
						end tell
					end if
				EOT`.chomp
		
		return false if reply == "Uninstall Later"
		
    # The next instruction requires that Xcode has fully quit--wait before proceeding
		`osascript -e 'tell application "Xcode" to quit' -e 'delay 1.0'` if reply == "Restart Xcode"

		`rm -rf #{docset_file}`

		if reply == "Restart Xcode"
			# once to restart, twice to become frontmost
			`osascript -e 'tell application "Xcode" to activate'`
			`osascript -e 'tell application "Xcode" to activate'`
		end
	end

	true
end


### Installation

desc "Installs supporting files"
task :install => :uninstall do
	puts "\nInstalling supporting files..."

	install_file_templates(ENV["dev"] == "yes")
	install_trace_template
	install_docs unless ENV["docs"] == "no"
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

  # Update the template to reference its script correctly
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


### Testing

desc "Runs Subliminal's tests"
task :test do
  puts "\nRunning tests...\n\n"

  # The unit tests guarantee the integrity of the integration tests
  # So no point in running the latter if the unit tests break the build
  Rake::Task['test:unit'].invoke
  Rake::Task['test:integration'].invoke

  puts "Tests passed.\n\n"
end

namespace :test do
  desc "Runs the unit tests"
  task :unit do    
    puts "- Running unit tests...\n\n"

    # Use system so we see the tests' output
    if system('xctool -project Subliminal.xcodeproj/ -scheme "Subliminal Unit Tests" clean test')
      puts "Unit tests passed.\n\n"
    else      
      fail "Unit tests failed."
    end
  end

  desc "Runs the integration tests"
  task :integration do    
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
    TEST_COMMAND="\"#{SCRIPT_DIR}/subliminal-test\"\
                      -project Subliminal.xcodeproj\
                      -scheme 'Subliminal Integration Tests'\
                      --quiet_build"

    desc "Runs the integration tests on iPhone"
    task :iphone do
      puts "-- Running iPhone integration tests..."

      results_dir = "#{SCRIPT_DIR}/results/iphone"
      `rm -rf "#{results_dir}" && mkdir -p "#{results_dir}"`

      # Use system so we see the tests' output
      if system("#{TEST_COMMAND} -output \"#{results_dir}\" -sim_device 'iPhone'")
        puts "\niPhone integration tests passed.\n\n"
      else
        fail "\niPhone integration tests failed.\n\n"
      end
    end

    desc "Runs the integration tests on iPad"
    task :ipad do
      puts "-- Running iPad integration tests..."

      results_dir = "#{SCRIPT_DIR}/results/ipad"
      `rm -rf "#{results_dir}" && mkdir -p "#{results_dir}"`

      # Use system so we see the tests' output
      if system("#{TEST_COMMAND} -output \"#{results_dir}\" -sim_device 'iPad'")
        puts "\niPad integration tests passed.\n\n"
      else
        fail "\niPad integration tests failed.\n\n"
      end
    end

    desc "Runs the integration tests on a device"
    task :device do
      puts "-- Running the integration tests on a device"

      udid = ENV["udid"]
      if !udid || udid.length == 0
        fail "Device UDID not specified. See 'rake usage[test]'." 
      end

      results_dir = "#{SCRIPT_DIR}/results/device"
      `rm -rf "#{results_dir}" && mkdir -p "#{results_dir}"`

      # Use system so we see the tests' output
      if system("#{TEST_COMMAND} -output \"#{results_dir}\" -hw_id #{udid}")
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
