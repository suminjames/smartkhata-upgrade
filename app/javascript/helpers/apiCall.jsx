import request from 'axios';
import { keysToSnake } from '../helpers/SmartFormGroup';

const BASE_URL = '';

const logEndpoint = (endpoint) => {
  // eslint-disable-next-line no-console
  console.log(BASE_URL + endpoint);
};


const getHeaders = () => {
  const csrf = document.querySelector("meta[name='csrf-token']").getAttribute('content');
  const headers = {
    'Content-Type': 'application/json',
    'X-CSRF-Token': csrf,
  };
  return headers;
};

export default {
  /**
   * Retrieve list of entities from server using AJAX call.
   *
   * @returns {Promise} - Result of ajax call.
   */
  fetchEntities(endpoint, parameters) {
    logEndpoint(endpoint);
    return request({
      method: 'GET',
      url: BASE_URL + endpoint,
      headers: getHeaders(),
      params: keysToSnake(parameters),
      responseType: 'json',
    });
  },

  searchEntities(endpoint) {
    logEndpoint(endpoint);
    return request({
      method: 'GET',
      url: BASE_URL + endpoint,
      headers: getHeaders(),
      responseType: 'json',
    });
  },
  /**
   * Submit new entity to server using AJAX call.
   *
   * @param {Object} entity - Request body to post.
   * @returns {Promise} - Result of ajax call.
   */
  submitEntity(entity, endpoint, method = 'POST') {
    logEndpoint(endpoint);
    return request({
      method,
      url: BASE_URL + endpoint,
      headers: getHeaders(),
      responseType: 'json',
      data: keysToSnake(entity),
    });
  },

  createEntity(entity, endpoint) {
    return this.submitEntity(entity, endpoint);
  },

  patchEntity(entity, endpoint) {
    return this.submitEntity(entity, endpoint, 'PATCH');
  },

  deleteEntity(endpoint) {
    logEndpoint(endpoint);
    return request({
      method: 'DELETE',
      url: BASE_URL + endpoint,
      headers: getHeaders(),
      responseType: 'json',
    });
  },
};
