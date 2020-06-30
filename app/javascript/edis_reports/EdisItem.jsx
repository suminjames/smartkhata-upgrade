import React, { useState, useEffect } from 'react';
import EdisItemEdit from './EdisItemEdit';

export default function EdisItem({ item, newItem, sn, addItem}) {
  const [editMode, setEditMode] = useState(newItem ? true : false);
  const [edisItem, setEdisItem ] = useState({});

  useEffect(() => {
    setEdisItem(item)
  }, []);

  const handleEdit = () => {
    setEditMode(true)
  }

  const handleUpdate =(data) =>{
    setEditMode(false );
    const newData = {...data, splitOptions: []}
    setEdisItem(newData);
  }

  const RenderShow =()=> {
    const { settlement_id, contract_number, settlement_date, scrip, boid, client_code , quantity, wacc, reason_code} = edisItem;
    return (
      <tr onClick={ handleEdit }>
        <td>{sn}</td>
        <td>{ contract_number }</td>
        <td>{ settlement_id }</td>
        <td>{ settlement_date }</td>
        <td>{ scrip }</td>
        <td>{ boid } </td>
        <td>{ client_code }</td>
        <td>{ quantity }</td>
        <td>{ reason_code }</td>
        <td>{ wacc }</td>
      </tr>
    )
  }

  return (
    <>
      { <RenderShow /> }
      { editMode && <EdisItemEdit item={edisItem} updateItem={handleUpdate} setEditMode={setEditMode} addItem={addItem} /> }
    </>
  )
}
