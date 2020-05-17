require 'test_helper'

class ReserveControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get reserve_edit_url
    assert_response :success
  end

  test "should get update" do
    get reserve_update_url
    assert_response :success
  end

end
