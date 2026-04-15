# frozen_string_literal: true

require "test_helper"

module AtomicCrm
  class ContactsPagePayloadTest < ActiveSupport::TestCase
    test "builds directory props from contacts, tasks, and deals" do
      company = Company.create!(city: "Seattle", name: "Northwind Foods", sector: "Retail")
      contact = Contact.create!(
        company: company,
        email: "maya@example.test",
        first_name: "Maya",
        last_name: "Chen",
        last_seen_at: Time.zone.parse("2026-04-14 09:30:00"),
        status: "hot",
        title: "VP Revenue"
      )
      Deal.create!(
        amount: 18_000,
        company: company,
        contact: contact,
        last_seen_at: Time.zone.parse("2026-04-14 08:30:00"),
        name: "Northwind expansion",
        stage: "lead"
      )
      Task.create!(
        contact: contact,
        due_on: Date.new(2026, 4, 16),
        priority: "high",
        status: "open",
        title: "Review discovery notes"
      )

      payload = ContactsPagePayload.new.page_props

      assert_equal 4, payload[:metrics].size
      assert_equal [ "Maya Chen" ], payload[:contacts].map { |directory_contact| directory_contact[:fullName] }
      assert_equal "Northwind Foods", payload[:contacts].first[:companyName]
      assert_equal "1 deals · $18,000", payload[:contacts].first[:dealSummary]
      assert_equal "Northwind Foods", payload[:companyRollup].first[:name]
    end
  end
end
