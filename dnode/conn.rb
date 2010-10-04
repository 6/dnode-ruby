require 'rev'
require 'events'

class Conn < Rev::TCPSocket
    include Events::Emitter
    
    def on_connect
        puts 'connect!'
    end
    
    def on_close
    end
    
    def on_read data
        puts "data = #{data}"
    end
end
