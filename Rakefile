PROJECT_DIR = File.dirname(__FILE__)
SCRIPT_DIR = "#{PROJECT_DIR}/Supporting Files/CI"

FILE_TEMPLATE_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/Templates/File Templates/Subliminal"
TRACE_TEMPLATE_DIR = "#{ENV['HOME']}/Library/Application Support/Instruments/Templates/Subliminal"

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
  task\tThe name of the task to describe."""

		when "uninstall"
			puts "rake uninstall\tUninstalls supporting files"

		when "install"
			puts """
rake install\tInstalls supporting files

rake install [docs=no] [dev=yes]

Options:
  docs=no\tSkips the download and installation of Subliminal's documentation.
  dev=yes\tInstalls files supporting the development of Subliminal."""

    when "test", "test:unit", "test:integration", "test:integration:iphone", "test:integration:ipad"
      puts """
rake test\tRuns Subliminal's tests

rake test[:unit, :integration[:iphone, :ipad]]

Sub-tasks:
  :unit\tRuns the unit tests
  :integration\tRuns the integration tests
    :iphone\tFor iPhone
    :ipad\tFor iPad"""

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

See 'rake usage[<task>]' for more information on a specific task."""
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
		
		`osascript -e 'tell application "Xcode" to quit' -e 'delay 0.1'` if reply == "Restart Xcode"

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

  # It appears that the trace template actually caches `SLTerminal.js` when created,
  # but it also refers to the file at the pre-cached path (inside the template directory), 
  # so we might as well move it to that path
	`mkdir -p "#{TRACE_TEMPLATE_DIR}" && \
	cp "#{PROJECT_DIR}/Supporting Files/Instruments/"* "#{TRACE_TEMPLATE_DIR}"`
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
  puts "\nRunning tests..."

  # The unit tests guarantee the integrity of the integration tests
  # So no point in running the latter if the unit tests break the build
  Rake::Task['test:unit'].invoke
  Rake::Task['test:integration'].invoke

  puts "Tests passed.\n\n"
end

namespace :test do
  desc "Runs the unit tests"
  task :unit do    
    puts "- Running unit tests..."

    # Use system so we see the tests' output
    if system('xctool -project Subliminal.xcodeproj/ -scheme "Subliminal Unit Tests" test')
      puts "Unit tests passed.\n\n"
    else      
      fail "Unit tests failed."
    end
  end

  desc "Runs the integration tests"
  task :integration do    
    puts "- Running integration tests..."

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

    if iPhone_succeeded && iPad_succeeded
      puts "\nIntegration tests passed.\n\n"
    else
      fail "\nIntegration tests failed.\n\n"
    end
  end

  namespace :integration do
    TEST_COMMAND="\"#{SCRIPT_DIR}/subliminal-test\"\
                      -build_tool xctool\
                      -project Subliminal.xcodeproj\
                      -scheme 'Subliminal Integration Tests'"

    desc "Runs the integration tests on iPhone"
    task :iphone do
      puts "-- Running iPhone integration tests..."

      results_dir = "#{SCRIPT_DIR}/results/iphone"
      `rm -rf "#{results_dir}" && mkdir -p "#{results_dir}"`

      # Use system so we see the tests' output
      if system("#{TEST_COMMAND} -output \"#{results_dir}\" -device 'iPhone'")
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
      if system("#{TEST_COMMAND} -output \"#{results_dir}\" -device 'iPad'")
        puts "\niPad integration tests passed.\n\n"
      else
        fail "\niPad integration tests failed.\n\n"
      end
    end
  end
end


### Building documentation

desc "Builds the documentation"
task :build_docs do    
  puts "\nBuilding documentation..."

    # Use system so we see the build's output
  if system('xctool -project Subliminal.xcodeproj/ -scheme "Subliminal Documentation" build')
    puts "Documentation built successfully.\n\n"
  else
    fail "Documentation failed to build."
  end
end
