require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  test "login and browse site" do
    # login via https
    #https!
    get "/users/sign_up"
    assert_response :success
 
 	## login successfully
 	post_via_redirect '/users/sign_in', 'user[email]' => 'xwmeng@gmail.com', 'user[password]' => '11111111'
    #post "/users/sign_in", email: "xwmeng@gmail.com", password: "11111111"
    assert_response :success
    assert_equal '/inspections', path

    get "/inspections"
    assert_response :success
    #assert assigns(:articles)
  end

  test "login with errors" do
 	## login successfully
 	post_via_redirect '/users/sign_in', 'user[email]' => 'xwmeng@gmail.com', 'user[password]' => '2222'
    #post "/users/sign_in", email: "xwmeng@gmail.com", password: "11111111"
    assert_response :success
    assert_equal '/users/sign_in', path
  	assert_select "error_notice" do
  		assert_select "error_notice", "Invalid email or password."

  end

end
