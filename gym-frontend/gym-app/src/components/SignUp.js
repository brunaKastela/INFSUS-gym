import React, { useState } from 'react';
import axios from 'axios';
import { Link, useNavigate } from 'react-router-dom';
import './SignUp.css';

const SignupPage = ({ setIsLoggedIn, setUserRole, setUserId }) => {
  const [name, setName] = useState('');
  const [surname, setSurname] = useState('');
  const [email, setEmail] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [dateOfBirth, setDateOfBirth] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();

  const handleSignup = async (e) => {
    const date = new Date(dateOfBirth);
    const isoDate = date.toISOString();
    e.preventDefault(); 
    try {
      console.log({
        name,
        surname,
        email,
        phoneNumber,
        dateOfBirth: isoDate,
        password,
        userTypeId: '71BEAC26-4426-4620-9F74-DA6DCA89D792' 
      })
      const response = await axios.post('https://infsus-project-gym.fly.dev/gym/account/createAccount', {
        name,
        surname,
        email,
        phoneNumber,
        dateOfBirth: '2000-05-23T00:00:00Z',
        password,
        userTypeId: '71BEAC26-4426-4620-9F74-DA6DCA89D792'  // member
      });
      const userData = response.data;
      setIsLoggedIn(true);
      setUserRole(userData.userTypeName);
      setUserId(userData.id);
      navigate('/');
      // Handle successful signup, such as showing a success message or redirecting to login page
    } catch (error) {
      console.error('Error signing up:', error);
    }
  };

  return (
    <div className="signup-container">
      <h2>Registracija</h2>
      <form onSubmit={handleSignup}>
        <label>
          Ime:
          <input type="text" value={name} onChange={(e) => setName(e.target.value)} required />
        </label>
        <label>
          Prezime:
          <input type="text" value={surname} onChange={(e) => setSurname(e.target.value)} required />
        </label>
        <label>
          Email:
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        </label>
        <label>
          Broj telefona:
          <input type="text" value={phoneNumber} onChange={(e) => setPhoneNumber(e.target.value)} required />
        </label>
        <label>
          Datum rođenja:
          <input type="date" value={dateOfBirth} onChange={(e) => setDateOfBirth(e.target.value)} required />
        </label>
        <label>
          Lozinka:
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
        </label>
        <button type="submit">Registrirajte se</button>
      </form>
      <p className="login-link">Već imate račun? <Link to="/login">Prijavite se</Link></p>
    </div>
  );
};

export default SignupPage;
