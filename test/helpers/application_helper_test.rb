require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "displays only the start date for a single-day conference" do
    conference = Struct.new(:starts_on, :ends_on).new(Date.new(2026, 7, 18), Date.new(2026, 7, 18))

    assert_equal "2026/07/18", conference_date_range(conference)
  end

  test "displays the start and end dates for a multi-day conference" do
    conference = Struct.new(:starts_on, :ends_on).new(Date.new(2026, 7, 18), Date.new(2026, 7, 19))

    assert_equal "2026/07/18 - 2026/07/19", conference_date_range(conference)
  end

  test "displays only the dates for a conference without a venue" do
    conference = Struct.new(:venue, :starts_on, :ends_on).new(nil, Date.new(2026, 7, 18), Date.new(2026, 7, 18))

    assert_equal "2026/07/18", conference_location_and_date(conference)
  end

  test "displays the venue and dates for a conference with a venue" do
    conference = Struct.new(:venue, :starts_on, :ends_on).new("Hall A", Date.new(2026, 7, 18), Date.new(2026, 7, 18))

    assert_equal "Hall A / 2026/07/18", conference_location_and_date(conference)
  end

  test "displays session times without dates" do
    session = Struct.new(:starts_at, :ends_at, :room).new(
      Time.zone.local(2026, 7, 18, 10, 10),
      Time.zone.local(2026, 7, 18, 10, 40),
      nil
    )

    assert_equal "10:10 - 10:40", session_time_and_room(session)
  end

  test "includes the room with session times when present" do
    session = Struct.new(:starts_at, :ends_at, :room).new(
      Time.zone.local(2026, 7, 18, 10, 10),
      Time.zone.local(2026, 7, 18, 10, 40),
      "Main Hall"
    )

    assert_equal "10:10 - 10:40 / Main Hall", session_time_and_room(session)
  end
end
