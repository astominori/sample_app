require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
    @non_activated = users(:malory)
  end
  
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template "users/index"
    assert_select "div.pagination", count: 2
    first_page_of_users = User.where(activated: true).paginate(page:1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end
  
  test "index as non-admmin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "should not show non-activated user" do
    log_in_as(@admin)
    get user_path(@non_activated)
    assert_redirected_to root_path
  end
  
  test "index showing only activated user" do
    log_in_as(@admin)
    get users_path
    assert_select "a", {count: 0, text: @non_activated.name }
    @non_activated.activate
    assert @non_activated.reload.activated
    get users_path
    assert_select "a[href=?]", user_path(@non_activated), text: @non_activated.name
  end
  
end
