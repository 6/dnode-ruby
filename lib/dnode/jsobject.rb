require 'dnode/walk'

class JSObject
    class JSHash < Hash
        def [] key; super key.to_s; end
        def []= key, value; super key.to_s, value; end
        
        @@names = []
        def self.create hash
            @@names.each { |name| remove_method(name) }
            @@names = hash.keys
            
            hash.each do |name,value|
                define_method(name) do |*args,&block|
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
            
            self.new.update(hash)
        end
    end
    
    def self.create obj={}
        Walk.new(obj).walk do |node|
            if node.value.is_a? Hash and not node.value.is_a? JSHash then
                node.value = JSHash.create(node.value)
            end
        end
    end
end
