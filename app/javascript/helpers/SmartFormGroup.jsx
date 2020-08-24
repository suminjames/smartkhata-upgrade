import React from 'react';
import PropTypes from 'prop-types';

const snakeToCamel = (str) => str.replace(
  /([-_][a-z])/g,
  (group) => group.toUpperCase()
    .replace('-', '')
    .replace('_', ''),
);

export const snakeToHuman = (str) => str
  .replace(/([-_]\w)/g, (g) => g.toUpperCase()
    .replace('_', ' '))
  .replace(/^\w/, (c) => c.toUpperCase());

export const camelToUnderscore = (key) => key.replace(/([A-Z])/g, '_$1').toLowerCase();
export const camelToHuman = (str) => snakeToHuman(camelToUnderscore(str));

function isArray(a) {
  return Array.isArray(a);
}

function isObject(o) {
  return o === Object(o) && !isArray(o) && typeof o !== 'function';
}

export function keysToSnake(o, depth = 2) {
  if (depth <= 0) {
    return o;
  }
  if (isObject(o)) {
    const n = {};

    Object.keys(o)
      .forEach((k) => {
        n[camelToUnderscore(k)] = keysToSnake(o[k], depth - 1);
      });

    return n;
  } if (isArray(o)) {
    return o.map((i) => keysToSnake(i, depth - 1));
  }

  return o;
}

export function keysToCamel(o, depth = 2) {
  if (depth <= 0) {
    return o;
  }
  if (isObject(o)) {
    const n = {};

    Object.keys(o)
      .forEach((k) => {
        n[snakeToCamel(k)] = keysToCamel(o[k], depth - 1);
      });

    return n;
  } if (isArray(o)) {
    return o.map((i) => keysToCamel(i, depth - 1));
  }

  return o;
}

export default function SmartFormGroup({ name, label, errors, children, hideLabel, displayErrorTop, horizontal }) {
  const labelText = label || camelToHuman(name);

  let className = horizontal ? '' :'form-group';

  return (
    <div className={`${className} ${formClass(name, errors)}`}>
      {!hideLabel && <span className="label">{labelText}</span> }
      {
        displayErrorTop && getErrorMessage(name, errors) && (
          <div>
            <span className="error">{getErrorMessage(name, errors)}</span>>
          </div>
        )
      }
      {
        children
      }
      {
        !displayErrorTop && getErrorMessage(name, errors) && (
          <div>
            <span className="error">{getErrorMessage(name, errors)}</span>
          </div>
        )
      }
    </div>
  );
}

const getErrorMessage = (method, errors) => {
  const specificError = ( errors || {})[method];
  return isArray(specificError) ? specificError.join(', ') : specificError;
}

const formClass = (method, errors) => (getErrorMessage(method, errors) !== undefined ? 'has-error' : '');

SmartFormGroup.propTypes = {
  children: PropTypes.node.isRequired,
  displayErrorTop: PropTypes.bool,
  horizontal: PropTypes.bool,
  errors: PropTypes.shape({}),
  hideLabel: PropTypes.bool,
  label: PropTypes.string,
  name: PropTypes.string.isRequired,
};

SmartFormGroup.defaultProps = {
  displayErrorTop: false,
  horizontal: false,
  hideLabel: false,
  label: null,
  errors: null,
};
