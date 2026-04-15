# frozen_string_literal: true

require "test_helper"

module AtomicCrm
  class HomePagePayloadTest < ActiveSupport::TestCase
    test "builds dashboard and deal board props" do
      payload = HomePagePayload.new

      dashboard_props = payload.dashboard_props
      deal_board_props = payload.deal_board_props

      assert_equal "Atomic CRM on Rails Pro", dashboard_props[:appName]
      assert_equal 4, dashboard_props[:metrics].size
      assert_equal 3, dashboard_props[:nextSteps].size
      assert_equal %w[lead qualified proposal won], deal_board_props[:stages].map { |stage| stage[:id] }
      assert_equal 5, deal_board_props[:stages].sum { |stage| stage[:deals].size }
    end
  end
end
