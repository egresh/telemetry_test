require 'fileutils'

module Telemetry
  class Action
    class Delete < Action
      attr_accessor :full_path, :file_type

      def initialize(command_array)
        usage unless command_array[1]

        self.action_type = :delete
        self.full_path = command_array[1]

        set_file_type

        super
      end

      def set_file_type
        self.file_type = File.directory?(full_path) ? :directory : :file
      end

      def build_command
        lambda do
          puts "Deleting file of type #{file_type} at #{full_path}"

          if file_type == :directory
            FileUtils.rmdir(full_path)
          else
            FileUtils.rm(full_path)
          end
        end
      end

      def build_log_entry
        super.join(',')
      end
    end
  end
end
