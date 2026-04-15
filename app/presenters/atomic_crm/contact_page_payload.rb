# frozen_string_literal: true

module AtomicCrm
  class ContactPagePayload
    include PresenterFormatting

    def initialize(contact)
      @contact = contact
    end

    def page_props
      {
        companyCity: contact.company.city,
        companyName: contact.company.name,
        companyWebsite: contact.company.website,
        email: contact.email,
        fullName: contact.full_name,
        lastSeenLabel: timestamp_label(contact.last_seen_at),
        metrics: metrics,
        recentNotes: recent_notes,
        relatedDeals: related_deals,
        statusLabel: contact.status.capitalize,
        statusTone: contact.status,
        thesis:
          "This detail page stays server-rendered while still composing notes, deals, and tasks from " \
          "Rails associations. React on Rails Pro streams the page without introducing a separate API layer.",
        title: contact.title,
        upcomingTasks: upcoming_tasks
      }
    end

    private

    attr_reader :contact

    def metrics
      [
        {
          detail: "Open work tied directly to this relationship",
          label: "Open tasks",
          value: open_tasks.count.to_s
        },
        {
          detail: "Combined value across related deals",
          label: "Deal value",
          value: currency(contact.deals.sum(&:amount))
        },
        {
          detail: "Direct contact notes plus deal-related notes",
          label: "Timeline notes",
          value: related_notes.size.to_s
        },
        {
          detail: "Most recent touchpoint captured in Rails",
          label: "Last activity",
          value: timestamp_label(contact.last_seen_at)
        }
      ]
    end

    def upcoming_tasks
      open_tasks.first(5).map do |task|
        {
          dueLabel: task.due_on.strftime("%b %-d"),
          id: task.id,
          priorityLabel: task.priority.capitalize,
          priorityTone: task.priority,
          title: task.title
        }
      end
    end

    def related_deals
      ordered_deals.map do |deal|
        {
          amount: currency(deal.amount),
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

    def open_tasks
      @open_tasks ||= contact.tasks.where.not(status: "done").order(:due_on, :created_at).to_a
    end

    def ordered_deals
      @ordered_deals ||= contact.deals.order(last_seen_at: :desc, created_at: :desc).to_a
    end

    def related_notes
      @related_notes ||= begin
        deal_ids = ordered_deals.map(&:id)
        Note.includes(:contact, :deal)
            .where(
              "contact_id = :contact_id OR deal_id IN (:deal_ids)",
              contact_id: contact.id,
              deal_ids: deal_ids.presence || [ 0 ]
            )
            .order(created_at: :desc)
            .to_a
      end
    end
  end
end
