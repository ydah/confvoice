module SlugNormalizer
  FORMAT = /\A[\p{L}\p{N}-]+\z/

  module_function

  def normalize(source, fallback:)
    return ascii_slug(source, fallback:) if source.to_s.ascii_only?

    unicode_slug(source).presence || ascii_slug(source, fallback:)
  end

  def ascii_slug(source, fallback:)
    parameterized = source.to_s.parameterize
    parameterized.presence || fallback
  end

  def unicode_slug(source)
    source.to_s.unicode_normalize(:nfkc)
          .downcase
          .strip
          .gsub(/[\s_]+/, "-")
          .gsub(/[^\p{L}\p{N}-]+/, "-")
          .gsub(/-+/, "-")
          .delete_prefix("-")
          .delete_suffix("-")
  end
end
