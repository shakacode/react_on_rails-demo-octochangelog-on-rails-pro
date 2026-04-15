import React, { type ReactNode } from 'react';

type ActivePage = 'companies' | 'dashboard' | 'contacts';

type Props = {
  activePage: ActivePage;
  children: ReactNode;
};

const NAV_ITEMS: Array<{ href: string; id: ActivePage; label: string }> = [
  { href: '/', id: 'dashboard', label: 'Dashboard' },
  { href: '/contacts', id: 'contacts', label: 'Contacts' },
  { href: '/companies', id: 'companies', label: 'Companies' },
];

export default function AtomicCrmAppChrome({ activePage, children }: Props) {
  return (
    <div className="crm-app">
      <div className="crm-shell">
        <header className="crm-nav">
          <a className="crm-nav__brand" href="/">
            <span className="crm-nav__mark">RoR Pro</span>
            <div>
              <strong>Atomic CRM</strong>
              <span>Rails-owned product routes with streamed React Server Components</span>
            </div>
          </a>

          <nav className="crm-nav__links" aria-label="Atomic CRM navigation">
            {NAV_ITEMS.map((item) => (
              <a
                aria-current={item.id === activePage ? 'page' : undefined}
                className={`crm-nav__link${item.id === activePage ? ' crm-nav__link--active' : ''}`}
                href={item.href}
                key={item.id}
              >
                {item.label}
              </a>
            ))}
          </nav>

          <div className="crm-nav__meta">
            <span>Server first</span>
            <span>Client islands only where needed</span>
          </div>
        </header>
      </div>

      {children}
    </div>
  );
}
