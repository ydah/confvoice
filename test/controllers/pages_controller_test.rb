require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "renders the default OGP image and X metadata on the home page" do
    get root_path

    default_og_image_url = "http://www.example.com/ogp.png"

    assert_response :success
    assert_select "meta[property='og:title'][content=?]", "ConfVoice"
    assert_select "meta[property='og:image'][content=?]", default_og_image_url
    assert_select "meta[property='og:image:secure_url'][content=?]", default_og_image_url
    assert_select "meta[property='og:image:type'][content='image/png']"
    assert_select "meta[property='og:image:width'][content='1280']"
    assert_select "meta[property='og:image:height'][content='670']"
    assert_select "meta[property='og:image:alt'][content=?]", "ConfVoice social preview image"
    assert_select "meta[name='twitter:card'][content='summary_large_image']"
    assert_select "meta[name='twitter:image'][content=?]", default_og_image_url
    assert_select "meta[name='twitter:image:alt'][content=?]", "ConfVoice social preview image"
  end

  test "renders the header logo at a fixed size" do
    get root_path

    assert_response :success
    assert_select "header img[src='/logo.png'][width='32'][height='32']", count: 1
  end

  test "defaults to English and preserves organizer navigation" do
    user = create(:user, :organizer)

    sign_in_as(user)
    get root_path

    assert_equal :en, I18n.default_locale
    assert_select "a[href=?]", conferences_path, text: /Open dashboard/
    assert_select "header a[href=?]", conferences_path, text: "Conferences"
    assert_select ".locale-switch", count: 0
    assert_select "a[hreflang]", count: 0
  end

  test "renders in English despite a previously selected Japanese locale" do
    cookies[:locale] = "ja"

    I18n.with_locale(:ja) do
      get root_path(locale: :ja)
    end

    assert_response :success
    assert_select "h1", text: "Conferences"
    assert_no_match I18n.t("ui.conferences.title", locale: :ja), response.body
  end
end
