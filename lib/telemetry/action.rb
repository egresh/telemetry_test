require_relative "action/network"
require_relative "action/spawn"
require_relative "action/create"
require_relative "action/modify"
require_relative "action/delete"

module Telemetry
  class Action
    include Telemetry::ActionUtils

    attr_accessor :action_type, :process_name, :command_line, :process_id,
      :username, :timestamp, :command, :line_entry

    def common_log_entries
      [process_name, command_line, process_id, username, timestamp]
    end

    def set_process_id
      self.process_id =
        action_type == :spawn ? external_pid : Process.pid
    end

    def build_log_entry
      entry = common_log_entries

      if action_type != :spawn
        entry.push action_type
        entry.push full_path
      end

      entry
    end

    def initialize(command_array)
      if action_type != :spawn
        self.process_name = $PROGRAM_NAME
        self.command = $PROGRAM_NAME
        self.command_line = "#{command} " + command_array.join(" ")
      end
    end

    def execute
      self.timestamp = Time.now.utc.to_s
      self.process_id = Process.pid unless action_type == :spawn
      self.username = Etc.getpwuid(Process.uid).name

      begin
        build_command.call

        set_process_id

        write_to_log
        wait_for_child if action_type == :spawn
      rescue StandardError => e
        message = <<~EOF
          Error running command "#{command_line}"
          #{e.message}
        EOF

        raise e, message 
      end
    end

    def wait_for_child
      while Process.waitpid2(process_id, Process::WNOHANG).nil?
        puts "Waiting for PID: #{process_id} to finish..."
        $stdout.flush
        sleep 1
      end
    end

    def write_to_log
      log = File.join(APP_ROOT, "logs", "telemetry_log.csv")

      self.line_entry = build_log_entry

      File.open(log, "a") do |f|
        f.puts line_entry
      end
    end
  end
end
