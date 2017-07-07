__FILE__.sub(/\.rb\z/, '').tap do |path|
  [ 'attr_predicate' ].each do |file|
    require File.join(path, file)
  end
end
