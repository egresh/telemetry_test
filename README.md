# README

## Quick Start
* Clone the repository
* Change into the repository's directory
* Execute the "main.rb" script from the root directory
* Called without options, the usage is shown.
* Optional: run "bundle install" to install rspec to run tests

## Execute the 'main.rb' file in the project root to:

* Spawn an external program given options in the following format:
  * -s program_name program_arguments
  * Ex: main.rb -s ls -la
* Create a network connection over port 80 using the HTTP protocol:
  * -n site_name
  * Ex: main.rb -n www.google.com
* Create a new file (either a directory or plain file) given a location, name, and type:
  * -c location name type
  * Ex: main.rb -c /tmp foo.txt file
  * Ex: main.rb -c /tmp foo.txt directory
* Delete a file or directory
  * -d file
  * Ex: main.rb -d /tmp/foo.txt
  * Ex: main.rb -d /tmp/my_directory
* Modify a file by appending some text
  * -m file text
  * Ex: main.rb -m /tmp/foo.txt this is some text to add

## Operation

Although this project has a Gemfile, it's only needed to install the Rspec library for testing. The project doesn't use any other 3rd party gems and relies on the Ruby base install and its standard library. It has been tested on MacOS and Ubuntu Linux.

The program is namespaced within the ::Telemetry module. A base class called "Action" loads the "Action" subclasses. Each action subclass (Spawn, Network, Create, Delete, Modify) examines the provided options and sets action specific attributes to build a command action that can be invoked by the 'execute' method in the parent class. Command actions are implemented as lambdas in the subclasses.

The "main.rb" file is the framework driver. To execute the program:
```
# Loads the library
require_relative 'lib/telemetry'

# APP_ROOT is used to generate the location of the "logs" directory
APP_ROOT = File.expand_path("../", __FILE__)

# Adds the "create_action" method to scan the action as the first parameter.
# -s (spawn), -n (network), -c (create), -d (delete), -m (modify)
include Telemetry::ActionUtils

# Then an action instance is created and returned to the caller.
# Supply an array of options: create_action(['-s', 'ls', '-la'])
# or populate with ARGV
action = create_action(ARGV)

# To execute the action
action.execute
```

## Logging

Each action will log in CSV format a minimum of:

* Timestamp of start time
* Username that started the process
* Process name
* Process command line
* Process ID

The log resides in the project's "logs" directory: logs/telemetry_log.csv, and is appended to on each program run.

Example:

```
main.rb -s ls -l -a
```
This produces a log entry in the following format:

```
process_name, command_line, process_id, username, timestamp
ls,ls -l -a,40210,egresh,2022-08-22 18:55:13 UTC
```

The network action adds to the base set of log attributes:

```
main.rb -n www.google.com
```

This produces a log entry in the following format:

```
process_name, command_line, process_id, username, timestamp, source ip, source port, destination ip, destinatiaon port, protocol, payload size in bytes
./main.rb,./main.rb -n www.google.com,37813,egresh,2022-08-22 18:29:55 UTC,192.168.1.119,56155,172.217.14.68,80,http,54129
```

The create, modify, and delete actions add two additional logging fields to the base:

```
./main.rb -c /tmp foo.txt file
Creating file of type file at /tmp

./main.rb -m /tmp/foo.txt some text
Modifying file /tmp/foo.txt with content ["some", "text"]

./main.rb -d /tmp/foo.txt
Deleting file of type file at /tmp/foo.txt
```

This produces a log entry in the following format:

```
process_name, command_line, process_id, username, timestamp, activity descriptor, full path to file
./main.rb,./main.rb -c /tmp foo.txt file,43268,egresh,2022-08-22 19:32:59 UTC,create,/tmp/foo.txt
./main.rb,./main.rb -m /tmp/foo.txt some text,43706,egresh,2022-08-22 19:34:17 UTC,modify,/tmp/foo.txt
./main.rb,./main.rb -d /tmp/foo.txt,43429,egresh,2022-08-22 19:33:33 UTC,delete,/tmp/foo.txt
```

## Error Handling

The execution of the action's lambda is wrapped inside of a rescue block. Errors are caught and a user friendly message replaces the cryptic system error and backtrace. The exception is re-raised to be caught higher up the call stack. There is also some cursory error checking of the options presented by the user as command options.

For example, calling the "spawn" action with -s alone will only yield the usage:

```
./main.rb -s
Usage:
  Call the framework by executing the 'main.rb' script with options.
  Log data is saved in CSV format in logs/telemetry_log.csv.

Examples:
  To start a process use option -s, process name, and arguments.
    main.rb -s ls -la

  To start a network connection use option -n, site name
    main.rb -n www.google.com

  To create a file (directory or text file) in a specified location,
  use option -c, location, name, type
    main.rb -c /tmp foo.txt file
    main.rb -c /tmp foo.txt directory

  To delete a file (directory or text file), use option -d, name
    main.rb -d /tmp/foo.txt

  To modify a file (append some text), use option -m, text
    main.rb -m /tmp/foo.txt here is some text
```

If an error occurs because of an issue with the action itself, a different error is presented. For example, spawning an external program that can't be found:

```
./main.rb -s asdfasdfasdfsadf
Spawning command: asdfasdfasdfsadf
Error running command "asdfasdfasdfsadf"
No such file or directory - asdfasdfasdfsadf

Run the program with '-u' to see the usage
Example: main.rb -u
```

## Testing

The testing suite is based on RSpec. The test files:

* file_actions_spec.rb
* network_action_spec.rb
* spawn_action_spec.rb

act more or less as integration tests. An action is created for each action type, then executed, and a log entry is created. The log entry is parsed using Ruby's CSV library to ensure the log entry conforms to the CSV format and the action's state is reflected correctly in the log file..

The test file 'errors_spec.rb' demonstrates that when passed a single value to the 'create_action' method, it exits with an exit status of 0. That is, the exit status represents a successful return from the 'usage' function.

When intentional error conditions are given to the 'create_method' action, an exception should be raised. For example, spawning an external program called 'asdfasdfasdf' will trigger an exception: create_action(["-s", "asdfasdfasdf"]) should generate an exception Errno::ENOENT meaning the file is not present for execution.

Successful RSpec tests

```
# rspec

Errors
  when given a single parameter requesting an action
    -s, -n, -c, -d, -m will exit with a status 0
  when given intentional error conditions, the
    spawn action generates an exception
    network action generates an exception
    create action generates an exception
    delete action generates an exception
    modify action generates an exception

File Actions
  Create File
    builds a create object with type file and creates all csv log file entries
    builds a create object with type directory and creates all csv log file entries
  Delete File
    deletes a file object with type file and creates all csv log file entries
    deletes a file object with type directory and creates all csv log file entries
  Modify File
    modifies a file object and creates all csv log file entries

A Network Action
  builds a network object and creates all csv log file entries

A Spawn Action
  builds a spawn object and creates all csv log file entries

Finished in 1.08 seconds (files took 0.12313 seconds to load)
13 examples, 0 failures
```
