'use client';

import { useState } from 'react';

type Deal = {
  id: number;
  name: string;
  owner: string;
  amount: string;
};

type Stage = {
  id: string;
  name: string;
  deals: Deal[];
};

type Props = {
  stages: Stage[];
};

export default function AtomicCrmDealBoardIsland({ stages }: Props) {
  const [board, setBoard] = useState(stages);

  const moveForward = (stageIndex: number, dealId: number) => {
    if (stageIndex >= board.length - 1) return;

    const nextBoard = board.map((stage) => ({
      ...stage,
      deals: [...stage.deals],
    }));
    const currentStage = nextBoard[stageIndex];
    const nextStage = nextBoard[stageIndex + 1];

    if (!currentStage || !nextStage) return;

    const dealIndex = currentStage.deals.findIndex((deal) => deal.id === dealId);
    if (dealIndex < 0) return;

    const [deal] = currentStage.deals.splice(dealIndex, 1);
    if (!deal) return;

    nextStage.deals.push(deal);
    setBoard(nextBoard);
  };

  return (
    <div className="crm-board">
      {board.map((stage, stageIndex) => (
        <section className="crm-board__column" key={stage.id}>
          <div className="crm-board__column-header">
            <h3>{stage.name}</h3>
            <span className="crm-board__count">{stage.deals.length}</span>
          </div>

          {stage.deals.map((deal) => (
            <article className="crm-deal-card" key={deal.id}>
              <strong>{deal.name}</strong>
              <div className="crm-deal-card__meta">
                <span>{deal.owner}</span>
                <span>{deal.amount}</span>
              </div>
              <button
                type="button"
                disabled={stageIndex === board.length - 1}
                onClick={() => moveForward(stageIndex, deal.id)}
              >
                {stageIndex === board.length - 1 ? 'Closed' : 'Move Forward'}
              </button>
            </article>
          ))}
        </section>
      ))}
    </div>
  );
}
