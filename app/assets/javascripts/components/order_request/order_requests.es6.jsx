class OrderRequests extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      orderDetails: this.props.order_request_details
    }
  }
  render() {
    order_requests = this.state.orderDetails.map( function(order_request) {
      return (
        <OrderRequestDetail orderRequest={order_request} key={order_request.id} />
      );
    });

    return (
      <table className="table">
        <thead>
          <tr>
            <th>Client Name</th>
            <th>Client Nepse Code</th>
            <th>Ledger Balance</th>
            <th>Company</th>
            <th>Quantity</th>
            <th>Rate</th>
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
