require 'test_helper'

class PatchesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:patches)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_patch
    assert_difference('Patch.count') do
      post :create, :patch => { }
    end

    assert_redirected_to patch_path(assigns(:patch))
  end

  def test_should_show_patch
    get :show, :id => patches(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => patches(:one).id
    assert_response :success
  end

  def test_should_update_patch
    put :update, :id => patches(:one).id, :patch => { }
    assert_redirected_to patch_path(assigns(:patch))
  end

  def test_should_destroy_patch
    assert_difference('Patch.count', -1) do
      delete :destroy, :id => patches(:one).id
    end

    assert_redirected_to patches_path
  end
end
