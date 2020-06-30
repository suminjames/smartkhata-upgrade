import React, { useEffect, useState } from 'react';
import AsyncSelect from 'react-select/async';
import Select from 'react-select';
import ReactDatetime from 'react-datetime';
import moment from 'moment';
import apiCall from '../helpers/apiCall';
import SmartFormGroup from '../helpers/SmartFormGroup';
import useSmartForm from '../hooks/useSmartForm';
import { Modal, Button } from 'react-bootstrap';
import update from "immutability-helper";

const defaultItem = {
  id: null,
  settlement_id: '',
  contract_number: '',
  settlement_date: '',
  scrip: '',
  boid: '',
  client_code: '',
  quantity: '',
  wacc: '',
  edis_report_id: null,
  reason_code: ''
}

const customStyles = {
  control: base => ({
    ...base,
    height: 32,
    minHeight: 32
  })
};

const reasonCodeOptions = [
  { label: "Merge", value: "merge"},
  { label: "Regular", value: "regular"}
];

const loadIsinOptions = (inputValue, callback) => {
  if(inputValue && inputValue.length > 2) {
    return getIsinOptions(inputValue).then((results) => callback(results));
  }
  return []
};

const getIsinOptions = (searchTerm) => {
  return apiCall.fetchEntities('0/0/isin_infos/combobox_ajax_filter.json', { q: searchTerm, full_record: true })
    .then((res) => res.data.map((x) => (
        { label: `${x.company} (${x.isin})`, value: x.isin }
      )))
    .catch(() => {
    });
}

export default function EdisItem({ item, newItem, addItem, updateItem, edisReportId, setEditMode, toggleAddingItem }) {
  const [modal, setModal] = useState(true);
  const handleClose = () => {
    setModal(!modal);
    if(setEditMode !== undefined){
      setEditMode(false);
    }
    if(toggleAddingItem !== undefined){
      toggleAddingItem();
    }
  };
  

  const generateState = () => {
    let newState = {}
    if(item && !newItem) {
      newState = item;
    } else if (item && newItem) {
      const { id, contract_number, scrip, boid, client_code, quantity, wacc, reason_code } = defaultItem;
      newState = { ...item, ...{ id, contract_number, boid, scrip, client_code, quantity, wacc, reason_code }};
    } else {
      newState =  {...defaultItem, edis_report_id: edisReportId }
    }
    return { ...newState, editMode: newItem  ? true : false }
  }

  const handleFormSubmit = () => {
    const {
      id, settlement_id, contract_number, settlement_date, scrip, boid, client_code, quantity, wacc, edis_report_id, reason_code, splitOptions
    } = inputs;

    const isEditForm = checkEditForm();
    const method = isEditForm ? 'PATCH' : 'POST';
    const url = isEditForm ? `/0/0/edis_items/${id}.json` : '/0/0/edis_items.json';
    const data = {
      edis_item: {
        id, settlement_id, contract_number, settlement_date, scrip, boid, client_code, quantity, wacc, edis_report_id, reason_code, split_options: splitOptions
      },
    };

    apiCall
      .submitEntity(data, url, method)
      .then((response) => {
        if(isEditForm) {
          if ((response.data.splitted_records || []).length > 0) {
            const newItems = response.data.splitted_records
            addItem(newItems)
          }
          updateItem(inputs)
        } else {
          addItem(inputs);
        }
        setModal(false);
      })
      .catch((err) => {
        addError(err, false);
      });
  };

  const {
    inputs, handleManualInputChange,handleInputChange, handleSubmit, addError, errors, checkEditForm, setInputs
  } = useSmartForm(generateState(), handleFormSubmit);

  const onHandleIsinChange =(value) => {
    handleManualInputChange('scrip', value.value);
  }

  const onHandleReasonCodeChange = (val) => {
    const { value } = val;
    handleManualInputChange('reason_code', value)
  }

  const onChangeDatePicker =(date) => {
    handleManualInputChange('settlement_date', moment(date).format('YYYY-MM-DD'))
  }

  const actionText  = checkEditForm() ?  'Update' :  'Add';

  const renderInput =(name, isEdit = false)=> {
    return (
      <SmartFormGroup {...{ errors }} hideLabel={false} horizontal={false} name={name} >
      { isEdit ?
            <input className='form-control' type="text" value={inputs[name]} name={name}   onChange={handleInputChange} disabled/>
            :
          <input className='form-control' type="text" value={inputs[name]} name={name} onChange={handleInputChange} />
      }
      </SmartFormGroup>
    )
  }

  const renderSplitOptionInput = (name, index)=> {
    return (
      <SmartFormGroup {...{ errors }} hideLabel={false} horizontal={false} name={name} >
          <input className='form-control' type="text" value={inputs.splitOptions[index][name]} name={name} data-id={index} onChange={handleSplitInputChange} />
      </SmartFormGroup>
    )
  }

  const handleSplitInputChange = (e) => {
    const index = e.target.dataset.id;
    const value = e.target.value;
    const name = e.target.name;
    updateSplitInputs(index, name, value)
  };

  const updateSplitInputs =(index, name, value) => {
    const newItem = update(inputs, {
      splitOptions: {
        [index]: {
          [name]: {
            $set: value
          }
        }
      }
    });
    setInputs(newItem)
  }


  const handleSplit = () => {
    const quantity = inputs.quantity;
    if(!quantity) return null;
    const newItemQuantity = Math.floor(quantity/2)
    const splitOptionQuantity = quantity - newItemQuantity;
    const splitOptions = {
      quantity: splitOptionQuantity,
      wacc: inputs.wacc,
      reason_code: inputs.reason_code
    }
    const newSplitOptions = [...inputs.splitOptions, splitOptions]
    const newItem = update(item, {
      quantity: {
        $set: newItemQuantity
      },
      splitOptions: {
        $set: newSplitOptions
      }
    });
    setInputs(newItem);
    // updateEdisItem(newItem);
  };

  const renderSplitButton = () => {
    if(checkEditForm()){
      return(
        <Button variant="secondary" onClick={handleSplit}>
          Split
        </Button>
      )
    }
  };

  const onHandleSplitReasonCodeChange = (val, option) => {
    const { value } = val;
    const attrs = option.name.split("-")
    const name = attrs[0];
    const index = attrs[1];
    const newItem = update(item, {
      splitOptions: {
        [index]: {
          [name]: {
            $set: value
          }
        }
      }
    });
  setInputs(newItem)
  };

  const renderDiv = (index, sp)=> {
    return (
      <div className="row" key={String(index)}>
        <div className="col-md-4 col-sm-6">
          { renderSplitOptionInput('quantity', index) }
        </div>
        <div className="col-md-4 col-sm-6">
          { renderSplitOptionInput('wacc', index) }
        </div>
        <div className="col-sm-6 col-md-4">
          <span className="label">Reason Code</span>
          <Select
            name={`reason_code-${index}`}
            placeholder="Select Reason Code"
            styles={customStyles}
            options={reasonCodeOptions}
            onChange={(value, option) => updateSplitInputs(index, 'reason_code', value.value )}
            value={reasonCodeOptions.filter((x) => sp.reason_code === x.value)}
          />
        </div>
      </div>
    )
  };

  const { settlement_id, contract_number, settlement_date, scrip, boid, client_code , quantity, wacc, reason_code } = inputs;
  const isEdit = checkEditForm();
  return (
    <>
      <Modal show={modal} onHide={handleClose} className="edis-modal">
        <div className="modal-header justify-content-center">
          <button
            aria-hidden
            className="close"
            data-dismiss="modal"
            type="button"
            onClick={handleClose}
          >
            <span aria-hidden="true">&times;</span>
          </button>
          <h4 className="title title-up">{actionText} Edis Item</h4>
        </div>
        <div className="row">
          <div className="col-sm-6 col-md-6">
            <SmartFormGroup {...{ errors }} hideLabel={false} horizontal={false} name='settlement_date'>
              <ReactDatetime
                inputProps={{
                  className: 'form-control',
                  placeholder: 'Settlement Date',
                  disabled: isEdit
                }}
                dateFormat="YYYY-MM-DD"
                onChange={onChangeDatePicker}
                value={settlement_date}
                timeFormat={false}
              />
            </SmartFormGroup>
          </div>
          <div className="col-sm-6 col-md-6">
            { renderInput('contract_number', isEdit) }
          </div>
        </div>
        <div className="row">
          <div className="col-md-4 col-sm-6">
            { renderInput('quantity') }
          </div>
          <div className="col-sm-6 col-md-4">
            { renderInput('wacc') }
          </div>
          <div className="col-sm-6 col-md-4">
            <SmartFormGroup {...{ errors }} hideLabel={false} horizontal={false} name="reason_code">
              <Select
                placeholder="Select Reason Code"
                styles={customStyles}
                options={reasonCodeOptions}
                onChange={(value) => onHandleReasonCodeChange(value)}
                value={reasonCodeOptions.filter((x) => inputs.reason_code === x.value)}
              />
            </SmartFormGroup>
          </div>
        </div>
        { isEdit && inputs.splitOptions.length > 0 && (
          <SmartFormGroup {...{ errors }} hideLabel horizontal={false} name="splitted_records">
            { inputs.splitOptions.map((sp, index) => renderDiv(index, sp)) }
          </SmartFormGroup>
        )}
        { renderSplitButton() }
        <br/>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleClose}>
            Close
          </Button>
          <Button variant="primary" onClick={handleSubmit}>
            Confirm
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  )
}
