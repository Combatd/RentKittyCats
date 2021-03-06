class Cat < ApplicationRecord
    include ActionView::Helpers::DateHelper

    # User will select from a constant set of colors
    CAT_COLORS = %w(black white orange brown).freeze

    validates :birth_date, :name, :sex, :color, :user_id, presence: true
    validates :color, inclusion: CAT_COLORS
    validates :sex, inclusion: %w(M F)
    validates :user_id, uniqueness: true

    has_many :rental_requests,
        class_name: :CatRentalRequest,
        dependent: :destroy

    belongs_to :owner,
        foreign_key: :user_id,
        class_name: :User

    def age
       return time_ago_in_words(Time.now) if !birth_date
        time_ago_in_words(birth_date)
    end
end