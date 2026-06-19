require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "最初の登録ユーザーもadminにはならないこと" do
    User.delete_all

    post registration_path, params: {
      user: {
        name: "First User",
        email_address: "first@example.com",
        password: "secure-test-password",
        password_confirmation: "secure-test-password"
      }
    }

    user = User.find_by!(email_address: "first@example.com")

    assert_redirected_to conferences_path
    assert user.organizer?
    assert_not user.admin?
  end

  test "主催者登録を停止している場合は登録できないこと" do
    with_env("CONFVOICE_SELF_REGISTRATION_ENABLED" => "false") do
      get new_registration_path

      assert_redirected_to new_session_path

      assert_no_difference "User.count" do
        post registration_path, params: {
          user: {
            name: "Blocked User",
            email_address: "blocked@example.com",
            password: "secure-test-password",
            password_confirmation: "secure-test-password"
          }
        }
      end

      assert_redirected_to new_session_path
    end
  end

  private

  def with_env(values)
    previous = values.to_h { |key, _value| [key, ENV[key]] }
    values.each { |key, value| ENV[key] = value }

    yield
  ensure
    previous.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
