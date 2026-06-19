require "test_helper"

class ConferencesControllerTest < ActionDispatch::IntegrationTest
  test "未ログインではカンファレンス詳細にアクセスできないこと" do
    conference = create(:conference)

    get conference_path(conference)

    assert_redirected_to new_session_path
  end

  test "主催者はカンファレンス詳細を閲覧できること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_path(conference)

    assert_response :success
  end

  test "speakerメンバーは主催者向けカンファレンス詳細を閲覧できないこと" do
    user = create(:user)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :speaker)

    sign_in_as(user)
    get conference_path(conference)

    assert_redirected_to root_path
  end

  test "speakerメンバーのカンファレンスは主催者一覧に表示しないこと" do
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

  test "作成するカンファレンスのslugは名前から自動生成されること" do
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

  test "主催者はカンファレンスのOGP画像を登録できること" do
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

  test "主催者はカンファレンスのOGP画像を削除できること" do
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
end
