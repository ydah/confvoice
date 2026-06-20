require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "開催日が一日の場合は開始日だけを表示すること" do
    conference = Struct.new(:starts_on, :ends_on).new(Date.new(2026, 7, 18), Date.new(2026, 7, 18))

    assert_equal "2026/07/18", conference_date_range(conference)
  end

  test "開催日が複数日の場合は開始日と終了日を表示すること" do
    conference = Struct.new(:starts_on, :ends_on).new(Date.new(2026, 7, 18), Date.new(2026, 7, 19))

    assert_equal "2026/07/18 - 2026/07/19", conference_date_range(conference)
  end

  test "会場未設定のカンファレンスは日付だけを表示すること" do
    conference = Struct.new(:venue, :starts_on, :ends_on).new(nil, Date.new(2026, 7, 18), Date.new(2026, 7, 18))

    assert_equal "2026/07/18", conference_location_and_date(conference)
  end

  test "会場設定済みのカンファレンスは会場と日付を表示すること" do
    conference = Struct.new(:venue, :starts_on, :ends_on).new("Hall A", Date.new(2026, 7, 18), Date.new(2026, 7, 18))

    assert_equal "Hall A / 2026/07/18", conference_location_and_date(conference)
  end

  test "セッション時刻は日付なしで表示すること" do
    session = Struct.new(:starts_at, :ends_at, :room).new(
      Time.zone.local(2026, 7, 18, 10, 10),
      Time.zone.local(2026, 7, 18, 10, 40),
      nil
    )

    assert_equal "10:10 - 10:40", session_time_and_room(session)
  end

  test "会場があるセッション時刻には会場を付けること" do
    session = Struct.new(:starts_at, :ends_at, :room).new(
      Time.zone.local(2026, 7, 18, 10, 10),
      Time.zone.local(2026, 7, 18, 10, 40),
      "Main Hall"
    )

    assert_equal "10:10 - 10:40 / Main Hall", session_time_and_room(session)
  end
end
