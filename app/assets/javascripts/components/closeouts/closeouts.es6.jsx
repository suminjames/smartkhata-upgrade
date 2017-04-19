class Closeouts extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      transactions: this.props.share_transactions,
    }
  }
  render() {
    closeouts = this.state.transactions.map( function(transaction) {
      return (
        <Closeout transaction={transaction} key={transaction.id} />
      );
    });
    return (
      <table className="table">
        <thead>
        <tr>
          <th className="text-center">Transaction<br/>Date</th>
          <th className="text-center">Transaction No</th>
          <th className="col-sm-2 text-center">Company</th>
          <th className="text-center">Client</th>
          <th className="text-center">Broker</th>
          <th className="text-center">Qty<br/>In</th>
          <th className="text-center">Qty<br/>Out</th>
          <th className="text-center">Closeout Quantity</th>
          <th className="text-center">Rate</th>
          <th className="text-center">Closeout Amount</th>
        </tr>
        </thead>
        <tbody>
        {closeouts}
        </tbody>
      </table>
    );
  }
};