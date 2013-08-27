require "em/warden/client"

class ConnectionProvider
  attr_reader :socket_path

  def initialize(socket_path)
    @socket_path = socket_path
    @connections = {}
  end

  def get(name)
    connection = @connections[name]

    return connection if connection && connection.connected?
    new_connection = EventMachine::Warden::FiberAwareClient.new(@socket_path)
    new_connection.connect
    @connections[name] = new_connection
    new_connection
  end

  def close_all
    @connections.values.each(&:disconnect)
  end
end