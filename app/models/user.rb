class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable,
         :omniauthable, :omniauth_providers => [:twitter]

  def self.from_omniauth(auth)
	  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
	    user.provider = auth.provider
      user.uid = auth.uid
      user.secret = auth.credentials.secret
      user.token = auth.credentials.token
      user.save
	  end
	end

end
