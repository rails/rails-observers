require 'minitest/autorun'
require 'action_mailer'

FIXTURE_LOAD_PATH = File.expand_path('fixtures', File.dirname(__FILE__))
ActionMailer::Base.view_paths = FIXTURE_LOAD_PATH

class MockSMTP
  def self.deliveries
    @@deliveries
  end

  def initialize
    @@deliveries = []
  end

  def sendmail(mail, from, to)
    @@deliveries << [mail, from, to]
  end

  def start(*args)
    yield self
  end
end

class Net::SMTP
  def self.new(*args)
    MockSMTP.new
  end
end

class BaseMailer < ActionMailer::Base
  self.mailer_name = "base_mailer"

  default :to => 'system@test.lindsaar.net',
          :from => 'jose@test.plataformatec.com',
          :reply_to => 'mikel@test.lindsaar.net'

  def welcome(hash = {})
    headers['X-SPAM'] = "Not SPAM"
    mail({:subject => "The first email on new API!"}.merge!(hash))
  end
end

class BaseTest < ActiveSupport::TestCase
  class MyObserver
    def self.delivered_email(mail)
    end
  end

  class MySecondObserver
    def self.delivered_email(mail)
    end
  end

  test "you can register an observer to the mail object that gets informed on email delivery" do
    ActionMailer::Base.register_observer(MyObserver)
    mail = BaseMailer.welcome
    MyObserver.expects(:delivered_email).with(mail)
    mail.deliver
  end

  test "you can register an observer using its stringified name to the mail object that gets informed on email delivery" do
    ActionMailer::Base.register_observer("BaseTest::MyObserver")
    mail = BaseMailer.welcome
    MyObserver.expects(:delivered_email).with(mail)
    mail.deliver
  end

  test "you can register multiple observers to the mail object that both get informed on email delivery" do
    ActionMailer::Base.register_observers("BaseTest::MyObserver", MySecondObserver)
    mail = BaseMailer.welcome
    MyObserver.expects(:delivered_email).with(mail)
    MySecondObserver.expects(:delivered_email).with(mail)
    mail.deliver
  end
end
