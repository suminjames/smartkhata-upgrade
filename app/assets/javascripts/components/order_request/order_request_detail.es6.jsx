var OrderRequestDetail =  React.createClass({
  getInitialState() {
    return {
      orderRequest: this.props.orderRequest,
      hidden: false
    }
  },
  approve(){
    this.setState({hidden: true})
    var that = this;
    $.ajax({
      method: 'GET',
      url: '/order_request_details/'+that.state.orderRequest.id+'/approve.json',
      success: function(res) {
        that.setState({hidden: true});
      }
    });
  },
  reject(){
    this.setState({hidden: true})
    var that = this;
    $.ajax({
      method: 'GET',
      url: '/order_request_details/'+that.state.orderRequest.id+'/reject.json',
      success: function(res) {
        that.setState({hidden: true});
      }
    });
  },
  render () {
    return (
      <tr className={this.state.hidden ? "hidden": ""}>
        <td>{this.state.orderRequest.client_name}</td>
        <td>{this.state.orderRequest.nepse_code}</td>
        <td>{this.state.orderRequest.closing_balance}</td>
        <td>{this.state.orderRequest.company}</td>
        <td>{this.state.orderRequest.quantity}</td>
        <td>{this.state.orderRequest.rate}</td>
        <td>{this.state.orderRequest.order_type}</td>
        <td>{this.state.orderRequest.status}</td>
        <td>
          <a className="btn" onClick={this.approve}>Approve</a>
          <a className="btn" onClick={this.reject}>Reject</a>
        </td>
      </tr>
    );
  }
})


