require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  test "should get suburb_state_postcode" do
    get :suburb_state_postcode
    assert_response :success
  end

end
