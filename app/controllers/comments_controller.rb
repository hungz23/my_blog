class CommentsController < ApplicationController
	before_action :logged_in_user, only: [:create, :destroy, :new]
	before_action :correct_user, only: :destroy
	def new
  		@comment = Comment.new
  	end
	def create
		@comment = current_user.comments.build(comment_params)
    	if @comment.save
      		flash[:success] = "Comment created!"
      		redirect_to root_url
    	else
      		render 'static_pages/help'
    	end
	end
	def destroy
		@comment.destroy
		flash[:success] = "Comment deleted"
		redirect_to request.referrer || root_url
	end
	private
		def comment_params
			params.require(:comment).permit(:content, :entry_id)
		end
		def correct_user
			@comment = current_user.comments.find_by(id: params[:id])
			redirect_to root_url if @comment.nil?
		end
end
