require "test_helper"

class ComparisonRunTest < ActiveSupport::TestCase
  test "requires the repository and version fields" do
    comparison_run = ComparisonRun.new

    assert_not comparison_run.valid?
    assert_includes comparison_run.errors[:repository_full_name], "can't be blank"
    assert_includes comparison_run.errors[:from_version], "can't be blank"
    assert_includes comparison_run.errors[:to_version], "can't be blank"
  end
end
