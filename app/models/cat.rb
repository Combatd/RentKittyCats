class Cat < ApplicationRecord
include ActionView::Helpers::DateHelper

    validates :birth_date, :name, presence: true
    validates :color, presence: true
    validates :sex, presence: true, inclusion: { in: %w(M F) }

    def age
        years = Date.today.year - self.birth_date.year
        months = Date.today.month - self.birth_date.month
        days = Date.today.day - self.birth_date.day

        time_ago = Time.now - years - months - days
    end
end