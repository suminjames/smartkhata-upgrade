var Button = ReactBootstrap.Button
class Closeout extends React.Component {
  constructor(props) {
    debugger
    super(props);
    this.state = {
      transaction: this.props.transaction,
    }
  }
  render() {
    const transaction = this.state.transaction;
    return (
      <tr>
        <td className="text-center">{transaction.date}</td>
        <td className="text-center">{transaction.contract_no}</td>
        <td className="text-center">{transaction.isin_info.isin} <br/>{transaction.isin_info.company} </td>
        <td className="text-center">{transaction.client_account.name_and_nepse_code}</td>
        <td className="text-center">25</td>
        <td className="quantity-in text-right"></td>
        <td className="quantity-out text-right">185</td>
        <td className="text-right">20</td>
        <td className="text-right">626.0</td>
        <td className="text-right">15,024</td>
        <td>{ transaction.closeout_settled ? '': (<Button>Process</Button>)}
        </td>
      </tr>
    );
  }
};