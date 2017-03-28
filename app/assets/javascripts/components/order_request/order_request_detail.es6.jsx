class OrderRequestDetail extends React.Component {
  render () {
    return (
      <div>
        <div>Company: {this.props.company}</div>
        <div>Date: {this.props.date}</div>
        <div>Rate: {this.props.rate}</div>
        <div>Quantity: {this.props.quantity}</div>
        <div>Status: {this.props.status}</div>
      </div>
    );
  }
}

OrderRequestDetail.propTypes = {
  company: React.PropTypes.string,
  date: React.PropTypes.node,
  rate: React.PropTypes.node,
  quantity: React.PropTypes.node,
  status: React.PropTypes.string
};
