# frozen_string_literal: true

module AtomicCrm
  class CompanyPagePayload
    include PresenterFormatting

    def initialize(company)
      @company = company
    end

    def page_props
      {
        city: company.city,
        contacts: contacts,
        metrics: metrics,
        name: company.name,
        recentNotes: recent_notes,
        relatedDeals: related_deals,
        sector: company.sector,
        size: company.size,
        thesis:
          "This company route shows how Rails can assemble account summaries, linked contacts, deals, and " \
          "timeline notes into one streamed page while keeping route-level JavaScript tiny.",
        website: company.website
      }
    end

    private

    attr_reader :company

    def contacts
      company.contacts.order(last_seen_at: :desc, last_name: :asc, first_name: :asc).map do |contact|
        {
          fullName: contact.full_name,
          id: contact.id,
          lastSeenLabel: timestamp_label(contact.last_seen_at),
          path: "/contacts/#{contact.id}",
          statusLabel: contact.status.capitalize,
          statusTone: contact.status,
          title: contact.title
        }
      end
    end

    def metrics
      [
        {
          detail: "People attached to this account",
          label: "Contacts",
          value: company.contacts.size.to_s
        },
        {
          detail: "Open revenue still in the pipeline",
          label: "Open pipeline",
          value: currency(company.deals.reject { |deal| deal.stage == "won" }.sum(&:amount))
        },
        {
          detail: "Closed revenue already captured for this account",
          label: "Won revenue",
          value: currency(company.deals.select { |deal| deal.stage == "won" }.sum(&:amount))
        },
        {
          detail: "Notes from linked contacts and deals",
          label: "Timeline notes",
          value: related_notes.size.to_s
        }
      ]
    end

    def related_deals
      company.deals.order(last_seen_at: :desc, created_at: :desc).map do |deal|
        {
          amount: currency(deal.amount),
          contactName: deal.contact.full_name,
          id: deal.id,
          lastSeenLabel: timestamp_label(deal.last_seen_at),
          name: deal.name,
          stageLabel: deal.stage.capitalize
        }
      end
    end

    def recent_notes
      related_notes.first(5).map do |note|
        {
          body: note.body,
          createdAtLabel: timestamp_label(note.created_at),
          id: note.id,
          subjectLabel: note.subject_label,
          subjectType: note.subject_type_label
        }
      end
    end

    def related_notes
      @related_notes ||= begin
        contact_ids = company.contacts.ids
        deal_ids = company.deals.ids

        Note.includes(:contact, :deal)
            .where(
              "contact_id IN (:contact_ids) OR deal_id IN (:deal_ids)",
              contact_ids: contact_ids.presence || [ 0 ],
              deal_ids: deal_ids.presence || [ 0 ]
            )
            .order(created_at: :desc)
            .to_a
      end
    end
  end
end
