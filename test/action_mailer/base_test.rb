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
