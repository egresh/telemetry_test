module Telemetry
  class Action
    class Modify < Action
      attr_accessor :full_path, :content

      def initialize(command_array)
        usage unless command_array[1]
        self.action_type = :modify
        self.full_path = command_array[1]
        self.content = command_array[2..]
        super
      end

      def build_log_entry
        super.join(",")
      end

      def build_command
        lambda do
          raise "File does not exist, can't append!" if !File.file?(full_path)
          puts "Modifying file #{full_path} with content #{content}"

          File.open(full_path, 'a') do |f|
            f.puts(content)
          end
        end
      end
    end
  end
end
