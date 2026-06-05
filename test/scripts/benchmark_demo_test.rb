# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "json"
require "open3"
require "rbconfig"
require "tmpdir"

class BenchmarkDemoTest < ActiveSupport::TestCase
  test "emits json benchmark output with http status and asset snapshots" do
    Dir.mktmpdir("fake-curl") do |bin_dir|
      fake_curl_path = File.join(bin_dir, "curl")
      File.write(fake_curl_path, <<~SH)
        #!/usr/bin/env bash
        printf '200 0.012 0.034'
      SH
      FileUtils.chmod("+x", fake_curl_path)

      stdout, stderr, status = Open3.capture3(
        {
          "BENCHMARK_BASE_URL" => "http://example.test",
          "BENCHMARK_HOME_RUNS" => "1",
          "BENCHMARK_OUTPUT" => "json",
          "BENCHMARK_SKIP_COMPARE" => "1",
          "PATH" => "#{bin_dir}:#{ENV.fetch('PATH')}"
        },
        RbConfig.ruby,
        Rails.root.join("bin/benchmark-demo").to_s,
        chdir: Rails.root.to_s
      )

      assert status.success?, stderr

      report = JSON.parse(stdout)
      assert_equal "http://example.test", report.fetch("base_url")
      assert_equal [ "home" ], report.fetch("routes").map { |route| route.fetch("label") }
      assert_equal [ 200 ], report.fetch("routes").first.fetch("http_codes")
      assert_equal 0.034, report.fetch("routes").first.fetch("time_total").fetch("avg")
      assert_includes report.fetch("assets").map { |asset| asset.fetch("path") }, "public/packs/css/application.css"
    end
  end
end
