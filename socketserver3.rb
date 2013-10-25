require "eventmachine"
require "socket"
require 'em-websocket'

class Socket
  SO_REUSEPORT=15
end

class SocketHandler < EM::WebSocket::Connection
  def self.create_socket(port, address)
    s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, 1)
    s.fcntl(Fcntl::F_SETFL, s.fcntl(Fcntl::F_GETFL) |
            Fcntl::O_NONBLOCK)
    s.bind(Socket.pack_sockaddr_in(port, address))
    s.listen(50)
    return s
  end

  def trigger_on_open(hs)
    $stderr.puts "#{Process.pid}: Connection open"    
  end

  def trigger_on_message(msg)
    $stderr.puts "#{Process.pid}: Message recieved #{msg}"
  end

  def self.em_attach(port,addr,opts)
    $stderr.puts "#{Process.pid}: Initializing"
    s = SocketHandler.create_socket(port,addr)
    conn = EM.attach_server(s,SocketHandler,opts)
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
