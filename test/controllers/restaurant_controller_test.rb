require 'test_helper'

class RestaurantControllerTest < ActionDispatch::IntegrationTest
  test "should get signup" do
    get restaurant_signup_url
    assert_response :success
  end

  test "should get login" do
    get restaurant_login_url
    assert_response :success
  end

end
