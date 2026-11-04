require "test_helper"

class ConferencesControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated users cannot access conference details" do
    conference = create(:conference)

    get conference_path(conference)

    assert_redirected_to new_session_path
  end

  test "organizers can view conference details" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_path(conference)

    assert_response :success
  end

  test "speaker members cannot view organizer conference details" do
    user = create(:user)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :speaker)

    sign_in_as(user)
    get conference_path(conference)

    assert_redirected_to root_path
  end

  test "excludes conferences with speaker membership from the organizer list" do
    user = create(:user)
    organizer_conference = create(:conference, name: "Organizer Conference")
    speaker_conference = create(:conference, name: "Speaker Conference")
    create(:conference_membership, user: user, conference: organizer_conference, role: :organizer)
    create(:conference_membership, user: user, conference: speaker_conference, role: :speaker)

    sign_in_as(user)
    get conferences_path

    assert_response :success
    assert_includes response.body, "Organizer Conference"
    assert_no_match "Speaker Conference", response.body
  end

  test "generates a new conference slug from its name" do
    user = create(:user, :organizer)

    sign_in_as(user)
    post conferences_path, params: {
      conference: {
        name: "RubyKaigi 2026",
        description: "Ruby conference",
        venue: "Tokyo",
        starts_on: Date.current,
        ends_on: Date.current + 1.day,
        slug: "manual-slug",
        published: "1"
      }
    }

    conference = Conference.find_by!(name: "RubyKaigi 2026")

    assert_redirected_to conference_path(conference)
    assert_equal "rubykaigi2026", conference.slug
  end

  test "organizers can upload a conference OGP image" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    patch conference_path(conference), params: {
      conference: {
        ogp_image: fixture_file_upload("sample.png", "image/png")
      }
    }

    assert_redirected_to conference_path(conference)
    assert conference.reload.ogp_image.attached?
  end

  test "organizers can remove a conference OGP image" do
    user = create(:user, :organizer)
    conference = create(:conference)
    conference.ogp_image.attach(
      io: StringIO.new("image"),
      filename: "ogp.png",
      content_type: "image/png"
    )
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    patch conference_path(conference), params: {
      conference: {
        remove_ogp_image: "1"
      }
    }

    assert_redirected_to conference_path(conference)
    assert_not conference.reload.ogp_image.attached?
  end

  test "hides the image input when OGP image uploads are disabled" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)

    with_env("CONFVOICE_OGP_IMAGE_UPLOAD_ENABLED" => "false") do
      get edit_conference_path(conference)
    end

    assert_response :success
    assert_select "input[type=file][name=?]", "conference[ogp_image]", count: 0
  end

  test "rejects direct image uploads when OGP image uploads are disabled" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)

    with_env("CONFVOICE_OGP_IMAGE_UPLOAD_ENABLED" => "false") do
      patch conference_path(conference), params: {
        conference: {
          ogp_image: fixture_file_upload("sample.png", "image/png")
        }
      }
    end

    assert_redirected_to conference_path(conference)
    assert_not conference.reload.ogp_image.attached?
  end

  private

  def with_env(values)
    previous = values.to_h { |key, _value| [ key, ENV[key] ] }
    values.each { |key, value| ENV[key] = value }

    yield
  ensure
    previous.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
