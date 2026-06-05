# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionController::TestCase
  tests HomeController

  setup do
    ComparisonRun.delete_all
    stub_stream_render
  end

  test "recent runs include every canonical seeded comparison" do
    load Rails.root.join("db/seeds.rb")

    get :index

    props = @controller.instance_variable_get(:@home_page_props)
    seeded_repositories = Octochangelog::DemoCatalog.seed_runs.map { |run| run.fetch(:repository_full_name) }

    assert_equal seeded_repositories.size, props.fetch(:recentRuns).size
    assert_equal seeded_repositories.sort, props.fetch(:recentRuns).map { |run| run.fetch(:repositoryFullName) }.sort
  end

  private

  def stub_stream_render
    @controller.define_singleton_method(:stream_view_containing_react_components) do |template:|
      render inline: "<p>stubbed #{template}</p>", layout: false
    end
  end
end
