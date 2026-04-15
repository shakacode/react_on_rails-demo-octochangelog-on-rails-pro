# frozen_string_literal: true

class CompaniesController < ApplicationController
  include ReactOnRailsPro::Stream

  def index
    @page_props = AtomicCrm::CompaniesPagePayload.new.page_props

    stream_view_containing_react_components(template: "companies/index")
  end

  def show
    company = Company.find(params[:id])
    @page_props = AtomicCrm::CompanyPagePayload.new(company).page_props

    stream_view_containing_react_components(template: "companies/show")
  end
end
