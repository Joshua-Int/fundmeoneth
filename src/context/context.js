/* eslint-disable react/prop-types */
import React, { createContext, useReducer } from "react";
import { initialState } from "./initialState";
import AppReducer from "./reducer";
export const GlobalContext = createContext(initialState);

export const GlobalProvider = ({ children }) => {
  const [state, dispatch] = useReducer(AppReducer, initialState);

  // Actions for changing state
  function addWeb3ProviderToContext(data) {
    dispatch({
      type: "ADD_WEB3_PROVIDER",
      payload: data,
    });
  }

  function setLoading(data) {
    dispatch({
      type: "SET_LOADING",
      payload: data,
    });
  }

  const value = {
    ...state,
    setLoading,
    addWeb3ProviderToContext,
  };

  return (
    <GlobalContext.Provider value={value}>{children}</GlobalContext.Provider>
  );
};
