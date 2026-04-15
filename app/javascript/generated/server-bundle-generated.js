import ReactOnRails from 'react-on-rails-pro';

import AtomicCrmContactShowPage from '../src/atomic_crm/ror_components/AtomicCrmContactShowPage.tsx';
import AtomicCrmContactsPage from '../src/atomic_crm/ror_components/AtomicCrmContactsPage.tsx';
import AtomicCrmDealBoardIsland from '../src/atomic_crm/ror_components/AtomicCrmDealBoardIsland.tsx';
import AtomicCrmHomePage from '../src/atomic_crm/ror_components/AtomicCrmHomePage.tsx';

import registerServerComponent from 'react-on-rails-pro/registerServerComponent/server';
registerServerComponent({AtomicCrmContactShowPage,
AtomicCrmContactsPage,
AtomicCrmHomePage});

ReactOnRails.register({AtomicCrmDealBoardIsland});