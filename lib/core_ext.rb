__FILE__.sub(/\.rb\z/, '').tap do |path|
  [ 'string', 'module' ].each do |file|
    require File.join(path, file)
  end
end
