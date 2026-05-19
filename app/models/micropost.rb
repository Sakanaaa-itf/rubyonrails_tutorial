class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :picture
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :acceptable_picture

  private

  def acceptable_picture
    return unless picture.attached?

    unless picture.content_type.in?(%w[image/jpeg image/gif image/png])
      errors.add(:picture, 'must be a JPEG, GIF, or PNG')
    end

    return unless picture.blob.byte_size > 5.megabytes

    errors.add(:picture, 'should be less than 5MB')
  end
end
