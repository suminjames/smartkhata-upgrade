import { useState } from 'react';
import { keysToCamel } from '../helpers/SmartFormGroup';

const useForm = (initialValues, callback) => {
  const [inputs, setInputs] = useState(initialValues);
  const [errors, setError] = useState({});

  const checkEditForm = () => {
    const { id } = inputs;
    return (id !== null && id !== undefined && id !== '');
  };

  const handleSubmit = (event) => {
    if (event) event.preventDefault();
    callback();
  };

  const addError = (error, camelize = true) => {
    const data = ((error.response || {}).data) || error;
    if (data !== undefined) {
      setError(camelize ? keysToCamel(data) : data);
    }
  };

  const handleInputChange = (event) => {
    event.persist();
    setInputs((inputData) => ({ ...inputData, [event.target.name]: event.target.value }));
  };

  const handleManualInputChange = (name, value) => {
    setInputs((inputData) => ({ ...inputData, [name]: value }));
  };

  return {
    handleSubmit,
    handleInputChange,
    inputs,
    errors,
    addError,
    handleManualInputChange,
    setInputs,
    checkEditForm,
  };
};

export default useForm;
