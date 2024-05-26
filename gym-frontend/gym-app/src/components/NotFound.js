import React from 'react';
import './NotFound.css'

const NotFoundPage = () => {
  return (
    <div className="not-found-page">
      <h1>404: Page Not Found</h1>
      <p>Stranica koju tražite ne postoji.</p>
      <p>Povratak na <a className='not-found-link' href="/">početnu stranicu</a>.</p>
    </div>
  );
};

export default NotFoundPage;