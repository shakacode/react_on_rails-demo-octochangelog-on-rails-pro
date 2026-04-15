# frozen_string_literal: true

require "test_helper"

module AtomicCrm
  class HomePagePayloadTest < ActiveSupport::TestCase
    test "builds dashboard and deal board props from database records" do
      company = Company.create!(name: "Northwind Foods")
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

      payload = HomePagePayload.new
      dashboard_props = payload.dashboard_props
      deal_board_props = payload.deal_board_props

      assert_equal "Atomic CRM on Rails Pro", dashboard_props[:appName]
      assert_equal 4, dashboard_props[:metrics].size
      assert_equal "1", dashboard_props[:metrics].find { |metric| metric[:label] == "Companies" }[:value]
      assert_equal [ "Maya Chen" ], dashboard_props[:hotContacts].map { |hot_contact| hot_contact[:fullName] }
      assert_equal [ "Northwind expansion" ], deal_board_props[:stages].first[:deals].map { |pipeline_deal| pipeline_deal[:name] }
      assert_equal %w[lead qualified proposal won], deal_board_props[:stages].map { |stage| stage[:id] }
      assert_equal "Northwind expansion", dashboard_props[:recentNotes].first[:subjectLabel]
    end
  end
end
