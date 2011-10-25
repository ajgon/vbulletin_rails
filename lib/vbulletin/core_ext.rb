module ActiveRecord
  class Base
    def self.create_vbulletin
      after_create :add_vbulletin
    end
  
    private
    def add_vbulletin
      VBulletin.register(:email => self.email, :password => self.password, :username => (self.respond_to?(:login) ? self.login : nil))
    end
  end
end