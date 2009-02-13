require File.dirname(__FILE__) + '/../../test_helper'

class Shorturl::RedirectsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:shorturl_redirects)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_redirect
    assert_difference('Shorturl::Redirect.count') do
      post :create, :redirect => { }
    end

    assert_redirected_to redirect_path(assigns(:redirect))
  end

  def test_should_show_redirect
    get :show, :id => shorturl_redirects(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => shorturl_redirects(:one).id
    assert_response :success
  end

  def test_should_update_redirect
    put :update, :id => shorturl_redirects(:one).id, :redirect => { }
    assert_redirected_to redirect_path(assigns(:redirect))
  end

  def test_should_destroy_redirect
    assert_difference('Shorturl::Redirect.count', -1) do
      delete :destroy, :id => shorturl_redirects(:one).id
    end

    assert_redirected_to shorturl_redirects_path
  end
end
