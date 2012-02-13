class ApplicationController < ActionController::Base
  include Authentication
  helper :all
  protect_from_forgery
  
  # Only the API namespace should respond to XML. Be mindful of this!
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :unless => :requested_api?
  before_filter :login_required, :unless => :requested_api?
  before_filter :set_current_user, :unless => :requested_api?
  skip_before_filter :set_current_user, :only => [:access_denied]

  protected
  
  def requested_api?
    controller_path[0..3] == "api/"
  end
  
  def permission_denied
    flash[:error] = "Sorry, you are not allowed to access that page."
    redirect_to root_url
  end
end
