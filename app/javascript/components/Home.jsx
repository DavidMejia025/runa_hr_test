import React from "react";
import { Link } from "react-router-dom";

export default () => (
  <div className="vw-100 vh-100 primary-color d-flex align-items-center justify-content-center">
    <div className="jumbotron jumbotron-fluid bg-transparent">
      <div className="container secondary-color">
        <h1 className="display-4">Welcomne to Runa Registry system.</h1>
        <p className="lead">
          The place where you daily get into the company
        </p>
        <hr className="my-4" />
        <p>
          <Link
            to="/auth/login"
            className="btn btn-sm"
            role="button"
          >
            login
          </Link>
          <Link
            to="/auth/signup"
            className="btn btn-sm"
            role="button"
          >
            signup
          </Link>
        </p>
      </div>
    </div>
  </div>
);
