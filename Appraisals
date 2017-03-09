[ '4.0', '4.1', '4.2', '5.0', '5.1' ].map! { |v| Gem::Version.new v }.each do |ver|
  appraise "rails_#{ver.to_s.gsub '.', '_'}" do
    source "https://rubygems.org"
    gem "appraisal"
    if Gem::Requirement.new('> 5.0').satisfied_by?(ver)
      gem 'rails', :github => 'rails/rails', :branch => 'master'
    else
      gem 'rails', :github => 'rails/rails', :branch => "#{ver.to_s.gsub '.', '-'}-stable" 
    end

    if Gem::Requirement.new('> 4.2').satisfied_by?(ver)
      gem 'activeresource', :github => 'rails/activeresource', :branch => 'master'
    else
      gem 'activeresource', :github => 'rails/activeresource', :branch => '4-stable'
    end
    gem 'mocha', :require => false
    gemspec

  end
end

