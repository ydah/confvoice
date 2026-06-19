require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "有効な感想を保存できること" do
    feedback = build(:feedback)

    assert feedback.valid?
  end

  test "新規投稿は登壇者には未共有であること" do
    feedback = create(:feedback)

    assert_not feedback.speaker_visible?
  end

  test "新規投稿直後には登壇者通知を送らないこと" do
    speaker = create(:user, email_address: "speaker-notify@example.com")
    session = create(:session, speaker_user: speaker)

    assert_no_enqueued_jobs only: FeedbackNotificationJob do
      create(:feedback, session: session)
    end
  end

  test "登壇者に共有したタイミングで通知を送ること" do
    speaker = create(:user, email_address: "speaker-notify@example.com")
    session = create(:session, speaker_user: speaker)
    feedback = create(:feedback, session: session)

    assert_enqueued_jobs 1, only: FeedbackNotificationJob do
      feedback.share_with_speaker!
    end
  end

  test "評価が1〜5の範囲外だと無効" do
    feedback = build(:feedback, rating: 6)

    assert_not feedback.valid?
    assert_includes feedback.errors[:rating], "は1〜5の範囲で入力してください"
  end

  test "評価なしでも保存できること" do
    feedback = build(:feedback, rating: nil)

    assert feedback.valid?
  end

  test "名前と感想は必須" do
    feedback = build(:feedback, respondent_name: "", body: "")

    assert_not feedback.valid?
    assert_includes feedback.errors[:respondent_name], "を入力してください"
    assert_includes feedback.errors[:body], "を入力してください"
  end

  test "同一セッションに同一トークンで重複投稿できないこと" do
    existing = create(:feedback)
    duplicate = build(:feedback, session: existing.session, respondent_token: existing.respondent_token)

    assert_not duplicate.valid?
  end

  test "感想受付終了セッションには投稿できないこと" do
    session = create(:session, feedback_open: false)
    feedback = build(:feedback, session: session)

    assert_not feedback.valid?
  end

  test "感想受付終了後でも主催者共有状態は更新できること" do
    feedback = create(:feedback)
    feedback.session.update!(feedback_open: false)

    assert_changes -> { feedback.reload.speaker_visible? }, from: false, to: true do
      feedback.share_with_speaker!
    end
  end
end
