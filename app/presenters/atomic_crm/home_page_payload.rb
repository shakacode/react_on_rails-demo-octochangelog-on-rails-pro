# frozen_string_literal: true

module AtomicCrm
  class HomePagePayload
    include PresenterFormatting

    STAGES = [
      { id: "lead", name: "Lead" },
      { id: "qualified", name: "Qualified" },
      { id: "proposal", name: "Proposal" },
      { id: "won", name: "Won" }
    ].freeze

    def dashboard_props
      {
        appName: "Atomic CRM on Rails Pro",
        thesis:
          "Rails owns auth, persistence, and request orchestration while React Server Components " \
          "compose dashboard and record pages. The deal workflow stays in a client island.",
        metrics: metrics,
        hotContacts: hot_contacts,
        pipelineSummary: pipeline_summary,
        recentNotes: recent_notes,
        upcomingTasks: upcoming_tasks
      }
    end

    def deal_board_props
      {
        stages: STAGES.map { |stage| stage_payload(stage) }
      }
    end

    private

    def metrics
      [
        { label: "Companies", value: Company.count.to_s },
        { label: "Contacts", value: Contact.count.to_s },
        { label: "Open pipeline", value: currency(deals.reject { |deal| deal.stage == "won" }.sum(&:amount)) },
        { label: "Open tasks", value: Task.where.not(status: "done").count.to_s }
      ]
    end

    def hot_contacts
      Contact.includes(:company)
             .where(status: "hot")
             .order(last_seen_at: :desc, created_at: :desc)
             .limit(5)
             .map do |contact|
        {
          id: contact.id,
          companyName: contact.company.name,
          fullName: contact.full_name,
          lastSeenLabel: timestamp_label(contact.last_seen_at),
          title: contact.title
        }
      end
    end

    def pipeline_summary
      STAGES.map do |stage|
        scoped_deals = deals_by_stage.fetch(stage[:id], [])

        {
          id: stage[:id],
          name: stage[:name],
          dealCount: scoped_deals.size,
          totalAmount: currency(scoped_deals.sum(&:amount))
        }
      end
    end

    def recent_notes
      Note.includes(:contact, :deal)
          .order(created_at: :desc)
          .limit(5)
          .map do |note|
        {
          id: note.id,
          body: note.body,
          createdAtLabel: timestamp_label(note.created_at),
          subjectLabel: note.subject_label,
          subjectType: note.subject_type_label
        }
      end
    end

    def upcoming_tasks
      Task.includes(:contact)
          .where.not(status: "done")
          .order(:due_on, :created_at)
          .limit(5)
          .map do |task|
        {
          id: task.id,
          contactName: task.contact.full_name,
          dueLabel: task.due_on.strftime("%b %-d"),
          priority: task.priority.capitalize,
          title: task.title
        }
      end
    end

    def stage_payload(stage)
      scoped_deals = deals_by_stage.fetch(stage[:id], [])

      {
        id: stage[:id],
        name: stage[:name],
        deals: scoped_deals.map do |deal|
          {
            amount: currency(deal.amount),
            companyName: deal.company.name,
            id: deal.id,
            name: deal.name,
            owner: deal.contact.full_name
          }
        end
      }
    end

    def deals
      @deals ||= Deal.includes(:company, :contact).order(last_seen_at: :desc, created_at: :desc).to_a
    end

    def deals_by_stage
      @deals_by_stage ||= deals.group_by(&:stage)
    end
  end
end
