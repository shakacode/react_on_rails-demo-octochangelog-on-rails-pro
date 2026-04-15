import React from 'react';
import AtomicCrmAppChrome from '../components/AtomicCrmAppChrome';

type Metric = {
  label: string;
  value: string;
};

type HotContact = {
  id: number;
  companyName: string;
  fullName: string;
  lastSeenLabel: string;
  title: string | null;
};

type PipelineStageSummary = {
  id: string;
  name: string;
  dealCount: number;
  totalAmount: string;
};

type RecentNote = {
  id: number;
  body: string;
  createdAtLabel: string;
  subjectLabel: string;
  subjectType: string;
};

type UpcomingTask = {
  id: number;
  contactName: string;
  dueLabel: string;
  priority: string;
  title: string;
};

type Props = {
  appName: string;
  hotContacts: HotContact[];
  metrics: Metric[];
  pipelineSummary: PipelineStageSummary[];
  recentNotes: RecentNote[];
  thesis: string;
  upcomingTasks: UpcomingTask[];
};

export default function AtomicCrmHomePage({
  appName,
  hotContacts,
  thesis,
  metrics,
  pipelineSummary,
  recentNotes,
  upcomingTasks,
}: Props) {
  return (
    <AtomicCrmAppChrome activePage="dashboard">
      <main className="crm-shell">
        <section className="crm-hero">
          <div>
            <p className="crm-shell__eyebrow">Seeded Rails dashboard with streamed RSC sections</p>
            <h1>{appName} keeps the product shell on the server and the workflow island in the browser.</h1>
            <p>{thesis}</p>

            <div className="crm-hero__actions">
              <a className="crm-button-link" href="/contacts">
                Open streamed contacts directory
              </a>
              <a className="crm-button-link crm-button-link--muted" href="#pipeline-board">
                Jump to client island
              </a>
            </div>
          </div>

          <div className="crm-metrics">
            {metrics.map((metric) => (
              <article className="crm-card" key={metric.label}>
                <span>{metric.label}</span>
                <h3>{metric.value}</h3>
              </article>
            ))}
          </div>
        </section>

        <section className="crm-shell">
          <div className="crm-shell__section-header">
            <div>
              <p className="crm-shell__eyebrow">Dashboard snapshot</p>
              <h2>Hot contacts, pipeline summary, notes, and tasks now come from Rails-backed seeded records.</h2>
            </div>
          </div>

          <div className="crm-stage-summary">
            {pipelineSummary.map((stage) => (
              <article className="crm-card crm-card--summary" key={stage.id}>
                <span>{stage.name}</span>
                <h3>{stage.totalAmount}</h3>
                <p>{stage.dealCount} deals in stage</p>
              </article>
            ))}
          </div>

          <div className="crm-dashboard-grid">
            <article className="crm-card crm-panel">
              <div className="crm-panel__header">
                <div>
                  <p className="crm-shell__eyebrow">Contacts</p>
                  <h3>Hot contacts</h3>
                </div>
              </div>

              <div className="crm-list">
                {hotContacts.map((contact) => (
                  <div className="crm-list__item" key={contact.id}>
                    <div>
                      <strong>
                        <a className="crm-text-link" href={`/contacts/${contact.id}`}>
                          {contact.fullName}
                        </a>
                      </strong>
                      <p>{contact.title ? `${contact.title} at ${contact.companyName}` : contact.companyName}</p>
                    </div>
                    <span>{contact.lastSeenLabel}</span>
                  </div>
                ))}
              </div>
            </article>

            <article className="crm-card crm-panel">
              <div className="crm-panel__header">
                <div>
                  <p className="crm-shell__eyebrow">Tasks</p>
                  <h3>Upcoming work</h3>
                </div>
              </div>

              <div className="crm-list">
                {upcomingTasks.map((task) => (
                  <div className="crm-list__item" key={task.id}>
                    <div>
                      <strong>{task.title}</strong>
                      <p>{task.contactName}</p>
                    </div>
                    <span>
                      {task.priority} · {task.dueLabel}
                    </span>
                  </div>
                ))}
              </div>
            </article>

            <article className="crm-card crm-panel">
              <div className="crm-panel__header">
                <div>
                  <p className="crm-shell__eyebrow">Notes</p>
                  <h3>Latest updates</h3>
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
          </div>
        </section>
      </main>
    </AtomicCrmAppChrome>
  );
}
