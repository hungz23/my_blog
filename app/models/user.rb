class User < ActiveRecord::Base
	has_many :comments, dependent: :destroy
	has_many :entries, dependent: :destroy
	has_many :active_relationships, class_name: "Relationship",
									foreign_key: "follower_id",
									dependent: :destroy
	has_many :passive_relationships, class_name: "Relationship",
									foreign_key: "followed_id",
									dependent: :destroy
	has_many :following, through: :active_relationships, source: :followed
	has_many :followers, through: :passive_relationships, source: :follower
	before_save {self.email =  email.downcase}
	validates :name, presence: true, length: {maximum: 64}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX},
			   uniqueness: {case_sensitive: false}
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true
	# Returns the hash digest of the given string.
	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
		BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	# Defines a proto-feed.
	# See "Following users" for the full implementation.
	def feed
		following_ids = "SELECT followed_id FROM relationships
				WHERE follower_id = :user_id"
		Entry.where("user_id IN (#{following_ids})
				OR user_id = :user_id", user_id: id)
	end

	# Follows a user.
	def follow(other_user)
		active_relationships.create(followed_id: other_user.id)
	end
	# Unfollows a user.
	def unfollow(other_user)
		active_relationships.find_by(followed_id: other_user.id).destroy
	end
	# Returns true if the current user is following the other user.
	def following?(other_user)
		following.include?(other_user)
	end
end
