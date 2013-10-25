require "eventmachine"
require "socket"

class Socket
  SO_REUSEPORT=15
end

class SocketHandler < EM::Connection
  def self.create_socket(port, address)
    s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, 1)
    s.bind(Socket.pack_sockaddr_in(port, address))
    s.listen(50)
    return s
  end

  def receive_data data
    $stderr.puts "#{Process.pid}: Data: #{data}"
  end

  def self.em_attach(port,addr,opts)
    $stderr.puts "#{Process.pid}: Initializing"
    s = SocketHandler.create_socket(port,addr)
    conn = EM.attach_server(s,SocketHandler) #,opts)
    $stderr.puts "#{Process.pid}: Socket created"
  end
end

pid = 0
3.times {
  if (0 != (pid = Process.fork()))
    $stderr.puts "#{Process.pid}: In fork"
    EM.run {
      SocketHandler.em_attach(8200,'127.0.0.1',{})
    }
  end
}
Process.waitpid if pid == 0
