# frozen_string_literal: true

class Deal < ApplicationRecord
  belongs_to :company
  belongs_to :contact
  has_many :notes, dependent: :destroy

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :name, :stage, presence: true
end
