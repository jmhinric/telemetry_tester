# telemetry_tester

## Description
This Ruby program executes certain known activities and generates log output of its actions. MacOS and Linux operating systems are supported. Though not a proper Ruby gem at this point, it's designed to be run by loading a single file into an irb session or a command line script, which successfully generates the desired log files.

Activities:
* Start a process:

  - MacOS executes the command `open {path_to_executable} {args (optional)}`

  - Linux executes the command `{path_to_executable} {args (optional)}`
* Create a file:

  - MacOS and Linux execute `touch {file_path}.{file_extension}`
* Update a file:

  - Append mode: MacOS and Linux execute `echo '{content}' >> {file_path}`
  - Overwrite mode: MacOS and Linux execute `echo '{content}' > {file_path}`
* Delete a file:

  - MacOS and Linux execute `rm {file_path}`

* Make a network request:

  - MacOS and Linux execute

      `curl -H 'Content-Type: application/json' -d {json_data} POST https://httpbin.org/post`

JSON log files are generated in a `./logs` directory within the project.

## Dependencies

* Linux curl utility
* Docker Desktop (an option to run with a Linux OS- instructions below)

## Installation

* Clone the git repository
* Run `bundle install`

## Usage
Start an irb session and run `load telemetry_tester.rb`. Execute examples below.

## Examples
```ruby
# Start a process:
  # MacOS:
    TelemetryTester.start_process('/System/Applications/Calculator.app', '-g')
    TelemetryTester.start_process('/System/Applications/Calculator.app')
  # Linux:
    TelemetryTester.start_process('sleep', '0')

# Create a file
TelemetryTester.create_file('./foo/baz', 'txt')

# Update a file
  # Note: default is "append" mode.
  # Can send `-o` as third arg to use "overwrite" mode
TelemetryTester.update_file('./foo/baz.txt', "Content here: #{Time.now.utc}")
TelemetryTester.update_file('./foo/baz.txt', "Content here: #{Time.now.utc}", 'o')

# Delete a file
TelemetryTester.delete_file('./foo/baz.txt')

# Make a network request
TelemetryTester.network_request({ name: 'John Smith' })
```

## Setup for testing on Linux
It seems common for developers to use Mac computers.  To test this program using Ubuntu, here are instructions to run via Docker Desktop:

```sh
# Download Ubuntu for docker:
docker pull --platform linux/x86_64 ubuntu

# Run a shell:
docker run -it --platform linux/x86_64 ubuntu bash

# Copy the project directory to the container:
docker cp ~/{path to repo}/telemetry_tester {container id}:/telemetry_tester

# Install Dependencies:
  # Install ruby
  apt update && apt upgrade -y
  apt install ruby ruby-dev
  which ruby

  # Install curl:
  apt install curl

  # Install bundler
  gem install bundler

  # Install vim (optional)
  apt-get install vim

# To colorize the terminal:
vim ~/.bashrc
Uncomment `force_color_prompt=yes`

# Run the Program:
  # From the project directory, install gems:
  bundle install
  # Open an irb session
  irb
  # Load the program
  load 'telemetry_tester.rb'
  # Follow above code examples
```
