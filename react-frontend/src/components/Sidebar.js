import React from 'react';
import { Link } from 'react-router-dom';

function Sidebar() {
  return (
    <aside className="app-sidebar">
      <nav>
        <ul>
          <li><Link to="/dashboard">Dashboard Overview</Link></li>
          <li><Link to="/products">Manage Products</Link></li>
          <li><Link to="/orders">Manage Orders</Link></li>
          {/* Add more links for admin/user functionality */}
        </ul>
      </nav>
    </aside>
  );
}

export default Sidebar;
