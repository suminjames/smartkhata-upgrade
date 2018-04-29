import React from 'react';
import ReactDOM from 'react-dom';
import OrderRequestDetail from './order_request_detail';

class OrderRequests extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      orderDetails: this.props.order_request_details
      // orderDetails: []
    }
  }
  render() {
    const order_requests = this.state.orderDetails.map( function(order_request) {
      return (
        <OrderRequestDetail orderRequest={order_request} key={order_request.id} />
      );
    });

    return (
      <table className="table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Nepse Code</th>
            <th>Balance</th>
            <th>Company</th>
            <th>Quantity</th>
            <th>Rate</th>
            <th>Order Type</th>
            <th>Status</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {order_requests}
        </tbody>
      </table>
    );
  }
};

export default OrderRequests;

document.addEventListener('turbolinks:load', () => {
  const node = document.getElementById('order_requests_data')
  const data = JSON.parse(node.getAttribute('data'))
  ReactDOM.render(
    <OrderRequests order_request_details={data} />,
    node,
  );

  console.log(node)
})
