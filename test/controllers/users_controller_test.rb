require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get apply_now" do
    get :apply_now
    assert_response :success
  end

end
