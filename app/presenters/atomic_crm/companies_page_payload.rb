# frozen_string_literal: true

module AtomicCrm
  class CompaniesPagePayload
    include PresenterFormatting

    def page_props
      {
        companies: companies,
        metrics: metrics,
        thesis:
          "Companies are another strong read-heavy RSC route because they combine relationship data, " \
          "account context, and pipeline rollups without needing a client-side data layer."
      }
    end

    private

    def companies
      Company.includes(:contacts, :deals)
             .order(:name)
             .map do |company|
        {
          city: company.city,
          contactCount: company.contacts.size,
          dealCount: company.deals.size,
          name: company.name,
          openPipeline: currency(company.deals.reject { |deal| deal.stage == "won" }.sum(&:amount)),
          path: "/companies/#{company.id}",
          sector: company.sector,
          size: company.size,
          website: company.website,
          wonRevenue: currency(company.deals.select { |deal| deal.stage == "won" }.sum(&:amount))
        }
      end
    end

    def metrics
      [
        {
          detail: "Seeded CRM accounts now have their own route family",
          label: "Companies",
          value: Company.count.to_s
        },
        {
          detail: "Cross-linked directly to contact detail pages",
          label: "Linked contacts",
          value: Contact.count.to_s
        },
        {
          detail: "Open revenue across non-won deal stages",
          label: "Open pipeline",
          value: currency(Deal.where.not(stage: "won").sum(:amount))
        },
        {
          detail: "Closed revenue already visible without extra API calls",
          label: "Won revenue",
          value: currency(Deal.where(stage: "won").sum(:amount))
        }
      ]
    end
  end
end
