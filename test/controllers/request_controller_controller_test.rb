require 'test_helper'

class RequestControllerControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get request_controller_new_url
    assert_response :success
  end

end
