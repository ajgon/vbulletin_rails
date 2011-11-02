module ActiveRecord
  class Base
    def self.create_vbulletin(email = :email, password = :password, username = :login)
      after_create :add_vbulletin
    end

    private
    def add_vbulletin
      VBulletin::User.register(:email => self.send(email), :password => self.send(password), :username => (self.respond_to?(username) ? self.send(username) : nil))
    end
  end
end