require 'rev'
require 'events'
require 'json'
require 'dnode/scrub'

class Conn < Rev::TCPSocket
    include Events::Emitter
    
    def initialize params
        @block = params[:block] || lambda {}
        @scrub = Scrub.new
        
        buf = ''
        this = self
        
        conn = params[:conn]
        conn.on_connect {}
        conn.on_close {}
        conn.on_read do |data|
            # hopefully line-buffered already, but anyways
            buf += data
            while buf.match(/\n/)
                buf = buf.sub(/^([^\n]+\n)/) do |line|
                    this.handle(JSON(line))
                    ''
                end
            end
        end
    end
    
    def handle req
        puts req.inspect
        
        args = @scrub.unscrub(req) { |id|
            lambda { |*argv| self.request(id, *argv) }
        }
        
        if req['method'].is_a? Integer then
            
        else
            
        end
    end
end
