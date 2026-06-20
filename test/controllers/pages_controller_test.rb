require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "ホームにデフォルトOGP画像とX向けmetaを表示すること" do
    get root_path

    default_og_image_url = "http://www.example.com/ogp.png"

    assert_response :success
    assert_select "meta[property='og:title'][content=?]", "ConfVoice"
    assert_select "meta[property='og:image'][content=?]", default_og_image_url
    assert_select "meta[property='og:image:secure_url'][content=?]", default_og_image_url
    assert_select "meta[property='og:image:type'][content='image/png']"
    assert_select "meta[property='og:image:width'][content='1280']"
    assert_select "meta[property='og:image:height'][content='670']"
    assert_select "meta[property='og:image:alt'][content=?]", "ConfVoice のOGP画像"
    assert_select "meta[name='twitter:card'][content='summary_large_image']"
    assert_select "meta[name='twitter:image'][content=?]", default_og_image_url
    assert_select "meta[name='twitter:image:alt'][content=?]", "ConfVoice のOGP画像"
  end

  test "ヘッダーロゴを固定サイズで表示すること" do
    get root_path

    assert_response :success
    assert_select "header img[src='/logo.png'][width='32'][height='32']", count: 1
  end
end
