class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each_with_index do |name,idx|
      define_method(name) do
        instance_variable_get("@#{names[idx]}")
      end
      define_method("#{name}=") do |arg|
        instance_variable_set("@#{names[idx]}",arg)
      end
    end
  end
end
