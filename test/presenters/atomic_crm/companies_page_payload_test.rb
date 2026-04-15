# frozen_string_literal: true

require "test_helper"

module AtomicCrm
  class CompaniesPagePayloadTest < ActiveSupport::TestCase
    test "builds company cards and aggregate metrics" do
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
      Deal.create!(
        amount: 18_000,
        company: company,
        contact: contact,
        last_seen_at: Time.zone.parse("2026-04-14 08:30:00"),
        name: "Northwind expansion",
        stage: "lead"
      )

      payload = CompaniesPagePayload.new.page_props

      assert_equal 4, payload[:metrics].size
      assert_equal [ "Northwind Foods" ], payload[:companies].map { |payload_company| payload_company[:name] }
      assert_equal "https://northwind.example", payload[:companies].first[:website]
      assert_equal "$18,000", payload[:companies].first[:openPipeline]
    end
  end
end
