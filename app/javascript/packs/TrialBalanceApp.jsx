import React from 'react';
import ReactDOM from 'react-dom';
import TrialBalance from '../reports/TrialBalance';

document.addEventListener('DOMContentLoaded', () => {
  const node = document.getElementById('trial_balance');
  const ledger_groups = JSON.parse(node.getAttribute('ledger_groups')) || {};

  ReactDOM.render(
    <TrialBalance ledger_groups={ledger_groups} />,
    node
  );
});
