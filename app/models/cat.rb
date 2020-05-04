class Cat < ApplicationRecord
     sinclude ActionView::Helpers::DateHelper

    validates :birth_date, :name, :sex, :color, :user_id, presence: true
    validates :color, presence: true
    validates :sex, presence: true, inclusion: %w(M F)
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