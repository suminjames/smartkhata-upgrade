import React from 'react';
import { Button } from 'react-bootstrap';

class Closeout extends React.Component {
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
        <td className="text-center">{transaction.date} <br/> {transaction.date_bs}</td>
        <td className="text-center">{transaction.contract_no}</td>
        <td className="text-center">{transaction.isin_info.isin} <br/>{transaction.isin_info.company} </td>
        <td className="text-center">{transaction.client_account.name_and_nepse_code}</td>
        <td className="text-center">{transaction.transaction_type=='selling' ? transaction.buyer: transaction.seller}</td>
        <td className="quantity-in text-right">{transaction.transaction_type=='buying' ? transaction.raw_quantity : '' }</td>
        <td className="quantity-out text-right">{transaction.transaction_type=='selling' ? transaction.raw_quantity : ''}</td>
        <td className="text-right">{transaction.raw_quantity - transaction.quantity}</td>
        <td className="text-right">{transaction.share_rate}</td>
        <td className="text-right">{transaction.closeout_amount}</td>
        <td>{ transaction.closeout_settled ? '': (<Button onClick={() => this.props.process(transaction)} >Process</Button>)}
        </td>
      </tr>
    );
  }
};
export default Closeout;