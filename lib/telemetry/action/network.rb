require "socket"

module Telemetry
  class Action
    class Network < Action
      attr_accessor :port, :protocol, :destination_url, :source_address,
        :source_port, :destination_address, :destination_port, :data_transferred

      def initialize(command_array)
        usage unless command_array[1]
        self.action_type = :network

        self.port = 80
        self.protocol = "http"
        self.destination_url = command_array.last

        super
      end

      def build_command
        lambda do
          puts "Connecting to: #{destination_url} over port: #{port}"
          connect
        end
      end

      def build_log_entry
        entry = common_log_entries
        entry.instance_exec(self) do |s|
          push s.source_address
          push s.source_port
          push s.destination_address
          push s.destination_port
          push s.protocol
          push s.data_transferred
        end
        entry.join(",")
      end

      def set_socket_attributes(socket_connection)
        local = Socket.unpack_sockaddr_in(socket_connection.getsockname)
        remote = Socket.unpack_sockaddr_in(socket_connection.getpeername)

        self.source_port = local[0]
        self.destination_port = remote[0]
        self.source_address = local[1]
        self.destination_address = remote[1]
      end

      def connect
        Socket.tcp(destination_url, port) do |connection|
          set_socket_attributes(connection)

          http_command = "GET / HTTP/1.1\n\n"
          connection.write(http_command)
          connection.close_write

          content = connection.read

          self.data_transferred = http_command.size + content.size
        end
      end
    end
  end
end
