import React, { useState } from 'react';
import axios from 'axios';
import { Link, useNavigate } from 'react-router-dom'; 
import './Login.css';

const LoginPage = ({ setIsLoggedIn, setUserRole, setUserId }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState('');
  const navigate = useNavigate(); 

  const handleLogin = async (e) => {
    e.preventDefault();
    if (!email || !password) {
      setErrorMessage('Please fill in all fields.'); 
      return;
    }
    try {
      const response = await axios.post('https://infsus-project-gym.fly.dev/gym/account/login', {
        email,
        password
      });
      const userData = response.data;
      setIsLoggedIn(true);
      setUserRole(userData.userTypeName);
      setUserId(userData.id);
      navigate('/'); 
    } catch (error) {
      if (error.response && error.response.status === 401) {
        setErrorMessage('Invalid email or password.');
      } else {
        setErrorMessage('An unexpected error occurred. Please try again later.');
      }
      console.error('Error logging in:', error);
    }
  };

  return (
    <div className="login-container">
      <h2>Login</h2>
      <form onSubmit={handleLogin}>
        <label>
          Email:
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
        </label>
        <label>
          Password:
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        </label>
        <button type="submit">Login</button>
        {errorMessage && <p className="error-message">{errorMessage}</p>}
      </form>
      <p className="signup-link">Nemate račun? <Link to="/signup">Registrirajte se</Link></p>
    </div>
  );
};

export default LoginPage;
