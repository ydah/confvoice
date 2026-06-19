class FeedbackKeywordExtractor
  STOP_WORDS = %w[
    です ます でした ました する した こと もの これ それ あれ
    とても かなり もう 少し よく 良い 良かった ある いる
    the and for with this that was were are you your
  ].freeze

  def initialize(feedbacks)
    @feedbacks = feedbacks
  end

  def top(limit: 20)
    tokens
      .tally
      .reject { |word, count| count < 2 || STOP_WORDS.include?(word.downcase) }
      .sort_by { |word, count| [-count, word] }
      .first(limit)
  end

  private

  attr_reader :feedbacks

  def tokens
    feedbacks.flat_map do |feedback|
      feedback.body.to_s.scan(/[[:alnum:]一-龠ぁ-んァ-ヶー]{2,}/)
    end
  end
end
