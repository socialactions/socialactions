require File.dirname(__FILE__) + '/../test_helper'

class ActionTypesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:action_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_action_type
    assert_difference('ActionType.count') do
      post :create, :action_type => { }
    end

    assert_redirected_to action_type_path(assigns(:action_type))
  end

  def test_should_show_action_type
    get :show, :id => action_types(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => action_types(:one).id
    assert_response :success
  end

  def test_should_update_action_type
    put :update, :id => action_types(:one).id, :action_type => { }
    assert_redirected_to action_type_path(assigns(:action_type))
  end

  def test_should_destroy_action_type
    assert_difference('ActionType.count', -1) do
      delete :destroy, :id => action_types(:one).id
    end

    assert_redirected_to action_types_path
  end
end
