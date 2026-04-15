require "test_helper"

module Github
  class ClientTest < ActiveSupport::TestCase
    test "extracts versions from scoped tags" do
      assert_equal "4.9.4", Client.extract_version("@yarnpkg/cli/4.9.4")
      assert_equal "1.2.3", Client.extract_version("v1.2.3")
    end

    test "filters releases by an open-closed version range" do
      releases = [
        { "tag_name" => "v3.0.0" },
        { "tag_name" => "v2.0.0" },
        { "tag_name" => "v1.0.0" }
      ]

      filtered = Client.filter_releases_by_range(releases, from: "1.0.0", to: "latest")

      assert_equal [ "v3.0.0", "v2.0.0" ], filtered.map { |release| release["tag_name"] }
    end
  end
end
