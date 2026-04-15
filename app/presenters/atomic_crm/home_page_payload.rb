# frozen_string_literal: true

module AtomicCrm
  class HomePagePayload
    def dashboard_props
      {
        appName: "Atomic CRM on Rails Pro",
        thesis:
          "Rails owns auth, persistence, and request orchestration while React Server Components " \
          "compose dashboard and record pages. The deal workflow stays in a client island.",
        metrics: [
          { label: "Resources in v1", value: "Contacts, companies, deals, tasks" },
          { label: "Server-rendered surfaces", value: "Dashboard, lists, show pages" },
          { label: "Client island", value: "Deal pipeline board" },
          { label: "Back end", value: "Rails + PostgreSQL" }
        ],
        nextSteps: [
          "Seed realistic CRM data for dashboard and list views.",
          "Port contacts and companies as streamed RSC pages.",
          "Keep the deal board interactive without hydrating the whole app."
        ]
      }
    end

    def deal_board_props
      {
        stages: [
          {
            id: "lead",
            name: "Lead",
            deals: [
              { id: 1, name: "Northwind expansion", owner: "Maya Chen", amount: "$18k" },
              { id: 2, name: "Blue Ocean renewal", owner: "Jordan Lee", amount: "$9k" }
            ]
          },
          {
            id: "qualified",
            name: "Qualified",
            deals: [
              { id: 3, name: "Acme platform rollout", owner: "Ivy Walker", amount: "$42k" }
            ]
          },
          {
            id: "proposal",
            name: "Proposal",
            deals: [
              { id: 4, name: "Helix migration", owner: "Noah Kim", amount: "$67k" }
            ]
          },
          {
            id: "won",
            name: "Won",
            deals: [
              { id: 5, name: "Sunset Analytics", owner: "Lena Park", amount: "$24k" }
            ]
          }
        ]
      }
    end
  end
end
