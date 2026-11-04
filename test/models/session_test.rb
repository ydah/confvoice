require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "generates a slug from a title containing English and Japanese text" do
    session = create(:session, title: "Keynote: Ruby の未来", slug: nil)

    assert_equal "keynote-ruby-の未来", session.slug
  end

  test "generates a Japanese slug from a Japanese title" do
    session = create(:session, title: "パフォーマンスチューニング", slug: nil)

    assert_equal "パフォーマンスチューニング", session.slug
  end

  test "accepts Japanese slugs" do
    session = build(:session, slug: "日本語-slug-123")

    assert session.valid?
  end

  test "numbers duplicate title slugs within the same conference" do
    conference = create(:conference)
    create(:session, conference: conference, title: "Keynote: Ruby の未来", slug: nil)
    session = create(:session, conference: conference, title: "Keynote: Ruby の未来", slug: nil)

    assert_equal "keynote-ruby-の未来-2", session.slug
  end

  test "preserves the existing slug when the title changes" do
    session = create(:session, title: "Original Talk", slug: nil)

    assert_no_changes -> { session.reload.slug } do
      session.update!(title: "Changed Talk")
    end
  end

  test "requires slugs to be unique only within a conference" do
    first = create(:session, slug: "keynote-ruby")
    second = build(:session, slug: "keynote-ruby")

    assert second.valid?

    duplicate = build(:session, conference: first.conference, slug: "keynote-ruby")

    assert_not duplicate.valid?
  end

  test "requires the start date to fall within the conference dates" do
    conference = create(:conference, starts_on: Date.new(2026, 6, 20), ends_on: Date.new(2026, 6, 21))
    session = build(
      :session,
      conference: conference,
      starts_at: Time.zone.local(2026, 6, 19, 10, 0),
      ends_at: Time.zone.local(2026, 6, 20, 11, 0)
    )

    assert_not session.valid?
    assert_includes session.errors[:starts_at], "must be within the conference dates"
  end

  test "requires the end date to fall within the conference dates" do
    conference = create(:conference, starts_on: Date.new(2026, 6, 20), ends_on: Date.new(2026, 6, 21))
    session = build(
      :session,
      conference: conference,
      starts_at: Time.zone.local(2026, 6, 21, 10, 0),
      ends_at: Time.zone.local(2026, 6, 22, 11, 0)
    )

    assert_not session.valid?
    assert_includes session.errors[:ends_at], "must be within the conference dates"
  end

  test "requires the session to start and end on the same date" do
    conference = create(:conference, starts_on: Date.new(2026, 6, 20), ends_on: Date.new(2026, 6, 21))
    session = build(
      :session,
      conference: conference,
      starts_at: Time.zone.local(2026, 6, 20, 23, 30),
      ends_at: Time.zone.local(2026, 6, 21, 0, 10)
    )

    assert_not session.valid?
    assert_includes session.errors[:ends_at], "must be on the same date as the start time"
  end

  test "accepts PDF slide attachments" do
    session = build(:session)
    session.slide_deck.attach(
      io: File.open(Rails.root.join("test/fixtures/files/sample.pdf")),
      filename: "sample.pdf",
      content_type: "application/pdf"
    )

    assert session.valid?
  end

  test "rejects non-PDF slide attachments" do
    session = build(:session)
    session.slide_deck.attach(
      io: StringIO.new("not a pdf"),
      filename: "sample.txt",
      content_type: "text/plain"
    )

    assert_not session.valid?
  end
end
