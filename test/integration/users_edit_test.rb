require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
	def setup
		@user = users(:michael)
	end
	
end
