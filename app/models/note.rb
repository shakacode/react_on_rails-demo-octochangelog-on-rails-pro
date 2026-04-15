# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :contact, optional: true
  belongs_to :deal, optional: true

  validates :body, presence: true

  def subject_label
    return deal.name if deal.present?
    return contact.full_name if contact.present?

    "CRM note"
  end

  def subject_type_label
    return "Deal" if deal.present?
    return "Contact" if contact.present?

    "Note"
  end
end
