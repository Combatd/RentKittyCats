class Cat < ApplicationRecord
include ActionView::Helpers::DateHelper

    validates :birth_date, :name, presence: true
    validates :color, presence: true
    validates :sex, presence: true, inclusion: { in: %w(M F) }
    validates :user_id, uniqueness: true

    has_many :rental_requests,
        class_name: :CatRentalRequest,
        dependent: :destroy

    belongs_to :owner,
        foreign_key: :user_id,
        class_name: :User

    def age
       time_ago_in_words(birth_date)
    end
end