class Response < ApplicationRecord
  belongs_to :user
  validates :content, presence: true, unless: -> { bot_response.present? }
  validates :bot_response, presence: true, unless: -> { content.present? }
end
