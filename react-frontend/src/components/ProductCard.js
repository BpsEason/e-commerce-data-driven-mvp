import React from 'react';
import { Link } from 'react-router-dom';

function ProductCard({ product }) {
  if (!product) return null;

  return (
    <div className="product-card">
      <img src={product.image_url || 'https://via.placeholder.com/150'} alt={product.name} />
      <h3><Link to={`/products/${product.id}`}>{product.name}</Link></h3>
      <p>{product.description}</p>
      <p>Price: ${product.price.toFixed(2)}</p>
      <p>Stock: {product.stock}</p>
      {/* Add "Add to Cart" button */}
    </div>
  );
}

export default ProductCard;
