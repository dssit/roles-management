require 'test_helper'

class Admin::OpsControllerTest < ActionController::TestCase
  test "admin access required impersonating" do
    # Ensure unauthorized user has no access
    revoke_access

    # assert (Authorization.current_user.role_symbols.include? :access) == false, "user should not have access role"
    # assert (Authorization.current_user.role_symbols.include? :admin) == false, "user should not have admin role"

    get "impersonate", params: { loginid: 'someone' }, as: :json
    assert_response 401

    # Ensure authorized non-admin user has no access
    CASClient::Frameworks::Rails::Filter.fake("casuser")

    grant_test_user_basic_access
    revoke_test_user_admin_access

    get "impersonate", params: { loginid: 'someone' }, as: :json
    assert_response 403

    # Ensure authorized admin users have access
    grant_test_user_admin_access

    get "impersonate", params: { loginid: 'someone' }
    assert_response :redirect
  end

  # test "admin access required for unimpersonating" do
  #
  #   assert false
  # end
end
