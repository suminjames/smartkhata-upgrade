class TrialBalance extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      ledger_groups: this.props.ledger_groups,
    }
  }
  render() {
    var self = this;
    let total_opening_balance_dr = 0, total_opening_balance_cr = 0, total_dr_amount = 0, total_cr_amount = 0, total_closing_balance_dr = 0, total_closing_balance_cr = 0;
    return (
      <table className="table">
        <thead><tr>
          <th>Name</th>
          <th>Opening <br/> Balance Dr</th>
          <th>Opening <br/> Balance Cr</th>
          <th>Net Debit</th>
          <th>Net Credit</th>
          <th>Closing <br/> Balance Dr</th>
          <th>Closing <br/> Balance Cr</th>
        </tr></thead>
          {
            Object.keys(this.state.ledger_groups).map(function (key, index) {
              var ledgers = self.state.ledger_groups[key];

              let opening_balance_dr = 0, opening_balance_cr = 0, dr_amount = 0, cr_amount = 0, closing_balance_dr = 0, closing_balance_cr = 0;

              return(
                <tbody className="ledger-group" key={index}>
                  <tr>
                    <td colSpan="7"><h4><strong>{key}</strong></h4></td>
                  </tr>
                  {
                    ledgers.map(function(ledger, index_inner){

                      opening_balance_dr += ((ledger.opening_balance > 1) ? positive_currency_raw(ledger.opening_balance) : 0.00);
                      opening_balance_cr += ((ledger.opening_balance < 0) ? positive_currency_raw(ledger.opening_balance) : 0);
                      dr_amount += positive_currency_raw(ledger.dr_amount);
                      cr_amount += positive_currency_raw(ledger.cr_amount);
                      closing_balance_dr += ((ledger.closing_balance > 1) ? positive_currency_raw(ledger.closing_balance) : 0);
                      closing_balance_cr += ((ledger.closing_balance < 0) ? positive_currency_raw(ledger.closing_balance) : 0);

                      total_opening_balance_dr += ((ledger.opening_balance > 1) ? positive_currency_raw(ledger.opening_balance) : 0);
                      total_opening_balance_cr += ((ledger.opening_balance < 0) ? positive_currency_raw(ledger.opening_balance) : 0);
                      total_dr_amount += positive_currency_raw(ledger.dr_amount);
                      total_cr_amount += positive_currency_raw(ledger.cr_amount);
                      total_closing_balance_dr += ((ledger.closing_balance > 1) ? positive_currency_raw(ledger.closing_balance) : 0);
                      total_closing_balance_cr += ((ledger.closing_balance < 0) ? positive_currency_raw(ledger.closing_balance) : 0);


                      return(
                        <tr className="ledger-single" key={index_inner}>
                          <td>{ ledger.name }</td>
                          <td className="text-right">{ ledger.opening_balance > 1 ? number_to_currency(ledger.opening_balance) : '0.00' }</td>
                          <td className="text-right">{ ledger.opening_balance < 0 ? number_to_currency(ledger.opening_balance) : '0.00' }</td>
                          <td className="text-right">{ number_to_currency(ledger.dr_amount) }</td>
                          <td className="text-right">{ number_to_currency(ledger.cr_amount) }</td>
                          <td className="text-right">{ ledger.closing_balance > 1 ? number_to_currency(ledger.closing_balance) : '0.00' }</td>
                          <td className="text-right">{ ledger.closing_balance < 0 ? number_to_currency(ledger.closing_balance) : '0.00' }</td>
                        </tr>
                      )
                    })
                  }

                  {
                    (
                    <tr className="total-trial" key={"total"+ index}>
                      <td>Total</td>
                      <td className="text-right">{number_to_currency(opening_balance_dr)}</td>
                      <td className="text-right">{number_to_currency(opening_balance_dr)}</td>
                      <td className="text-right">{number_to_currency(dr_amount)}</td>
                      <td className="text-right">{number_to_currency(cr_amount)}</td>
                      <td className="text-right">{number_to_currency(closing_balance_dr)}</td>
                      <td className="text-right">{number_to_currency(closing_balance_cr)}</td>
                    </tr>
                  )
                  }
                </tbody>
              )
            })
          }
          <tbody>
            <tr className="end">
              <td>Grand Total</td>
              <td className="text-right">{number_to_currency(total_opening_balance_dr)}</td>
              <td className="text-right">{number_to_currency(total_opening_balance_dr)}</td>
              <td className="text-right">{number_to_currency(total_dr_amount)}</td>
              <td className="text-right">{number_to_currency(total_cr_amount)}</td>
              <td className="text-right">{number_to_currency(total_closing_balance_dr)}</td>
              <td className="text-right">{number_to_currency(total_closing_balance_cr)}</td>
            </tr>
          </tbody>
      </table>
    );
  }
};
