module ApplicationHelper
  DEFAULT_OG_IMAGE_PATH = "/ogp.png"
  DEFAULT_OG_IMAGE_TYPE = "image/png"
  DEFAULT_OG_IMAGE_WIDTH = 1280
  DEFAULT_OG_IMAGE_HEIGHT = 670

  def rating_stars(rating)
    value = rating.to_i
    safe_join(1.upto(5).map do |index|
      content_tag(:span, index <= value ? "★" : "☆", class: index <= value ? "text-amber-300" : "text-zinc-300 dark:text-zinc-700")
    end)
  end

  def short_datetime(datetime)
    l(datetime, format: :short)
  end

  def conference_date_range(conference)
    return l(conference.starts_on) if conference.starts_on == conference.ends_on

    "#{l(conference.starts_on)} - #{l(conference.ends_on)}"
  end

  def conference_location_and_date(conference)
    [conference.venue.presence, conference_date_range(conference)].compact.join(" / ")
  end

  def session_date_groups(sessions)
    sessions.group_by { |session| session.starts_at.to_date }
  end

  def session_time_range(session)
    "#{l(session.starts_at, format: "%H:%M")} - #{l(session.ends_at, format: "%H:%M")}"
  end

  def session_time_and_room(session)
    return session_time_range(session) if session.room.blank?

    "#{session_time_range(session)} / #{session.room}"
  end

  def session_datetime_and_room(session)
    ends_at = session.starts_at.to_date == session.ends_at.to_date ? l(session.ends_at, format: "%H:%M") : short_datetime(session.ends_at)
    datetime_range = "#{short_datetime(session.starts_at)} - #{ends_at}"
    return datetime_range if session.room.blank?

    "#{datetime_range} / #{session.room}"
  end

  def reaction_options
    Reaction.kinds.keys.map { |kind| [kind, Reaction.emoji_for(kind)] }
  end

  def reaction_count(session, kind)
    session.reactions.where(kind: kind).count
  end

  def conference_og_description(conference)
    conference.description.to_s.squish.presence || "#{conference.name} のトーク一覧と感想投稿ページです。"
  end

  def conference_og_image_alt(conference)
    "#{conference.name} のOGP画像"
  end

  def conference_og_image_url(_conference)
    default_og_image_url
  end

  def conference_og_image_type(_conference)
    DEFAULT_OG_IMAGE_TYPE
  end

  def default_og_image_url
    "#{request.base_url}#{DEFAULT_OG_IMAGE_PATH}"
  end

  def default_og_image_alt
    "#{t("app.name")} のOGP画像"
  end

  def keyword_size_class(count, max_count)
    return "text-sm" if max_count.to_i <= 1

    ratio = count.to_f / max_count
    return "text-2xl" if ratio >= 0.75
    return "text-xl" if ratio >= 0.5
    return "text-lg" if ratio >= 0.3

    "text-sm"
  end
end
