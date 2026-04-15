import React from 'react';

type Metric = {
  label: string;
  value: string;
};

type Props = {
  appName: string;
  thesis: string;
  metrics: Metric[];
  nextSteps: string[];
};

export default function AtomicCrmHomePage({
  appName,
  thesis,
  metrics,
  nextSteps,
}: Props) {
  return (
    <main className="crm-shell">
      <section className="crm-hero">
        <div>
          <p className="crm-shell__eyebrow">React on Rails Pro migration in progress</p>
          <h1>{appName} is the next product-shaped demo in the portfolio.</h1>
          <p>{thesis}</p>
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
            <p className="crm-shell__eyebrow">Migration thesis</p>
            <h2>Server-render the dashboard shell, reserve the browser for the surfaces that truly need it.</h2>
          </div>
        </div>

        <div className="crm-next-steps">
          {nextSteps.map((step) => (
            <article className="crm-card" key={step}>
              <h3>{step}</h3>
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}
