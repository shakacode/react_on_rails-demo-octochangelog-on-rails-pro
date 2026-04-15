import React from "react";

import CompareResults from "./CompareResults";

import type { ComparisonPayload } from "../lib/types";

type CompareResultsPageProps = {
  authEnabled: boolean;
  authenticated: boolean;
  comparison?: ComparisonPayload | null;
  from?: string | null;
  to?: string | null;
};

export default function CompareResultsPage(props: CompareResultsPageProps) {
  return (
    <CompareResults
      authEnabled={props.authEnabled}
      authenticated={props.authenticated}
      comparison={props.comparison}
      from={props.from}
      to={props.to}
    />
  );
}
