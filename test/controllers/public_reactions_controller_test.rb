require "test_helper"

class PublicReactionsControllerTest < ActionDispatch::IntegrationTest
  test "聴衆がリアクションできること" do
    session = create(:session)

    assert_difference "Reaction.count", 1 do
      post public_reactions_path(session.conference, session), params: {
        reaction: { kind: "fire" }
      }
    end

    assert_redirected_to public_feedback_path(session.conference, session)
  end

  test "同じリアクションは重複送信できないこと" do
    session = create(:session)

    post public_reactions_path(session.conference, session), params: { reaction: { kind: "idea" } }

    assert_no_difference "Reaction.count" do
      post public_reactions_path(session.conference, session), params: { reaction: { kind: "idea" } }
    end
  end
end
