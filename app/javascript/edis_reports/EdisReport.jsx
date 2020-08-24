import React from 'react';
import EdisItem from './EdisItem';
import EdisItemEdit from './EdisItemEdit';
import Select from 'react-select';

const ColStyles = {
  sn: { width: 100 },
  scrip: { width: 150, minWidth: 150 }
}


export default class EdisReport extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      id: props.edis_report,
      edisItems: [],
      addedEdisItems: [],
      isinInfoOptions: [],
      newItemKey: 0,
      addingItem: false,
      initialFilterEdisItems: [],
    }
  }

  componentDidMount() {
    fetch(this.props.items_path)
      .then(response => {
        return response.json();
      })
      .then(data => {
        const items = data.map(d => Object.assign(d, {splitOptions: []}))
        this.setState({ edisItems: items, initialFilterEdisItems: items })
      });
  }


  renderItems() {
    const { edisItems } = this.state;
    if(edisItems.length < 1 ) {
      return null;
    }
    return edisItems.map((item, index) => <EdisItem item={item} key={index} sn={index + 1} name={item.contract_number} addItem={this.handleEdisAdd} />)
  }

  handleEdisAdd =(item)=> {
    const { addedEdisItems } = this.state;
    if(Array.isArray(item)){
      this.setState({ addedEdisItems: [...addedEdisItems, ...item], addingItem: false })
    } else{
      this.setState({ addedEdisItems: [...addedEdisItems, item], addingItem: false })
    }
  }

  onHandleContractNoChange = (val) => {
    const { initialFilterEdisItems } = this.state;
    let filteredItems;

    if(val !== null) {
      const value = val.map(item => item.value);
      const filterEdisItem = initialFilterEdisItems.filter((item) => value.includes(item.contract_number))
      filteredItems = filterEdisItem.length < 1 ? initialFilterEdisItems : filterEdisItem;
    } else{
      filteredItems = initialFilterEdisItems;
    }

    this.setState({
      edisItems: filteredItems
    })
  };

  renderNew() {
    const {edisItems, addingItem, newItemKey, id} = this.state;
    if (addingItem) {
      return <EdisItemEdit edisReportId={id} item={edisItems[0]} key={newItemKey} newItem={true}
                           addItem={this.handleEdisAdd} toggleAddingItem={this.toggleAddingItem}/>
    }
  }

  toggleAddingItem = () => {
    let newState = this.state;
    this.setState({
      ...newState, addingItem: false
    })
  };

  renderAddedItems() {
    const { edisItems, addedEdisItems, newItemKey,  } = this.state;
    const length = edisItems.length
    console.log(addedEdisItems);
    return (
      <>
        {
          addedEdisItems.map((item, index) => <EdisItem item={item} key={index} sn={index+1+length} addEdisItem={this.handleEdisAdd} />)
        }
      </>
    )
  }

  render() {
    const { initialFilterEdisItems } = this.state;
    return (
      <div>
        <h4><b>Filter By</b></h4>
        <div className="row">
          <div className="col-sm-6 col-md-4">
            <Select
              isMulti
              placeholder="Contract Number"
              options={ initialFilterEdisItems.map((item) => {
                return { label: item.contract_number, value: item.contract_number }
              })}
              onChange={(value) => this.onHandleContractNoChange(value)}
            />
          </div>
        </div>
        <br/>
        <table className="table table-bordered table-striped edis">
          <thead>
            <tr>
              <th style={ColStyles.sn}>SN.</th>
              <th>Contract Number</th>
              <th>Settlement Id</th>
              <th>Settlement Date</th>
              <th style={ColStyles.scrip}>Scrip</th>
              <th>BoId</th>
              <th>Client Code</th>
              <th>Quantity</th>
              <th>Reason Code</th>
              <th>Wacc</th>
            </tr>
          </thead>
          <tbody>
          <tr className="info actions">
            <td colSpan={10}>
              <button className='pull-right' onClick={() => this.setState({ addingItem: true })}>Add</button>
            </td>
          </tr>
          { this.renderNew() }
          { this.renderItems() }
          { this.renderAddedItems() }
          </tbody>
        </table>
      </div>
    )
  }
}
