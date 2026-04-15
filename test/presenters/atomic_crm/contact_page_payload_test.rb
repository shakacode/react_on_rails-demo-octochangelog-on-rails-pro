# frozen_string_literal: true

require "test_helper"

module AtomicCrm
  class ContactPagePayloadTest < ActiveSupport::TestCase
    test "builds detail props with related tasks, notes, and deals" do
      company = Company.create!(
        city: "Seattle",
        name: "Northwind Foods",
        website: "https://northwind.example"
      )
      contact = Contact.create!(
        company: company,
        email: "maya@example.test",
        first_name: "Maya",
        last_name: "Chen",
        last_seen_at: Time.zone.parse("2026-04-14 09:30:00"),
        status: "hot",
        title: "VP Revenue"
      )
      deal = Deal.create!(
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
      Note.create!(
        body: "Northwind wants a multi-region rollout option.",
        deal: deal,
        created_at: Time.zone.parse("2026-04-14 07:30:00")
      )

      payload = ContactPagePayload.new(contact).page_props

      assert_equal "Maya Chen", payload[:fullName]
      assert_equal "Northwind Foods", payload[:companyName]
      assert_equal 4, payload[:metrics].size
      assert_equal [ "Northwind expansion" ], payload[:relatedDeals].map { |related_deal| related_deal[:name] }
      assert_equal [ "Review discovery notes" ], payload[:upcomingTasks].map { |task| task[:title] }
      assert_equal "Northwind expansion", payload[:recentNotes].first[:subjectLabel]
    end
  end
end
