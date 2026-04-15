class ComparisonRun < ApplicationRecord
  validates :repository_full_name, :from_version, :to_version, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
