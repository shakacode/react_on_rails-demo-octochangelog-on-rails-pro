# frozen_string_literal: true

require "test_helper"

class ComparisonRunSeedTest < ActiveSupport::TestCase
  setup do
    ComparisonRun.delete_all
  end

  test "demo seeds create deterministic comparison history idempotently" do
    load Rails.root.join("db/seeds.rb")

    # Sort in Ruby (not via SQL ORDER BY) so the comparison is independent of the
    # database's collation: SQLite orders by byte value while Postgres uses a
    # locale collation, which disagree on mixed-case names like "TanStack/router".
    seeded_runs = ComparisonRun.pluck(
      :repository_full_name,
      :from_version,
      :to_version
    ).sort

    assert_equal Octochangelog::DemoCatalog.seed_runs.map(&:values).sort, seeded_runs

    assert_no_difference("ComparisonRun.count") do
      load Rails.root.join("db/seeds.rb")
    end
  end
end
