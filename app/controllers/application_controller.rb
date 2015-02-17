class ApplicationController < ActionController::Base
	respond_to :html, :json
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	after_filter :set_csrf_cookie_for_ng

	def set_csrf_cookie_for_ng
		cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
	end

	protected
	# In Rails 4.1 and below
	def verified_request?
		super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
	end
end
