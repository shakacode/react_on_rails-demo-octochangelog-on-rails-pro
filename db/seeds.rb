# frozen_string_literal: true

Note.delete_all
Task.delete_all
Deal.delete_all
Contact.delete_all
Company.delete_all

companies = {
  northwind: Company.create!(
    name: "Northwind Foods",
    sector: "Retail",
    size: "Mid-market",
    website: "https://northwind.example",
    city: "Seattle"
  ),
  blue_ocean: Company.create!(
    name: "Blue Ocean Systems",
    sector: "Infrastructure",
    size: "Enterprise",
    website: "https://blueocean.example",
    city: "San Diego"
  ),
  helix: Company.create!(
    name: "Helix Labs",
    sector: "Biotech",
    size: "Growth",
    website: "https://helix.example",
    city: "Boston"
  ),
  sunset: Company.create!(
    name: "Sunset Analytics",
    sector: "Analytics",
    size: "SMB",
    website: "https://sunset.example",
    city: "Portland"
  )
}

contacts = {
  maya: Contact.create!(
    company: companies[:northwind],
    email: "maya@northwind.example",
    first_name: "Maya",
    last_name: "Chen",
    last_seen_at: 1.day.ago,
    status: "hot",
    title: "VP Revenue"
  ),
  jordan: Contact.create!(
    company: companies[:blue_ocean],
    email: "jordan@blueocean.example",
    first_name: "Jordan",
    last_name: "Lee",
    last_seen_at: 2.days.ago,
    status: "hot",
    title: "Procurement Lead"
  ),
  ivy: Contact.create!(
    company: companies[:helix],
    email: "ivy@helix.example",
    first_name: "Ivy",
    last_name: "Walker",
    last_seen_at: 3.days.ago,
    status: "hot",
    title: "RevOps Director"
  ),
  noah: Contact.create!(
    company: companies[:helix],
    email: "noah@helix.example",
    first_name: "Noah",
    last_name: "Kim",
    last_seen_at: 4.days.ago,
    status: "warm",
    title: "Transformation Lead"
  ),
  lena: Contact.create!(
    company: companies[:sunset],
    email: "lena@sunset.example",
    first_name: "Lena",
    last_name: "Park",
    last_seen_at: 5.days.ago,
    status: "hot",
    title: "Founder"
  )
}

deals = {
  northwind: Deal.create!(
    amount: 18_000,
    company: companies[:northwind],
    contact: contacts[:maya],
    last_seen_at: 1.day.ago,
    name: "Northwind expansion",
    stage: "lead"
  ),
  blue_ocean: Deal.create!(
    amount: 9_000,
    company: companies[:blue_ocean],
    contact: contacts[:jordan],
    last_seen_at: 2.days.ago,
    name: "Blue Ocean renewal",
    stage: "lead"
  ),
  acme: Deal.create!(
    amount: 42_000,
    company: companies[:helix],
    contact: contacts[:ivy],
    last_seen_at: 3.days.ago,
    name: "Acme platform rollout",
    stage: "qualified"
  ),
  helix: Deal.create!(
    amount: 67_000,
    company: companies[:helix],
    contact: contacts[:noah],
    last_seen_at: 1.day.ago,
    name: "Helix migration",
    stage: "proposal"
  ),
  sunset: Deal.create!(
    amount: 24_000,
    company: companies[:sunset],
    contact: contacts[:lena],
    last_seen_at: 6.days.ago,
    name: "Sunset Analytics",
    stage: "won"
  )
}

Task.create!(
  contact: contacts[:maya],
  due_on: Date.current + 1.day,
  priority: "high",
  status: "open",
  title: "Review Northwind discovery notes"
)
Task.create!(
  contact: contacts[:jordan],
  due_on: Date.current + 2.days,
  priority: "medium",
  status: "open",
  title: "Prepare Blue Ocean renewal deck"
)
Task.create!(
  contact: contacts[:ivy],
  due_on: Date.current + 3.days,
  priority: "high",
  status: "open",
  title: "Confirm rollout timeline with Acme stakeholders"
)
Task.create!(
  contact: contacts[:noah],
  due_on: Date.current + 4.days,
  priority: "low",
  status: "open",
  title: "Draft Helix migration commercial proposal"
)
Task.create!(
  contact: contacts[:lena],
  due_on: Date.current + 5.days,
  priority: "medium",
  status: "open",
  title: "Schedule Sunset customer success handoff"
)

Note.create!(
  body: "Northwind asked for a multi-region rollout option and wants pricing by Friday.",
  contact: contacts[:maya],
  created_at: 1.day.ago
)
Note.create!(
  body: "Jordan confirmed procurement is aligned if the renewal keeps the implementation team included.",
  contact: contacts[:jordan],
  created_at: 2.days.ago
)
Note.create!(
  body: "Acme approved the updated scope and wants a revised onboarding sequence.",
  deal: deals[:acme],
  created_at: 3.days.ago
)
Note.create!(
  body: "Helix is asking for a services add-on before moving into legal review.",
  deal: deals[:helix],
  created_at: 4.days.ago
)
Note.create!(
  body: "Lena introduced the customer success lead who will own the Sunset rollout.",
  contact: contacts[:lena],
  created_at: 5.days.ago
)
