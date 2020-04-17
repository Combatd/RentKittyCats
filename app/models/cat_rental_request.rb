class CatRentalRequest < ApplicationRecord
    validates :cat_id, :start_date, :end_date, presence: true
    validates :status, presence: true, inclusion: { in: %w(PENDING APPROVED DENIED).freeze }

    belongs_to :cat

    def overlapping_requests # SQL Queries only, not Ruby
        CatRentalRequest,
          where.not(id: self.id),
          where(cat_id: self.cat_id),
          where.not('start_date > :end_date OR end_date < :start_date',
                start_date: self.start_date, end_date: self.end_date)
    end

    def overlapping_approved_requests # returns SQL Record
        overlapping_requests.where(status: 'APPROVED')
    end

    def does_not_overlap_approved_requests
        return if self.status == 'DENIED'
        errors[:cat] << "cannot process request" if overlapping_approved_requests.exists?
    end

    def overlapping_pending_requests
        overlapping_requests.where(status: 'PENDING')
    end
end