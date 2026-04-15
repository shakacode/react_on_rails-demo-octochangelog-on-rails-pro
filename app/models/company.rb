# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :contacts, dependent: :destroy
  has_many :deals, dependent: :destroy

  validates :name, presence: true
end
