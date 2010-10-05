require 'eventmachine'
require 'events'
require 'json'
require 'dnode/scrub'

class Conn
    include Events::Emitter
    
    def initialize params
        @block = params[:block] || lambda {}
        @instance = params[:instance] || {}
        @conn = params[:conn]
        @scrub = Scrub.new
        @remote = {}
        
        request('methods', [
            if @instance.is_a? Proc
                then @instance.call(*[@remote,this][0..@instance.arity-1])
                else @instance
            end
        ])
    end
    
    def handle req
        puts req.inspect
        
        args = @scrub.unscrub(req) { |id|
            lambda { |*argv| self.request(id, *argv) }
        }
        
        if req['method'].is_a? Integer then
            id = req['method']
            @scrub.callbacks[id].call(*args)
        elsif req['method'] == 'methods' then
            @remote.update(args[0])
            @block.call(*[ @remote, self ][ 0 .. @block.arity - 1 ])
            self.emit('remote', @remote)
            self.emit('ready')
        end
    end
    
    def request method, *args
        scrub = @scrub.scrub(args)
        @conn.send_data(JSON(
            {
                :method => method,
                :links => [],
            }.merge(@scrub.scrub args)
        ))
    end
end
