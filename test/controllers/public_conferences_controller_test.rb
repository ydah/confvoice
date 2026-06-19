require "test_helper"

class PublicConferencesControllerTest < ActionDispatch::IntegrationTest
  test "公開カンファレンスのトーク一覧を未ログインで閲覧できること" do
    conference = create(:conference)
    session = create(:session, conference: conference, title: "公開トーク")

    get public_conference_path(conference)

    assert_response :success
    assert_select "h1", conference.name
    assert_select "h3", "公開トーク"
    assert_select "a[href=?]", public_feedback_path(conference, session), text: "感想を書く"
  end

  test "感想受付終了トークは受付終了として表示すること" do
    conference = create(:conference)
    session = create(:session, conference: conference, feedback_open: false)

    get public_conference_path(conference)

    assert_response :success
    assert_select "span", "受付終了"
    assert_select "a[href=?]", public_feedback_path(conference, session), count: 0
  end

  test "OGP画像が登録されている場合は公開ページのmetaとビジュアルに反映されること" do
    conference = create(:conference, name: "RubyKaigi 2026")
    conference.ogp_image.attach(
      io: StringIO.new("image"),
      filename: "ogp.png",
      content_type: "image/png"
    )

    get public_conference_path(conference)

    assert_response :success
    assert_select "meta[property='og:title'][content=?]", "RubyKaigi 2026"
    assert_select "meta[property='og:image']", 1
    assert_select "meta[property='og:image:alt'][content=?]", "RubyKaigi 2026 のOGP画像"
    assert_select "meta[name='twitter:card'][content='summary_large_image']"
    assert_select "img[alt=?]", "RubyKaigi 2026 のOGP画像"
    assert_match %r{\Ahttp://www.example.com/rails/active_storage/blobs/redirect/}, css_select("meta[property='og:image']").first["content"]
  end
end
