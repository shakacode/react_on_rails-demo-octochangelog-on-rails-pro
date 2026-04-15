# frozen_string_literal: true

class ContactsController < ApplicationController
  include ReactOnRailsPro::Stream

  def index
    @page_props = AtomicCrm::ContactsPagePayload.new.page_props

    stream_view_containing_react_components(template: "contacts/index")
  end

  def show
    contact = Contact.find(params[:id])
    @page_props = AtomicCrm::ContactPagePayload.new(contact).page_props

    stream_view_containing_react_components(template: "contacts/show")
  end
end
