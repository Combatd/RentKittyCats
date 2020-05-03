class User < ApplicationRecord
    attr_reader :password
    
    validates :user_name, :password_digest, presence: true
    validates :password_digest, presence: { message: 'Password cannot be blank' }
    
    after_initialize :ensure_session_token

    has_many :cats
    has_many :cat_rental_requests

    def reset_session_token!
        self.session_token = User.generate_session_token
        self.save!
        self.session_token
    end

    def password=(password) # set password
        @password = password
        self.password_digest = BCrypt::Password.create(@password)
    end

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end

    def self.find_by_credentials(user_name, password)
        user = User.find_by(user_name: user_name)
        if user.nil?
            return nil
        elsif user && user.is_password?(password)
            return user
        end
    end

    private

    def self.generate_session_token 
        SecureRandom::urlsafe_base64(16)
    end

    def ensure_session_token 
        self.session_token ||= User.generate_session_token
    end
end