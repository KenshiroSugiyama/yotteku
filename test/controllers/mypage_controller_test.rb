require 'test_helper'

class MypageControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get mypage_home_url
    assert_response :success
  end

end
