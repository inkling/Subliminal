DOCSET_DIR = "#{ENV['HOME']}/Library/Developer/Shared/Documentation/DocSets"
DOCSET_NAME = "com.inkling.Subliminal.docset"
DOCSET_VERSION = "1.0"

### Uninstallation

desc "Uninstalls supporting files"
task :uninstall do
	puts "Uninstalling supporting files..."

	fail "Could not uninstall docs" if !uninstall_docs
end

def uninstall_docs
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
	puts "Installing supporting files..."

	install_docs unless ENV["docs"] == "no"
end

def install_docs
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
