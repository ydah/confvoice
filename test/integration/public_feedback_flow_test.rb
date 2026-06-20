require "test_helper"

class PublicFeedbackFlowTest < ActionDispatch::IntegrationTest
  test "聴衆が感想を投稿できること" do
    session = create(:session, feedback_open: true)

    assert_equal "/#{session.conference.slug}/talks/#{ERB::Util.url_encode(session.slug)}", public_feedback_path(session.conference, session)

    get public_feedback_path(session.conference, session)
    assert_response :success
    assert_select "a[href=?]", public_conference_path(session.conference), text: "トーク一覧へ"
    assert_select "form[data-controller=?][data-feedback-draft-key-value=?]", "feedback-draft", "feedback-draft:#{session.conference.slug}:#{session.slug}"
    assert_select "input[name=?][data-feedback-draft-target=?]", "feedback[respondent_name]", "field"
    assert_select "textarea[name=?][data-feedback-draft-target=?]", "feedback[body]", "field"
    assert_select "input[name=?]", "feedback[rating]", count: 0

    assert_difference "Feedback.count", 1 do
      post public_feedback_path(session.conference, session), params: {
        feedback: { respondent_name: "参加者 太郎", body: "とても良かった！" }
      }
    end
    assert_redirected_to public_feedback_thanks_path(session.conference, session)
    assert_equal "参加者 太郎", Feedback.last.respondent_name
    assert_nil Feedback.last.rating
  end

  test "日本語slugの投稿URLはエスケープされること" do
    session = create(:session, title: "パフォーマンスチューニング", slug: nil)

    assert_equal "パフォーマンスチューニング", session.slug
    assert_includes public_feedback_path(session.conference, session), "%E3%83%91%E3%83%95"
  end

  test "感想受付終了セッションには投稿できないこと" do
    session = create(:session, feedback_open: false)

    get public_feedback_path(session.conference, session)

    assert_response :forbidden
    assert_select "a[href=?]", public_conference_path(session.conference), text: "トーク一覧へ"
  end
end
