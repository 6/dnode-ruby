require './dnode/conn.rb'
require 'rev'

class DNode
    def initialize obj={}
        @object = obj
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
        
        Conn.new(params.merge :conn => conn.new)
        
        sock = klass.connect(params[:host], params[:port])
        event_loop = Rev::Loop.default
        sock.attach(event_loop)
        event_loop.run
    end
    
    def listen *args, &block
        params = from_args(*args, &block)
        server = Rev::TCPServer.new(params[:host], params[:port]) do |conn|
            Conn.new(params.merge :conn => conn)
        end
        event_loop = Rev::Loop.default
        server.attach(event_loop)
        event_loop.run
    end
end
