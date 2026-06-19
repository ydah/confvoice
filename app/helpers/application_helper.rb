module ApplicationHelper
  def rating_stars(rating)
    value = rating.to_i
    safe_join(1.upto(5).map do |index|
      content_tag(:span, index <= value ? "★" : "☆", class: index <= value ? "text-amber-300" : "text-zinc-300 dark:text-zinc-700")
    end)
  end

  def short_datetime(datetime)
    l(datetime, format: :short)
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

  def conference_og_image_url(conference)
    return unless conference&.ogp_image&.attached?

    rails_blob_url(conference.ogp_image)
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
