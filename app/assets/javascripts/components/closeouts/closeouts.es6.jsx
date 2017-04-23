var Button = ReactBootstrap.Button;
var Modal = ReactBootstrap.Modal;
var FormGroup = ReactBootstrap.FormGroup;
var Radio = ReactBootstrap.Radio;

class Closeouts extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      transactions: this.props.share_transactions,
      balancing_transactions: [],
      balancing_transactions_ids: [],
      showModal: false,
      modalContent: 'dummy',
      transaction: null,
      settlement_by: null,
      processed: false,
      message: '',
      error: ''
    }
    this.close = this.close.bind(this);
    this.submit = this.submit.bind(this);
    this.processSettlement = this.processSettlement.bind(this);
    this.prepareSettlement = this.prepareSettlement.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }
  close(){
    this.setState({ showModal: false, transaction: null, error: '', settlement_by: null, balancing_transactions: [], balancing_transactions_ids: [] });
  }
  prepareSettlement(transaction, settlement_type){
    var self = this;
    // disable the settlement by
    self.setState({settlement_by: null});

    if(transaction.transaction_type == 'buying' && settlement_type != 'client') {
      $.get(
        "/share_transactions/"+ self.state.transaction.id+"/available_balancing_transactions.json"
      )
        .done(function(data){
         self.setState({balancing_transactions: data.share_transactions, settlement_by: settlement_type})
        })
        .fail(function(data) {
          self.setState({error: data.responseJSON.error, settlement_by: settlement_type})
        });
    } else {
      self.setState({balancing_transactions: [], settlement_by: settlement_type})
    }
  }

  submit() {
    var self = this;

    if (this.state.transaction.transaction_type == 'buying' ) {
      //make sure the transactions are selected
      if (this.state.balancing_transactions_ids.length < 1) {
        self.setState({error: 'Select atleast one transaction'});
        return false;
      } else {
      //  and the transactions have equal amount as that of the closeout transaction.
        var transactions_qty = this.state.balancing_transactions.map(
          function(e){
            if(this == e.id){return e.quantity}
            },this.state.balancing_transactions_ids
        );
        var total_quantity = transactions_qty.reduce( (prev, curr) => prev + curr );
        if (total_quantity != (self.state.transaction.raw_quantity - self.state.transaction.quantity)) {
          self.setState({error: 'The quantity does not match. Required quantity is: '+ (self.state.transaction.raw_quantity - self.state.transaction.quantity)});
          return false;
        }
      }
    }

    $.post(
        "/share_transactions/"+ self.state.transaction.id+"/process_closeout.json",
        { 'settlement_by': self.state.settlement_by, balancing_transaction_ids: self.state.balancing_transactions_ids }
      )
      .done(function(data){
        var newTransactions = self.state.transactions.map(function (item) {
          if(item.id == self.state.transaction.id) {
            item.closeout_settled = true
          }
          return item;
        });
        self.setState({ transactions: newTransactions, message: data.message, processed: true });
      })
      .fail(function(data) {
       self.setState({error: data.responseJSON.error})
      });
  }

  processSettlement(transaction) {
    this.setState({ showModal: true, processed: false, transaction: transaction });
  }

  handleChange(e, value) {
    if (e.target.checked){
      //append to array
      this.setState({
        balancing_transactions_ids: this.state.balancing_transactions_ids.concat([value])
      })
    } else {
      //remove from array
      this.setState({
        balancing_transactions_ids : this.state.balancing_transactions_ids.filter(function(val) {return val!==value})
      })
    }
  }

  render() {
    var self = this;
    closeouts = this.state.transactions.map( function(transaction) {
      return (
        <Closeout transaction={transaction} key={transaction.id} process={self.processSettlement}  />
      );
    });

    balancingTransactions = this.state.balancing_transactions.map( function(transaction) {
      return (
        <BalancingTransaction transaction={transaction} key={transaction.id}  handleChange={ self.handleChange } />
      );
    });

    const transaction = this.state.transaction;

    return (
      <div>
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

        {/*modal*/}
        <Modal show={this.state.showModal} onHide={this.close}>
          <Modal.Header closeButton>
            <Modal.Title>Close Out Settlement</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            { transaction &&
              <div>
                { this.state.processed ?
                  <p>{this.state.message}</p>
                  :
                  <div>
                    <p>Beneficiary for the closeout amount</p>
                    <FormGroup>
                      <Radio name="settlement_by" inline onClick={() => self.prepareSettlement(transaction, 'client')}>
                        Client
                      </Radio>
                      {' '}
                      <Radio name="settlement_by" inline onClick={() => self.prepareSettlement(transaction, 'broker')}>
                        Broker
                      </Radio>
                    </FormGroup>

                    {/* Balancing Transaction list to select from for buy closeouts */}
                    { this.state.balancing_transactions.length > 0 &&
                      <table className="table">
                        <thead>
                        <tr>
                          <th>Select</th>
                          <th className="text-center">Transaction<br/>Date</th>
                          <th className="text-center">Transaction No</th>
                          <th className="text-center">Broker</th>
                          <th className="text-center">Qty</th>
                          <th className="text-center">Rate</th>
                          <th className="text-center">Amount</th>
                        </tr>
                        </thead>
                        <tbody>
                        {balancingTransactions}
                        </tbody>
                      </table>
                    }

                    {this.state.error && <p className="text-danger">{this.state.error}</p>}
                    <Button disabled={!this.state.settlement_by} onClick={this.submit}>Process</Button>
                  </div>
                }
              </div>
            }
          </Modal.Body>
          <Modal.Footer>
            <Button onClick={this.close}>Close</Button>
          </Modal.Footer>
        </Modal>
      </div>

    );
  }
};