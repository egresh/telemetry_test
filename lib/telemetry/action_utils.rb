module Telemetry
  module ActionUtils
    def create_action(array)
      action = array.first

      case action
      when "-s"
        Action::Spawn.new(array)
      when "-n"
        Action::Network.new(array)
      when "-c"
        Action::Create.new(array)
      when "-d"
        Action::Delete.new(array)
      when "-m"
        Action::Modify.new(array)
      when "-u"
        usage
      else
        puts "Valid argument not detected"
        puts "----------------------------"

        usage
      end
    end

    def usage
      puts <<~EOF
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
        EOF

        exit true
    end
  end
end
