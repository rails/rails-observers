require 'isolation/abstract_unit'
require 'rails-observers'

module ApplicationTests
  class RakeTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::Isolation

    def setup
      build_app
      boot_rails
      FileUtils.rm_rf("#{app_path}/config/environments")
    end

    def teardown
      teardown_app
    end

    def test_load_activerecord_base_when_we_use_observers
      Dir.chdir(app_path) do
        `bundle exec rails g model user;
         bundle exec rake db:migrate;
         bundle exec rails g observer user;`

        add_to_config "config.active_record.observers = :user_observer"

        assert_equal "0", `bundle exec rails r "puts User.count"`.strip

        app_file "lib/tasks/count_user.rake", <<-RUBY
          namespace :user do
            task :count => :environment do
              puts User.count
            end
          end
        RUBY

        assert_equal "0", `bundle exec rake user:count`.strip
      end
    end
  end
end
