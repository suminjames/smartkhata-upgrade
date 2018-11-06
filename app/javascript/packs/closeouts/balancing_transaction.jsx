import React from 'react';
class BalancingTransaction extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      transaction: this.props.transaction,
    }
  }


  render() {
    const transaction = this.state.transaction;
    return (
      <tr>
        <td><input
          name='transaction_id'
          type='checkbox'
          onClick={(e)=>this.props.handleChange(e, transaction.id)}
          label='Add'/>
        </td>
        <td className="text-center">{transaction.date}</td>
        <td className="text-center">{transaction.contract_no}</td>
        <td className="text-center">{transaction.transaction_type=='selling' ? transaction.buyer: transaction.seller}</td>
        <td className="quantity-in text-right">{ transaction.raw_quantity }</td>
        <td className="text-right">{transaction.share_rate}</td>
        <td className="text-right">{transaction.share_amount}</td>
      </tr>
    );
  }
};
export default BalancingTransaction;