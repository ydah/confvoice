require "test_helper"

class PublicConferencesControllerTest < ActionDispatch::IntegrationTest
  test "公開カンファレンスのトーク一覧を未ログインで閲覧できること" do
    conference = create(:conference)
    session = create(:session, conference: conference, title: "公開トーク")

    get public_conference_path(conference)

    assert_response :success
    assert_select "h1", conference.name
    assert_select "h4", "公開トーク"
    assert_select "a[href=?]", public_feedback_path(conference, session), text: "感想を書く"
  end

  test "セッション一覧は日付ごとに時刻だけを表示し会場未設定なら表示しないこと" do
    conference = create(:conference, venue: nil, starts_on: Date.new(2026, 7, 18), ends_on: Date.new(2026, 7, 19))
    session = create(
      :session,
      conference: conference,
      title: "Opening Talk",
      room: nil,
      starts_at: Time.zone.local(2026, 7, 18, 10, 10),
      ends_at: Time.zone.local(2026, 7, 18, 10, 40)
    )

    get public_conference_path(conference)

    assert_response :success
    assert_select "h3", "2026/07/18"
    assert_select "h4", "Opening Talk"
    assert_includes response.body, "10:10 - 10:40"
    assert_no_match "07/18 10:10 - 07/18 10:40", response.body
    assert_no_match "会場未定", response.body
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

  test "公開ページはデフォルトOGP画像をmetaに反映すること" do
    conference = create(:conference, name: "RubyKaigi 2026")

    get public_conference_path(conference)

    default_og_image_url = "http://www.example.com/ogp.png"

    assert_response :success
    assert_select "meta[property='og:title'][content=?]", "RubyKaigi 2026"
    assert_select "meta[property='og:image'][content=?]", default_og_image_url
    assert_select "meta[property='og:image:secure_url'][content=?]", default_og_image_url
    assert_select "meta[property='og:image:type'][content='image/png']"
    assert_select "meta[property='og:image:width'][content='1280']"
    assert_select "meta[property='og:image:height'][content='670']"
    assert_select "meta[property='og:image:alt'][content=?]", "RubyKaigi 2026 のOGP画像"
    assert_select "meta[name='twitter:card'][content='summary_large_image']"
    assert_select "meta[name='twitter:image'][content=?]", default_og_image_url
    assert_select "meta[name='twitter:image:alt'][content=?]", "RubyKaigi 2026 のOGP画像"
  end

  test "OGP画像が登録されている場合もmetaはデフォルト画像を使いビジュアルには反映されること" do
    conference = create(:conference, name: "RubyKaigi 2026")
    conference.ogp_image.attach(
      io: StringIO.new("image"),
      filename: "ogp.png",
      content_type: "image/png"
    )

    get public_conference_path(conference)

    default_og_image_url = "http://www.example.com/ogp.png"

    assert_response :success
    assert_select "meta[property='og:title'][content=?]", "RubyKaigi 2026"
    assert_select "meta[property='og:image'][content=?]", default_og_image_url
    assert_select "meta[property='og:image:alt'][content=?]", "RubyKaigi 2026 のOGP画像"
    assert_select "meta[property='og:image:type'][content='image/png']"
    assert_select "meta[name='twitter:card'][content='summary_large_image']"
    assert_select "meta[name='twitter:image'][content=?]", default_og_image_url
    assert_select "meta[name='twitter:image:alt'][content=?]", "RubyKaigi 2026 のOGP画像"
    assert_select "img[alt=?]", "RubyKaigi 2026 のOGP画像"
  end
end
