require 'test_helper'

class WishesControllerTest < ActionDispatch::IntegrationTest
  test "should get create_invoice" do
    get wishes_create_invoice_url
    assert_response :success
  end

  test "should get check_payment" do
    get wishes_check_payment_url
    assert_response :success
  end

  test "should get get_count" do
    get wishes_get_count_url
    assert_response :success
  end

end
