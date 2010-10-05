require 'rev'
require 'dnode/conn'

class DNode
    def initialize obj={}
        @instance = obj
    end
    
    def from_args *args, &block
        types = args.inject({}) { |acc,x| acc.merge(x.class.to_s => x) }
        kw = types['Hash'] || {}
        {
            :host => kw['host'] || kw[:host] || types['String'] || 'localhost',
            :port => kw['port'] || kw[:port] || types['Fixnum'],
            :block => block || kw['block'] || kw[:block] || types['Proc'],
        }
    end
    private :from_args
    
    def connect *args, &block
        params = from_args(*args, &block)
        
        klass = Class.new(Rev::TCPSocket)
        conn = Class.new
        %w{ on_connect on_close on_read }.each do |method|
            conn.send(:define_method, method) do |&block|
                klass.send :define_method, method, block
            end
        end
        
        socket = nil
        write_queue = []
        
        conn.send(:define_method, 'write') do |msg|
            puts "write: <#{msg}>"
            if socket.nil? then
                write_queue.push(msg)
            else
                socket.write(msg)
            end
        end
        
        klass.send(:define_method, 'on_connection') do |s|
            socket = s
            write_queue.each { |msg| socket.write(m) }
            puts "got socket: #{socket}"
        end
        
        Conn.new(params.merge :conn => conn.new, :instance => @instance)
        
        sock = klass.connect(params[:host], params[:port])
        event_loop = Rev::Loop.default
        sock.attach(event_loop)
        event_loop.run
    end
    
    def listen *args, &block
        params = from_args(*args, &block)
        server = Rev::TCPServer.new(params[:host], params[:port]) do |conn|
            Conn.new(params.merge :conn => conn, :instance => @instance)
        end
        event_loop = Rev::Loop.default
        server.attach(event_loop)
        event_loop.run
    end
end
