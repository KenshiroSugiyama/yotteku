require 'test_helper'

class UsersRestaurantsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get users_restaurants_new_url
    assert_response :success
  end

  test "should get create" do
    get users_restaurants_create_url
    assert_response :success
  end

  test "should get edit" do
    get users_restaurants_edit_url
    assert_response :success
  end

  test "should get update" do
    get users_restaurants_update_url
    assert_response :success
  end

  test "should get mypage" do
    get users_restaurants_mypage_url
    assert_response :success
  end

  test "should get detail" do
    get users_restaurants_detail_url
    assert_response :success
  end

end
