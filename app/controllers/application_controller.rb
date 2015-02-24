class ApplicationController < ActionController::Base
  respond_to :html, :json
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  # shared methods for begin/rescue
  def rescue_me(e)
    puts e
    case e.io.status[0]
    when "400"
      return 2
    when "401"
      return 2
    when "404"
      return 2
    else 
      return attempt_retry
    end
  end

  def attempt_retry
    @tries += 1
    if @tries < 3
      sleep 1
      return 1
    else
      return 2
    end
  end

  protected
  # In Rails 4.1 and below
  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end
end
