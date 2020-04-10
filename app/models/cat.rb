class Cat < ApplicationRecord
    validates :birth_date, :name, presence: true
    validates :color, presence: true
    validates :sex, presence: true
end