import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom'; # Added Link
import { getProductById } from '../../services/productService'; # Create this service
import { getProductRecommendations } from '../../services/dataAnalysisService';

function ProductDetail() {
  const { id } = useParams();
  const [product, setProduct] = useState(null);
  const [recommendations, setRecommendations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchProductAndRecommendations = async () => {
      setLoading(true);
      setError('');
      try {
        const productData = await getProductById(id);
        setProduct(productData);

        # Fetch product recommendations from Python backend
        const recs = await getProductRecommendations(id);
        setRecommendations(recs);

      } catch (err) {
        console.error('Error fetching product or recommendations:', err);
        setError('Failed to load product details or recommendations.');
      } finally {
        setLoading(false);
      }
    };
    fetchProductAndRecommendations();
  }, [id]);

  if (loading) return <div>Loading product details...</div>;
  if (error) return <div className="error-message">{error}</div>;
  if (!product) return <div>Product not found.</div>;

  return (
    <div className="product-detail-container">
      <div className="product-info">
        <img src={product.image_url || 'https://via.placeholder.com/300'} alt={product.name} />
        <h2>{product.name}</h2>
        <p>{product.description}</p>
        <p><strong>Price: ${product.price.toFixed(2)}</strong></p>
        <p>Stock: {product.stock}</p>
        <p>Category: {product.category}</p>
        {/* Add "Add to Cart" button or quantity selector */}
      </div>

      <section className="related-products">
        <h3>Related Products (from Python Backend)</h3>
        {recommendations.length > 0 ? (
          <div className="product-recommendations-grid">
            {recommendations.map((rec) => (
              <div key={rec.id} className="recommendation-card">
                <h4>{rec.name}</h4>
                <p>Price: ${rec.price.toFixed(2)}</p>
                <p>Similarity: {rec.score.toFixed(2)}</p>
                <Link to={`/products/${rec.id}`}>View Details</Link>
              </div>
            ))}
          </div>
        ) : (
          <p>No related products found.</p>
        )}
      </section>
    </div>
  );
}

export default ProductDetail;
