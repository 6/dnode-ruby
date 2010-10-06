require 'eventmachine'
require 'events'
require 'json'
require 'dnode/scrub'
require 'dnode/jsobject'

class Conn
    include Events::Emitter
    
    def initialize params
        @block = params[:block] || lambda {}
        @instance = params[:instance] || {}
        @conn = params[:conn]
        @scrub = Scrub.new
        @remote = {}
        js = JSObject.deep(@remote)
        
        request('methods',
            if @instance.is_a? Proc
                then @instance.call(*[js,this][0..@instance.arity-1])
                else @instance
            end
        )
    end
    
    def handle req
        args = @scrub.unscrub(req) do |id|
            lambda { |*argv| self.request(id, *argv) }
        end
        
        if req['method'].is_a? Integer then
            id = req['method']
            @scrub.callbacks[id].call(*JSObject.deep(args))
        elsif req['method'] == 'methods' then
            @remote.update(args[0])
            js = JSObject.deep(@remote)
            
            @block.call(*[ js, self ][ 0 .. @block.arity - 1 ])
            self.emit('remote', js)
            self.emit('ready')
        end
    end
    
    def request method, *args
        scrubbed = @scrub.scrub(args)
        @conn.send_data(JSON(
            {
                :method => (
                    if method.respond_to? :match and method.match(/^\d+$/)
                        then method.to_i
                        else method
                    end
                ),
                :links => [],
            }.merge(scrubbed)
        ) + "\n")
    end
end
