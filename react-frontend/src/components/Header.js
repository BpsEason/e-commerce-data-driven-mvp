import React from 'react';
import { Link } from 'react-router-dom';

function Header() {
  return (
    <header className="app-header">
      <Link to="/">
        <h1>Data-Driven E-commerce MVP</h1>
      </Link>
      {/* Add navigation, user info, cart icon etc. */}
    </header>
  );
}

export default Header;
