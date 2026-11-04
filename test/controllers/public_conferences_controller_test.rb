require "test_helper"

class PublicConferencesControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated users can view the talk list for a published conference" do
    conference = create(:conference)
    session = create(:session, conference: conference, title: "Public Talk")

    get public_conference_path(conference)

    assert_response :success
    assert_select "h1", conference.name
    assert_select "h4", "Public Talk"
    assert_select "a[href=?]", public_feedback_path(conference, session), text: "Write feedback"
  end

  test "groups sessions by date and displays times without a room when none is set" do
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
    assert_no_match "Room TBD", response.body
    assert_select "a[href=?]", public_feedback_path(conference, session), text: "Write feedback"
  end

  test "marks talks with closed feedback submissions as closed" do
    conference = create(:conference)
    session = create(:session, conference: conference, feedback_open: false)

    get public_conference_path(conference)

    assert_response :success
    assert_select "span", "Closed"
    assert_select "a[href=?]", public_feedback_path(conference, session), count: 0
  end

  test "uses the default OGP image in public page metadata" do
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
    assert_select "meta[property='og:image:alt'][content=?]", "RubyKaigi 2026 social preview image"
    assert_select "meta[name='twitter:card'][content='summary_large_image']"
    assert_select "meta[name='twitter:image'][content=?]", default_og_image_url
    assert_select "meta[name='twitter:image:alt'][content=?]", "RubyKaigi 2026 social preview image"
  end

  test "displays uploaded OGP images while keeping the default image in metadata" do
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
    assert_select "meta[property='og:image:alt'][content=?]", "RubyKaigi 2026 social preview image"
    assert_select "meta[property='og:image:type'][content='image/png']"
    assert_select "meta[name='twitter:card'][content='summary_large_image']"
    assert_select "meta[name='twitter:image'][content=?]", default_og_image_url
    assert_select "meta[name='twitter:image:alt'][content=?]", "RubyKaigi 2026 social preview image"
    assert_select "img[alt=?]", "RubyKaigi 2026 social preview image"
  end
end
