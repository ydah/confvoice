require "test_helper"

class ThemeToggleRenderingTest < ActionDispatch::IntegrationTest
  test "application layout renders the theme boot script and toggle" do
    get root_path

    assert_response :success
    assert_includes @response.body, "confvoice-theme"
    assert_select "header"
    assert_select "button[data-controller=?][data-action=?]", "theme", "theme#toggle"
  end

  test "public layout renders the theme boot script and toggle" do
    conference = create(:conference)

    get public_conference_path(conference)

    assert_response :success
    assert_includes @response.body, "confvoice-theme"
    assert_select "header"
    assert_select "header a[href=?]", public_conference_path(conference), text: conference.name
    assert_select "header a[href=?]", new_session_path, count: 0
    assert_select "header a[href=?]", new_registration_path, count: 0
    assert_select "button[data-controller=?][data-action=?]", "theme", "theme#toggle"
  end
end
