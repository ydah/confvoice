class Conference < ApplicationRecord
  OGP_IMAGE_CONTENT_TYPES = %w[image/png image/jpeg image/webp].freeze
  OGP_IMAGE_MAX_SIZE = 5.megabytes

  attr_accessor :remove_ogp_image

  has_many :conference_memberships, dependent: :destroy
  has_many :members, through: :conference_memberships, source: :user
  has_many :sessions, dependent: :destroy
  has_one_attached :ogp_image

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: SlugNormalizer::FORMAT }
  validates :starts_on, :ends_on, presence: true
  validate :ends_on_after_starts_on
  validate :ogp_image_must_be_supported_image

  before_validation :generate_slug, on: :create

  scope :published, -> { where(published: true) }
  scope :chronological, -> { order(starts_on: :desc, id: :desc) }

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?

    base_slug = SlugNormalizer.normalize(name, fallback: "conference")
    base_slug = base_slug.gsub(/(?<=[a-z])-(?=\d{4}\z)/, "")
    self.slug = unique_slug(base_slug)
  end

  def unique_slug(base_slug)
    candidate = base_slug
    suffix = 2

    while self.class.exists?(slug: candidate)
      candidate = "#{base_slug}-#{suffix}"
      suffix += 1
    end

    candidate
  end

  def ends_on_after_starts_on
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, "は開始日以降の日付にしてください") if ends_on < starts_on
  end

  def ogp_image_must_be_supported_image
    return unless ogp_image.attached?

    unless ogp_image.blob.content_type.in?(OGP_IMAGE_CONTENT_TYPES)
      errors.add(:ogp_image, "はPNG、JPEG、WebPのいずれかを添付してください")
    end

    if ogp_image.blob.byte_size > OGP_IMAGE_MAX_SIZE
      errors.add(:ogp_image, "は5MB以下にしてください")
    end
  end
end
