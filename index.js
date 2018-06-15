var request = require('request');
var wget = require('node-wget');
var exec = require('child_process').exec;

var command;
var TMP_DIR = "tmp/";
var DEFAULT_VERSION_IN_CONTROL_FILE = "1.9.5.4339-46276db8d";
var URL_PLEX_RELEASES_JSON = "https://plex.tv/api/downloads/1.json";

// Get the latest version
console.log("=== 1. Get the latest release of the plexpass ===");
request({
	uri: URL_PLEX_RELEASES_JSON
}, function(error, response, body) {
	if (error) {
		console.error(error);
		process.exit();
	}
	
	try {
		var json = JSON.parse(body);
	} catch (error) {
		console.log("The JSON file from '" + URL_PLEX_RELEASES_JSON + "' cannot be parsed.");
		process.exit();
	}
	
	var urlLatestVersion = json.computer.Linux.releases[0].url; // releases[0] is for Linux 64 bits
	var version = json.computer.Linux.version;
	if (!urlLatestVersion || !version) {
		console.error("The latest version cannot be found.");
		process.exit();
	}
	
	var split = urlLatestVersion.split('/');
	var filename = split[split.length - 1];
	var directory = filename.replace(".deb", ''); // Remove the .deb at the end
	var finalfilename = "plexmediaserver_" + version + "-sysvinit_amd64.deb";
	
	console.log("-------> End (" + version + ")");
	
	// Create the tmp/ directory
	command = "mkdir " + TMP_DIR;
	console.log("=== 2. Create the " + TMP_DIR + " directory ===");
	console.log("-------- " + command);
	exec(command);
	
	// Download the debian file
	console.log("=== 3. Download the latest .deb release of the plexpass ===")
	console.log("-------- wget " + urlLatestVersion);
	console.log("/!\\ Please wait for the download... /!\\");
	wget({
		url: urlLatestVersion,
		dest: TMP_DIR
	}, function(error, response, body) {
		if (error) {
			console.error(error);
			process.exit();
		}
		
		console.log("-------> End");
		
		// Unpack the debian package
		command = "dpkg -x " + TMP_DIR + filename + " " + TMP_DIR + directory;
		console.log("=== 4. Unpack the debian package ===");
		console.log("-------- " + command);
		exec(command, function(error, stdout, stderr) {
			if (error) {
				console.error("exec error: " + error);
				process.exit();
			}
			
			console.log("-------> End");
			
			// Un-tar the "prepared folder"
			command = "tar xvf amd64_base.tar.xz -C " + TMP_DIR;
			console.log("=== 5. Untar the amd64_base.tar.xz folder ===");
			console.log("-------- " + command);
			exec(command, function(error, stdout, stderr) {
				if (error) {
					console.error("exec error: " + error);
					process.exit();
				}
				
				console.log("-------> End");
				
				// Move usr/ directory
				command = "mv " + TMP_DIR + directory + "/usr " + TMP_DIR + "amd64_base/debian/";
				console.log("=== 6. Move the usr/ directory to amd64_base/debian/ ===");
				console.log("-------- " + command);
				exec(command, function(error, stdout, stderr) {
					if (error) {
						console.error("exec error: " + error);
						process.exit();
					}				
					
					console.log("-------> End");
					
					// Change the version in the amd64_base/debian/DEBIAN/control file
					command = "sed -i.bak s/" + DEFAULT_VERSION_IN_CONTROL_FILE + "/" + version + "/g " + TMP_DIR + "amd64_base/debian/DEBIAN/control";
					console.log("=== 7. Change the version in amd64_base/debian/DEBIAN/control to " + version + " ===");
					console.log("-------- " + command);
					exec(command, function(error, stdout, stderr) {
						if (error) {
							console.error("exec error: " + error);
							process.exit();
						}				
						
						console.log("-------> End");
						
						// Repackage the debian package
						command = "cd " + TMP_DIR + "amd64_base && dpkg-deb --build debian";
						console.log("=== 8. Repackage the debian package ===");
						console.log("-------- " + command);
						exec(command, function(error, stdout, stderr) {
							if (error) {
								console.error("exec error: " + error);
								process.exit();
							}				
							
							console.log("-------> End");
							
							// Move and rename the debian.deb built
							command = "mv " + TMP_DIR + "amd64_base/debian.deb " + finalfilename;
							console.log("=== 9. Move and rename the debian.deb built ===");
							console.log("-------- " + command);
						
							exec(command, function(error, stdout, stderr) {
								if (error) {
									console.error("exec error: " + error);
									process.exit();
								}				
								
								console.log("-------> End");
								
								// Remove the tmp/ directory
								command = "rm -rf " + TMP_DIR;
								console.log("=== 10. Remove the " + TMP_DIR + " directory ===");
								console.log("-------- " + command);
								exec(command, function(error, stdout, stderr) {
									if (error) {
										console.error("exec error: " + error);
										process.exit();
									}				
									
									console.log("-------> End");
								});
							});
						});
					});
					
				});
			});
			
		});
	});
})
