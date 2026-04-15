import React from 'react';
import AtomicCrmAppChrome from '../components/AtomicCrmAppChrome';

type Contact = {
  fullName: string;
  id: number;
  lastSeenLabel: string;
  path: string;
  statusLabel: string;
  statusTone: string;
  title: string | null;
};

type Metric = {
  detail: string;
  label: string;
  value: string;
};

type RecentNote = {
  body: string;
  createdAtLabel: string;
  id: number;
  subjectLabel: string;
  subjectType: string;
};

type RelatedDeal = {
  amount: string;
  contactName: string;
  id: number;
  lastSeenLabel: string;
  name: string;
  stageLabel: string;
};

type Props = {
  city: string | null;
  contacts: Contact[];
  metrics: Metric[];
  name: string;
  recentNotes: RecentNote[];
  relatedDeals: RelatedDeal[];
  sector: string | null;
  size: string | null;
  thesis: string;
  website: string | null;
};

export default function AtomicCrmCompanyShowPage({
  city,
  contacts,
  metrics,
  name,
  recentNotes,
  relatedDeals,
  sector,
  size,
  thesis,
  website,
}: Props) {
  return (
    <AtomicCrmAppChrome activePage="companies">
      <main className="crm-shell crm-page">
        <a className="crm-text-link crm-page__back" href="/companies">
          Back to companies
        </a>

        <section className="crm-card crm-contact-hero">
          <div className="crm-contact-hero__heading">
            <div>
              <p className="crm-shell__eyebrow">Streamed company detail</p>
              <h1>{name}</h1>
              <p>
                {sector || 'General'} · {city || 'City pending'}
              </p>
            </div>
            <span className="crm-pill crm-pill--deal">{size || 'Unspecified size'}</span>
          </div>

          <div className="crm-contact-hero__meta">
            {website ? (
              <a className="crm-text-link" href={website} rel="noreferrer" target="_blank">
                {website.replace(/^https?:\/\//, '')}
              </a>
            ) : (
              <span>Website pending</span>
            )}
          </div>

          <p>{thesis}</p>
        </section>

        <section className="crm-stat-grid">
          {metrics.map((metric) => (
            <article className="crm-card crm-stat-card" key={metric.label}>
              <span>{metric.label}</span>
              <h3>{metric.value}</h3>
              <p>{metric.detail}</p>
            </article>
          ))}
        </section>

        <section className="crm-detail-grid">
          <article className="crm-card crm-panel">
            <div className="crm-panel__header">
              <div>
                <p className="crm-shell__eyebrow">Contacts</p>
                <h2>Linked people</h2>
              </div>
            </div>

            <div className="crm-list">
              {contacts.map((contact) => (
                <div className="crm-list__item" key={contact.id}>
                  <div>
                    <strong>
                      <a className="crm-text-link" href={contact.path}>
                        {contact.fullName}
                      </a>
                    </strong>
                    <p>{contact.title || 'Title pending'}</p>
                  </div>
                  <div className="crm-deal-summary">
                    <span>Seen {contact.lastSeenLabel}</span>
                    <span className={`crm-pill crm-pill--${contact.statusTone}`}>{contact.statusLabel}</span>
                  </div>
                </div>
              ))}
            </div>
          </article>

          <article className="crm-card crm-panel">
            <div className="crm-panel__header">
              <div>
                <p className="crm-shell__eyebrow">Deals</p>
                <h2>Pipeline</h2>
              </div>
            </div>

            <div className="crm-list">
              {relatedDeals.map((deal) => (
                <div className="crm-list__item" key={deal.id}>
                  <div>
                    <strong>{deal.name}</strong>
                    <p>
                      {deal.contactName} · Seen {deal.lastSeenLabel}
                    </p>
                  </div>
                  <div className="crm-deal-summary">
                    <span>{deal.amount}</span>
                    <span className="crm-pill crm-pill--deal">{deal.stageLabel}</span>
                  </div>
                </div>
              ))}
            </div>
          </article>

          <article className="crm-card crm-panel crm-panel--wide">
            <div className="crm-panel__header">
              <div>
                <p className="crm-shell__eyebrow">Notes</p>
                <h2>Account timeline</h2>
              </div>
            </div>

            <div className="crm-notes">
              {recentNotes.map((note) => (
                <div className="crm-note" key={note.id}>
                  <div className="crm-note__meta">
                    <strong>{note.subjectType}</strong>
                    <span>
                      {note.subjectLabel} · {note.createdAtLabel}
                    </span>
                  </div>
                  <p>{note.body}</p>
                </div>
              ))}
            </div>
          </article>
        </section>
      </main>
    </AtomicCrmAppChrome>
  );
}
