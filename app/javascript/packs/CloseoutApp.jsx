import React from 'react';
import ReactDOM from 'react-dom';
import Closeouts from '../closeouts/Closeouts';


const mountComponent = () => {
  const node = document.getElementById('closeout-transactions');
  const array = JSON.parse(node.getAttribute('share_transactions')) || [];
  const share_transactions = array.map(x => JSON.parse(x));
  ReactDOM.render(
    <Closeouts share_transactions={share_transactions} />,
    node
  );
}

function unmountComponentAtNode() {
  const node = document.getElementById('closeout-transactions');
  ReactDOM.unmountComponentAtNode(node)
}

// document.addEventListener('DOMContentLoaded', () => {
//   mountComponent();
// });
//
// document.addEventListener('page:load', () => {
//   mountComponent();
// });

mountComponent();
document.addEventListener('turbolinks:before-cache', function () {
  unmountComponentAtNode()
})
