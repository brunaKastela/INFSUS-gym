import React, { useState } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom';
import './Login.css';

const LoginPage = ({ setIsLoggedIn, setUserRole }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = async () => {
    try {
      const response = await axios.post('https://infsus-project-gym.fly.dev/gym/account/login', {
        email,
        password
      });
      // Set user data and login status
      const userData = response.data;
      setIsLoggedIn(true);
      setUserRole(userData.userTypeName);
      // Redirect to home page or any other page after login
      // You can use useHistory from 'react-router-dom' for redirection
    } catch (error) {
      console.error('Error logging in:', error);
      // Handle login error
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
      </form>
      <p className="signup-link">Nemate račun? <Link to="/signup">Registrirajte se</Link></p> 
    </div>
  );
};

export default LoginPage;
