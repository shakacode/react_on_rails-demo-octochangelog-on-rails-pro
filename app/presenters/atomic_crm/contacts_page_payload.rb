# frozen_string_literal: true

module AtomicCrm
  class ContactsPagePayload
    include PresenterFormatting

    def page_props
      {
        contacts: contacts,
        companyRollup: company_rollup,
        metrics: metrics,
        thesis:
          "The contacts directory is a streamed RSC route backed directly by Rails models. " \
          "Each row links to a detail page without turning the whole CRM into a client SPA."
      }
    end

    private

    def contacts
      ordered_contacts.map do |contact|
        {
          city: contact.company.city,
          companyName: contact.company.name,
          dealSummary: "#{contact.deals.size} deals · #{currency(contact.deals.sum(&:amount))}",
          email: contact.email,
          fullName: contact.full_name,
          id: contact.id,
          lastSeenLabel: timestamp_label(contact.last_seen_at),
          path: "/contacts/#{contact.id}",
          statusLabel: contact.status.capitalize,
          statusTone: contact.status,
          taskSummary: task_count_label(contact.tasks.count { |task| task.status != "done" }),
          title: contact.title
        }
      end
    end

    def company_rollup
      Company.includes(:contacts, :deals)
             .order(:name)
             .map do |company|
        {
          city: company.city,
          contactCount: company.contacts.size,
          name: company.name,
          openPipeline: currency(company.deals.reject { |deal| deal.stage == "won" }.sum(&:amount)),
          sector: company.sector
        }
      end
    end

    def metrics
      [
        {
          detail: "Across #{Company.count} seeded accounts",
          label: "Total contacts",
          value: Contact.count.to_s
        },
        {
          detail: "Prioritized by last activity",
          label: "Hot contacts",
          value: Contact.where(status: "hot").count.to_s
        },
        {
          detail: "Task list stays server-owned until a workflow truly needs JS",
          label: "Open tasks",
          value: Task.where.not(status: "done").count.to_s
        },
        {
          detail: "Linked deal value visible directly in the directory",
          label: "Pipeline coverage",
          value: currency(Deal.where.not(stage: "won").sum(:amount))
        }
      ]
    end

    def ordered_contacts
      @ordered_contacts ||= Contact.includes(:company, :deals, :tasks)
                                   .order(last_seen_at: :desc, last_name: :asc, first_name: :asc)
                                   .to_a
    end
  end
end
