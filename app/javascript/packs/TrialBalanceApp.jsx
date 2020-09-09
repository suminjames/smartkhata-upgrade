import React from 'react';
import ReactDOM from 'react-dom';
import TrialBalance from '../reports/TrialBalance';

const loadPage = () => {
  const node = document.getElementById('trial_balance');
  const ledger_groups = JSON.parse(node.getAttribute('ledger_groups')) || {};

  ReactDOM.render(
    <TrialBalance ledger_groups={ledger_groups} />,
    node
  );
}

document.addEventListener('DOMContentLoaded', () => {
  loadPage();
});

document.addEventListener('page:load', () => {
  loadPage();
});
