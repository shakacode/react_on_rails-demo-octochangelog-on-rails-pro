# frozen_string_literal: true

class Contact < ApplicationRecord
  belongs_to :company
  has_many :deals, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
