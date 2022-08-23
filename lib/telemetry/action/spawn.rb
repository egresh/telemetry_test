require "etc"

module Telemetry
  class Action
    class Spawn < Action
      attr_accessor :arguments, :external_pid

      def initialize(command_array)
        usage unless command_array[1]

        self.action_type = :spawn
        self.external_pid = nil

        self.command = self.process_name = command_array[1]
        self.arguments = command_array[2..]

        set_command_line

        super
      end

      def set_command_line
        self.command_line = command.dup
        arguments.each { |a| command_line << " #{a}" }
      end

      def build_command
        lambda do
          puts "Spawning command: #{command_line}"
          self.external_pid = Process.spawn(command_line)
          sleep 1
        end
      end

      def build_log_entry
        common_log_entries.join(",")
      end
    end
  end
end
