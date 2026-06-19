require "test_helper"

class ConferenceTest < ActiveSupport::TestCase
  test "slugはカンファレンス名から自動生成されること" do
    conference = create(:conference, name: "RubyKaigi 2026", slug: nil)

    assert_equal "rubykaigi2026", conference.slug
  end

  test "日本語カンファレンス名は日本語slugとして自動生成されること" do
    conference = create(:conference, name: "東京Ruby会議", slug: nil)

    assert_equal "東京ruby会議", conference.slug
  end

  test "OGP画像を添付できること" do
    conference = build(:conference)
    conference.ogp_image.attach(
      io: StringIO.new("image"),
      filename: "ogp.png",
      content_type: "image/png"
    )

    assert conference.valid?
  end

  test "画像以外のOGP画像添付は無効" do
    conference = build(:conference)
    conference.ogp_image.attach(
      io: StringIO.new("not an image"),
      filename: "sample.txt",
      content_type: "text/plain"
    )

    assert_not conference.valid?
    assert_includes conference.errors[:ogp_image], "はPNG、JPEG、WebPのいずれかを添付してください"
  end

  test "5MBを超えるOGP画像添付は無効" do
    conference = build(:conference)
    conference.ogp_image.attach(
      io: StringIO.new("x" * (Conference::OGP_IMAGE_MAX_SIZE + 1)),
      filename: "large.png",
      content_type: "image/png"
    )

    assert_not conference.valid?
    assert_includes conference.errors[:ogp_image], "は5MB以下にしてください"
  end
end
