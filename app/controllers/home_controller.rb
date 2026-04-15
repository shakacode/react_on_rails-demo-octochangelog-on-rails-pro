class HomeController < ApplicationController
  include ReactOnRailsPro::Stream

  def index
    payload = AtomicCrm::HomePagePayload.new
    @dashboard_props = payload.dashboard_props
    @deal_board_props = payload.deal_board_props

    stream_view_containing_react_components(template: "home/index")
  end
end
