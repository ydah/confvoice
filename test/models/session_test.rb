require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "slugはタイトルから自動生成されること" do
    session = create(:session, title: "Keynote: Ruby の未来", slug: nil)

    assert_equal "keynote-ruby-の未来", session.slug
  end

  test "日本語タイトルは日本語slugとして自動生成されること" do
    session = create(:session, title: "パフォーマンスチューニング", slug: nil)

    assert_equal "パフォーマンスチューニング", session.slug
  end

  test "日本語slugも有効であること" do
    session = build(:session, slug: "日本語-slug-123")

    assert session.valid?
  end

  test "同じタイトルのslugはカンファレンス内で連番になること" do
    conference = create(:conference)
    create(:session, conference: conference, title: "Keynote: Ruby の未来", slug: nil)
    session = create(:session, conference: conference, title: "Keynote: Ruby の未来", slug: nil)

    assert_equal "keynote-ruby-の未来-2", session.slug
  end

  test "タイトルを変更しても既存slugは維持されること" do
    session = create(:session, title: "Original Talk", slug: nil)

    assert_no_changes -> { session.reload.slug } do
      session.update!(title: "Changed Talk")
    end
  end

  test "slugはカンファレンス内で一意であればよいこと" do
    first = create(:session, slug: "keynote-ruby")
    second = build(:session, slug: "keynote-ruby")

    assert second.valid?

    duplicate = build(:session, conference: first.conference, slug: "keynote-ruby")

    assert_not duplicate.valid?
  end

  test "PDFスライドを添付できること" do
    session = build(:session)
    session.slide_deck.attach(
      io: File.open(Rails.root.join("test/fixtures/files/sample.pdf")),
      filename: "sample.pdf",
      content_type: "application/pdf"
    )

    assert session.valid?
  end

  test "PDF以外のスライド添付は無効" do
    session = build(:session)
    session.slide_deck.attach(
      io: StringIO.new("not a pdf"),
      filename: "sample.txt",
      content_type: "text/plain"
    )

    assert_not session.valid?
  end
end
