require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "password must be at least 12 characters" do
    user = build(:user, password: "short", password_confirmation: "short")

    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end

  test "existing user can be updated without changing password" do
    user = create(:user)

    user.name = "Updated Name"

    assert user.valid?
  end
end
