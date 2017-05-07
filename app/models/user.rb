class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  after_create :welcome_user

  validates_format_of :email, :with => /@/
  validates :email, uniqueness: true

  def welcome_user
    invite_to_slack
    add_to_mailchimp
    add_to_airtables
  end

  def invite_to_slack
    SlackJobs::InviterJob.perform_later(email: email)
  end

  def add_to_mailchimp
    MailchimpInviterJob.perform_later(email: email)
  end

  def add_to_airtables
    AddUserToAirtablesJob.perform_later(self)
  end

  def token
    JsonWebToken.encode(user_id: self.id, roles: [])
  end
end