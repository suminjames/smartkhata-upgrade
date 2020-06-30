import React from 'react';
import ReactDOM from 'react-dom';
import EdisReport from '../edis_reports/EdisReport';


function mountComponent() {
  const node = document.getElementById('root');
  const edisReport = JSON.parse(node.getAttribute('edis_report')) || {};
  const itemsPath = node.getAttribute('items_path') || '';

  ReactDOM.render( <EdisReport edis_report={edisReport} items_path={itemsPath}/>, node);
}

function unmountComponentAtNode() {
  const node = document.getElementById('root');
  ReactDOM.unmountComponentAtNode(node)
}

// document.addEventListener('DOMContentLoaded', mountComponent);


mountComponent();
document.addEventListener('turbolinks:before-cache', function () {
  unmountComponentAtNode()
})
