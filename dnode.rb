require './dnode/conn.rb'
require 'rev'

class DNode
    def initialize obj={}
        @object = obj
    end
    
    def connect *args, &block
        types = args.inject({}) { |acc,x| acc.merge(x.class.to_s => x) }
        host = types['String'] || 'localhost'
        port = types['Fixnum']
        
        event_loop = Rev::Loop.default
        Conn.connect(host, port).attach(event_loop)
        event_loop.run 
    end
    
    def listen
        event_loop = Rev::Loop.default
        Rev::TCPServer.new(host, port, Conn).attach(event_loop)
        event_loop.run
    end
end
