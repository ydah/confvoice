require "test_helper"

class ReactionTest < ActiveSupport::TestCase
  test "accepts valid reactions" do
    reaction = build(:reaction)

    assert reaction.valid?
  end

  test "rejects duplicate reactions with the same session and respondent token" do
    existing = create(:reaction)
    duplicate = build(:reaction, session: existing.session, kind: existing.kind, respondent_token: existing.respondent_token)

    assert_not duplicate.valid?
  end

  test "rejects reactions for sessions with closed submissions" do
    session = create(:session, feedback_open: false)
    reaction = build(:reaction, session: session)

    assert_not reaction.valid?
  end
end
