import ReactOnRails from 'react-on-rails-pro';

import AtomicCrmDealBoardIsland from '../src/atomic_crm/ror_components/AtomicCrmDealBoardIsland.tsx';
import AtomicCrmHomePage from '../src/atomic_crm/ror_components/AtomicCrmHomePage.tsx';

import registerServerComponent from 'react-on-rails-pro/registerServerComponent/server';
registerServerComponent({AtomicCrmHomePage});

ReactOnRails.register({AtomicCrmDealBoardIsland});