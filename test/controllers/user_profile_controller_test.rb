require 'test_helper'

class UserProfileControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get user_profile_show_url
    assert_response :success
  end

  test "should get new" do
    get user_profile_new_url
    assert_response :success
  end

  test "should get edit" do
    get user_profile_edit_url
    assert_response :success
  end

  test "should get create" do
    get user_profile_create_url
    assert_response :success
  end

  test "should get update" do
    get user_profile_update_url
    assert_response :success
  end

end
