require File.dirname(__FILE__) + '/../test_helper'

class ActionSourcesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:action_sources)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_action_source
    assert_difference('ActionSource.count') do
      post :create, :action_source => { }
    end

    assert_redirected_to action_source_path(assigns(:action_source))
  end

  def test_should_show_action_source
    get :show, :id => action_sources(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => action_sources(:one).id
    assert_response :success
  end

  def test_should_update_action_source
    put :update, :id => action_sources(:one).id, :action_source => { }
    assert_redirected_to action_source_path(assigns(:action_source))
  end

  def test_should_destroy_action_source
    assert_difference('ActionSource.count', -1) do
      delete :destroy, :id => action_sources(:one).id
    end

    assert_redirected_to action_sources_path
  end
end
