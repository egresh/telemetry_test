module Telemetry
  class Action
    class Create < Action
      attr_accessor :file_location, :file_name, :file_type

      def initialize(command_array)
        usage unless command_array[1]
        self.action_type = :create

        self.file_location, self.file_name, self.file_type = command_array[1..]
        super
      end

      def full_path
        File.join(file_location, file_name)
      end

      def build_command
        lambda do
          puts "Creating file #{file_name} of type #{file_type} at #{file_location}"

          Dir.chdir(file_location) do |d|
            case file_type
            when "directory"
              Dir.mkdir file_name
            when "file"
              if File.file? file_name
                raise "File already exists, can't create!"
              end
              File.open(file_name, "w") { |f| }
            end
          end
        end
      end

      def build_log_entry
        super.join(',')
      end
    end
  end
end
