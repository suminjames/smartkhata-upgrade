var Button = ReactBootstrap.Button;
var Modal = ReactBootstrap.Modal;
var FormGroup = ReactBootstrap.FormGroup;
var Radio = ReactBootstrap.Radio;

class Closeouts extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      transactions: this.props.share_transactions,
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
  }
  close(){
    this.setState({ showModal: false, transaction: null, error: '', settlement_by: null });
  }
  submit() {
    var that = this;
    $.post(
        "/share_transactions/"+ that.state.transaction.id+"/process_closeout.json",
        { 'settlement_by': that.state.settlement_by}
      )
      .done(function(data){
        var newTransactions = that.state.transactions.map(function (item) {
          if(item.id == that.state.transaction.id) {
            item.closeout_settled = true
          }
          return item;
        });
        that.setState({ transactions: newTransactions, message: data.message, processed: true });
      })
      .fail(function(data) {
        debugger
       that.setState({error: data.responseJSON.error})
      });
  }

  processSettlement(transaction) {
    this.setState({ showModal: true, processed: false, transaction: transaction });
  }

  render() {
    var self = this;
    closeouts = this.state.transactions.map( function(transaction) {
      return (
        <Closeout transaction={transaction} key={transaction.id} process={self.processSettlement} />
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

                    { transaction.transaction_type == 'selling' ?
                      <div>
                        <p>Selling Transaction</p>
                        <FormGroup>
                          <Radio name="settlement_by" inline onClick={() => self.setState({settlement_by: 'client'}) }>
                            Client
                          </Radio>
                          {' '}
                          <Radio name="settlement_by" inline onClick={() => self.setState({settlement_by: 'broker'}) }>
                            Broker( self )
                          </Radio>
                        </FormGroup>
                      </div>
                      :
                      <div>
                        <p>Buying Transaction</p>
                      </div>
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