import React from 'react';
import AtomicCrmAppChrome from '../components/AtomicCrmAppChrome';

type Metric = {
  detail: string;
  label: string;
  value: string;
};

type CompanyCard = {
  city: string | null;
  contactCount: number;
  dealCount: number;
  name: string;
  openPipeline: string;
  path: string;
  sector: string | null;
  size: string | null;
  website: string | null;
  wonRevenue: string;
};

type Props = {
  companies: CompanyCard[];
  metrics: Metric[];
  thesis: string;
};

export default function AtomicCrmCompaniesPage({ companies, metrics, thesis }: Props) {
  return (
    <AtomicCrmAppChrome activePage="companies">
      <main className="crm-shell crm-page">
        <section className="crm-page__intro">
          <div>
            <p className="crm-shell__eyebrow">Streamed company directory</p>
            <h1>Account pages can stay server-rendered while still exposing pipeline and relationship context.</h1>
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

        <section className="crm-company-grid">
          {companies.map((company) => (
            <article className="crm-card crm-company-card" key={company.name}>
              <div className="crm-company-card__header">
                <div>
                  <p className="crm-shell__eyebrow">Account</p>
                  <h2>
                    <a className="crm-text-link" href={company.path}>
                      {company.name}
                    </a>
                  </h2>
                </div>
                <span className="crm-pill crm-pill--deal">{company.size || 'Unspecified size'}</span>
              </div>

              <p>
                {company.sector || 'General'} · {company.city || 'City pending'}
              </p>

              <div className="crm-company-card__stats">
                <div>
                  <span>Open pipeline</span>
                  <strong>{company.openPipeline}</strong>
                </div>
                <div>
                  <span>Won revenue</span>
                  <strong>{company.wonRevenue}</strong>
                </div>
                <div>
                  <span>Contacts</span>
                  <strong>{company.contactCount}</strong>
                </div>
                <div>
                  <span>Deals</span>
                  <strong>{company.dealCount}</strong>
                </div>
              </div>

              {company.website ? (
                <a className="crm-text-link" href={company.website} rel="noreferrer" target="_blank">
                  {company.website.replace(/^https?:\/\//, '')}
                </a>
              ) : (
                <span className="crm-company-card__placeholder">Website pending</span>
              )}
            </article>
          ))}
        </section>
      </main>
    </AtomicCrmAppChrome>
  );
}
