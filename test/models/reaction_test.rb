require "test_helper"

class ReactionTest < ActiveSupport::TestCase
  test "有効なリアクションを保存できること" do
    reaction = build(:reaction)

    assert reaction.valid?
  end

  test "同一セッションに同一トークンで同じリアクションは重複できないこと" do
    existing = create(:reaction)
    duplicate = build(:reaction, session: existing.session, kind: existing.kind, respondent_token: existing.respondent_token)

    assert_not duplicate.valid?
  end

  test "受付終了セッションにはリアクションできないこと" do
    session = create(:session, feedback_open: false)
    reaction = build(:reaction, session: session)

    assert_not reaction.valid?
  end
end
