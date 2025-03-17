require "test_helper"

class ScholarshipApplicationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get scholarship_applications_new_url
    assert_response :success
  end

  test "should get create" do
    get scholarship_applications_create_url
    assert_response :success
  end
end
