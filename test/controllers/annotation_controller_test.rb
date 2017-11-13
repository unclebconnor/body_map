require 'test_helper'

class AnnotationControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get annotation_index_url
    assert_response :success
  end

  test "should get new" do
    get annotation_new_url
    assert_response :success
  end

  test "should get edit" do
    get annotation_edit_url
    assert_response :success
  end

end
