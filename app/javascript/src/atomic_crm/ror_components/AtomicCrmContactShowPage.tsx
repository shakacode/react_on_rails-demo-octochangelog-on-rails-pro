import React from 'react';
import AtomicCrmAppChrome from '../components/AtomicCrmAppChrome';

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
  id: number;
  lastSeenLabel: string;
  name: string;
  stageLabel: string;
};

type UpcomingTask = {
  dueLabel: string;
  id: number;
  priorityLabel: string;
  priorityTone: string;
  title: string;
};

type Props = {
  companyCity: string | null;
  companyName: string;
  companyWebsite: string | null;
  email: string | null;
  fullName: string;
  lastSeenLabel: string;
  metrics: Metric[];
  recentNotes: RecentNote[];
  relatedDeals: RelatedDeal[];
  statusLabel: string;
  statusTone: string;
  thesis: string;
  title: string | null;
  upcomingTasks: UpcomingTask[];
};

export default function AtomicCrmContactShowPage({
  companyCity,
  companyName,
  companyWebsite,
  email,
  fullName,
  lastSeenLabel,
  metrics,
  recentNotes,
  relatedDeals,
  statusLabel,
  statusTone,
  thesis,
  title,
  upcomingTasks,
}: Props) {
  return (
    <AtomicCrmAppChrome activePage="contacts">
      <main className="crm-shell crm-page">
        <a className="crm-text-link crm-page__back" href="/contacts">
          Back to contacts
        </a>

        <section className="crm-card crm-contact-hero">
          <div className="crm-contact-hero__heading">
            <div>
              <p className="crm-shell__eyebrow">Streamed contact detail</p>
              <h1>{fullName}</h1>
              <p>{title ? `${title} at ${companyName}` : companyName}</p>
            </div>
            <span className={`crm-pill crm-pill--${statusTone}`}>{statusLabel}</span>
          </div>

          <div className="crm-contact-hero__meta">
            {email ? (
              <a className="crm-text-link" href={`mailto:${email}`}>
                {email}
              </a>
            ) : (
              <span>No email yet</span>
            )}
            <span>{companyCity || 'City pending'}</span>
            {companyWebsite ? (
              <a className="crm-text-link" href={companyWebsite} rel="noreferrer" target="_blank">
                {companyWebsite.replace(/^https?:\/\//, '')}
              </a>
            ) : (
              <span>Website pending</span>
            )}
            <span>Seen {lastSeenLabel}</span>
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
                <p className="crm-shell__eyebrow">Tasks</p>
                <h2>Upcoming work</h2>
              </div>
            </div>

            <div className="crm-list">
              {upcomingTasks.map((task) => (
                <div className="crm-list__item" key={task.id}>
                  <div>
                    <strong>{task.title}</strong>
                    <p>Due {task.dueLabel}</p>
                  </div>
                  <span className={`crm-pill crm-pill--${task.priorityTone}`}>{task.priorityLabel}</span>
                </div>
              ))}
            </div>
          </article>

          <article className="crm-card crm-panel">
            <div className="crm-panel__header">
              <div>
                <p className="crm-shell__eyebrow">Deals</p>
                <h2>Related opportunities</h2>
              </div>
            </div>

            <div className="crm-list">
              {relatedDeals.map((deal) => (
                <div className="crm-list__item" key={deal.id}>
                  <div>
                    <strong>{deal.name}</strong>
                    <p>Seen {deal.lastSeenLabel}</p>
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
                <h2>Relationship timeline</h2>
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
