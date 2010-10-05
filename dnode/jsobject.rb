require 'dnode/walk'

class JSObject < Hash
    def initialize hash={}
        singleton = (class << self; self; end)
        singleton.send(:define_method, :[], lambda { |key|
            super key.to_s
        })
        singleton.send(:define_method, :[]=, lambda { |key,value|
            super key.to_s, value
        })
        
        hash.each do |key,value|
            singleton.send(
                :define_method, key.to_s,
                lambda do |*args,&block|
                    if value.is_a? Proc then
                        if block.nil? then
                            value.call(*args)
                        else 
                            value.call(*args) { |*iargs| block.call(*iargs) }
                        end
                    else
                        value
                    end
                end
            )
        end
        self.update(
            hash.inject({}) { |acc,x| acc.merge(x[0].to_s => x[1]) }
        )
    end
end
