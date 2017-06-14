class Module
  def attr_predicate(*attrs)
    attrs.each do |name|
      ivar = "@#{name}"
      predicate = "#{name}?"
      remove_possible_method predicate
      define_method predicate do
        instance_variable_defined?(ivar) && !!instance_variable_get(ivar)
      end
    end
  end
end
