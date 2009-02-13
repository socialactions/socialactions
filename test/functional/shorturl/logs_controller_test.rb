require File.dirname(__FILE__) + '/../../test_helper'

class Shorturl::LogsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:shorturl_logs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_log
    assert_difference('Shorturl::Log.count') do
      post :create, :log => { }
    end

    assert_redirected_to log_path(assigns(:log))
  end

  def test_should_show_log
    get :show, :id => shorturl_logs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => shorturl_logs(:one).id
    assert_response :success
  end

  def test_should_update_log
    put :update, :id => shorturl_logs(:one).id, :log => { }
    assert_redirected_to log_path(assigns(:log))
  end

  def test_should_destroy_log
    assert_difference('Shorturl::Log.count', -1) do
      delete :destroy, :id => shorturl_logs(:one).id
    end

    assert_redirected_to shorturl_logs_path
  end
end
