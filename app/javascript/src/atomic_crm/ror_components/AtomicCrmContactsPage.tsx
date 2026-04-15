import React from 'react';
import AtomicCrmAppChrome from '../components/AtomicCrmAppChrome';

type Metric = {
  detail: string;
  label: string;
  value: string;
};

type ContactRow = {
  city: string | null;
  companyName: string;
  dealSummary: string;
  email: string | null;
  fullName: string;
  id: number;
  lastSeenLabel: string;
  path: string;
  statusLabel: string;
  statusTone: string;
  taskSummary: string;
  title: string | null;
};

type CompanyRollup = {
  city: string | null;
  contactCount: number;
  name: string;
  openPipeline: string;
  sector: string | null;
};

type Props = {
  companyRollup: CompanyRollup[];
  contacts: ContactRow[];
  metrics: Metric[];
  thesis: string;
};

export default function AtomicCrmContactsPage({ companyRollup, contacts, metrics, thesis }: Props) {
  return (
    <AtomicCrmAppChrome activePage="contacts">
      <main className="crm-shell crm-page">
        <section className="crm-page__intro">
          <div>
            <p className="crm-shell__eyebrow">Streamed contacts directory</p>
            <h1>Read-heavy CRM routes can stay server-first without losing product shape.</h1>
            <p>{thesis}</p>
          </div>
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

        <section className="crm-directory-layout">
          <article className="crm-card crm-panel">
            <div className="crm-panel__header">
              <div>
                <p className="crm-shell__eyebrow">Contacts</p>
                <h2>Directory</h2>
              </div>
              <p>Each record links to its own streamed detail page with no new client runtime.</p>
            </div>

            <div className="crm-directory">
              {contacts.map((contact) => (
                <a className="crm-directory__row" href={contact.path} key={contact.id}>
                  <div className="crm-directory__identity">
                    <div>
                      <strong>{contact.fullName}</strong>
                      <p>{contact.title ? `${contact.title} at ${contact.companyName}` : contact.companyName}</p>
                    </div>
                    <span className={`crm-pill crm-pill--${contact.statusTone}`}>{contact.statusLabel}</span>
                  </div>

                  <div className="crm-directory__detail">
                    <span>{contact.email || 'No email yet'}</span>
                    <span>{contact.city || 'City pending'}</span>
                    <span>{contact.taskSummary}</span>
                    <span>{contact.dealSummary}</span>
                  </div>

                  <div className="crm-directory__meta">Seen {contact.lastSeenLabel}</div>
                </a>
              ))}
            </div>
          </article>

          <div className="crm-page__aside">
            <article className="crm-card crm-panel">
              <div className="crm-panel__header">
                <div>
                  <p className="crm-shell__eyebrow">Accounts</p>
                  <h2>Company rollup</h2>
                </div>
              </div>

              <div className="crm-company-rollup">
                {companyRollup.map((company) => (
                  <div className="crm-company-rollup__item" key={company.name}>
                    <div>
                      <strong>{company.name}</strong>
                      <p>
                        {company.sector || 'General'} · {company.city || 'City pending'}
                      </p>
                    </div>
                    <div className="crm-company-rollup__stats">
                      <span>{company.contactCount} contacts</span>
                      <span>{company.openPipeline}</span>
                    </div>
                  </div>
                ))}
              </div>
            </article>

            <article className="crm-card crm-panel">
              <div className="crm-panel__header">
                <div>
                  <p className="crm-shell__eyebrow">Why it matters</p>
                  <h2>Useful demo surface</h2>
                </div>
              </div>

              <div className="crm-notes">
                <div className="crm-note">
                  <p>The source SPA treats directory and detail views as client-heavy routes. This migration shows the same product area as streamed RSC pages.</p>
                </div>
                <div className="crm-note">
                  <p>It is a better React on Rails Pro demo than a brochure page because the route has sorting, relationships, and repeated record rendering that clearly benefit from server ownership.</p>
                </div>
              </div>
            </article>
          </div>
        </section>
      </main>
    </AtomicCrmAppChrome>
  );
}
