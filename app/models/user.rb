class User < ApplicationRecord
    before_save :downcase_email
    before_create :generate_confirmation_instructions

    has_secure_password
    validates :email, presence:true, uniqueness: true
    validates :email, case_sensitive: false
    validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }

    def downcase_email
        self.email.delete(' ').downcase
    end

    def generate_confirmation_instructions
        self.confirmation_token = Digest::SHA256.hexdigest((Time.now.to_i).to_s + self.email.to_s + SecureRandom.hex(8))
        self.confirmation_sent_at = Time.now.utc
    end

    def confirmation_token_valid?
        (self.confirmation_sent_at + 30.days) > Time.now.utc
    end

    def mark_as_confirmed!
        self.confirmation_token = nil
        self.confirmed_at = Time.now.utc
        save
    end
end
