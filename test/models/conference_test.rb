require "test_helper"

class ConferenceTest < ActiveSupport::TestCase
  test "generates a slug from the conference name" do
    conference = create(:conference, name: "RubyKaigi 2026", slug: nil)

    assert_equal "rubykaigi2026", conference.slug
  end

  test "generates a Japanese slug from a Japanese conference name" do
    conference = create(:conference, name: "東京Ruby会議", slug: nil)

    assert_equal "東京ruby会議", conference.slug
  end

  test "accepts an OGP image attachment" do
    conference = build(:conference)
    conference.ogp_image.attach(
      io: StringIO.new("image"),
      filename: "ogp.png",
      content_type: "image/png"
    )

    assert conference.valid?
  end

  test "OGP images can be analyzed and resized" do
    conference = create(:conference)
    png = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=")
    conference.ogp_image.attach(io: StringIO.new(png), filename: "pixel.png", content_type: "image/png")

    conference.ogp_image.analyze
    assert_equal 1, conference.ogp_image.metadata["width"]
    assert_equal 1, conference.ogp_image.metadata["height"]

    resized = conference.ogp_image.variant(resize_to_fill: [ 2, 2 ]).processed
    assert_equal [ 2, 2 ], resized.download.byteslice(16, 8).unpack("N2")
  end

  test "rejects non-image OGP attachments" do
    conference = build(:conference)
    conference.ogp_image.attach(
      io: StringIO.new("not an image"),
      filename: "sample.txt",
      content_type: "text/plain"
    )

    assert_not conference.valid?
    assert_includes conference.errors[:ogp_image], "must be a PNG, JPEG, or WebP image"
  end

  test "rejects OGP images larger than 5 MB" do
    conference = build(:conference)
    conference.ogp_image.attach(
      io: StringIO.new("x" * (Conference::OGP_IMAGE_MAX_SIZE + 1)),
      filename: "large.png",
      content_type: "image/png"
    )

    assert_not conference.valid?
    assert_includes conference.errors[:ogp_image], "must be 5MB or smaller"
  end
end
