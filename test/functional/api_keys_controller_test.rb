require File.dirname(__FILE__) + '/../test_helper'

class ApiKeysControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:api_keys)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_api_key
    assert_difference('ApiKey.count') do
      post :create, :api_key => { }
    end

    assert_redirected_to api_key_path(assigns(:api_key))
  end

  def test_should_show_api_key
    get :show, :id => api_keys(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => api_keys(:one).id
    assert_response :success
  end

  def test_should_update_api_key
    put :update, :id => api_keys(:one).id, :api_key => { }
    assert_redirected_to api_key_path(assigns(:api_key))
  end

  def test_should_destroy_api_key
    assert_difference('ApiKey.count', -1) do
      delete :destroy, :id => api_keys(:one).id
    end

    assert_redirected_to api_keys_path
  end
end
