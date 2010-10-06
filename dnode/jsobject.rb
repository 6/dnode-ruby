require 'dnode/walk'

class JSObject < Hash
    def self.deep obj
        Walk.new(obj).walk do |node|
            if node.value.is_a? Hash and not node.value.is_a? JSObject then
                node.value = JSObject.new(node.value)
            end
        end
    end
    
    def initialize hash={}
        meta = class << self
            def [] key; super key.to_s; end
            def []= key, value; super key.to_s, value; end
            def update h
                h.each { |key,value| self[key] = value }
            end
            
            def method_missing method, *args, &block
                value = self[method]
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
            
            self
        end
        
        hash.each do |key,value|
            self[key] = value
            meta.send(:define_method, key) do |*args,&block|
                value = self[key]
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
        end
    end
end
