# frozen_string_literal: true

require "test_helper"

module AtomicCrm
  class CompanyPagePayloadTest < ActiveSupport::TestCase
    test "builds company detail props with contacts, deals, and notes" do
      company = Company.create!(
        city: "Seattle",
        name: "Northwind Foods",
        sector: "Retail",
        size: "Mid-market",
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
      Note.create!(
        body: "Northwind wants a multi-region rollout option.",
        contact: contact,
        created_at: Time.zone.parse("2026-04-14 07:30:00")
      )
      Note.create!(
        body: "Northwind is close to a pricing review.",
        deal: deal,
        created_at: Time.zone.parse("2026-04-14 06:30:00")
      )

      payload = CompanyPagePayload.new(company).page_props

      assert_equal "Northwind Foods", payload[:name]
      assert_equal 4, payload[:metrics].size
      assert_equal [ "Maya Chen" ], payload[:contacts].map { |payload_contact| payload_contact[:fullName] }
      assert_equal [ "Northwind expansion" ], payload[:relatedDeals].map { |payload_deal| payload_deal[:name] }
      assert_equal 2, payload[:recentNotes].size
    end
  end
end
