require 'rev'
require 'events'
require 'json'
require 'dnode/scrub'

class Conn < Rev::TCPSocket
    include Events::Emitter
    
    def initialize params
        @block = params[:block] || lambda {}
        @instance = params[:instance] || {}
        @scrub = Scrub.new
        @remote = {}
        @sock = nil
        
        buf = ''
        this = self
        
        @conn = params[:conn]
        @conn.on_connect {
            this.emit('connect')
            conn = self
            
            (class << this; self; end).send(:define_method, 'write') do |msg|
                puts "msg=#{msg}"
                conn.write(msg)
            end
            
            this.request('methods', [
                if @instance.is_a? Proc
                    then @instance.call(*[@remote,this][0..@instance.arity-1])
                    else @instance
                end
            ])
        }
        @conn.on_close {}
        @conn.on_read do |data|
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
        @conn.write(JSON(
            {
                :method => method,
                :links => [],
            }.merge(@scrub.scrub args)
        ))
    end
end
