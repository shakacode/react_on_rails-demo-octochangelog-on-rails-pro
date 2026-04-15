# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :contact

  validates :due_on, :title, presence: true
end
