class CatRentalRequest < ApplicationRecord
    validates :cat_id, :start_date, :end_date, presence: true
    validates :status, presence: true, inclusion: { in: %w(PENDING APPROVED DENIED).freeze }

    belongs_to :cat
end