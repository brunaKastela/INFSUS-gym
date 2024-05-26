import React, { useState } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom';
import './SignUp.css';

const SignupPage = () => {
  const [name, setName] = useState('');
  const [surname, setSurname] = useState('');
  const [email, setEmail] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [dateOfBirth, setDateOfBirth] = useState('');
  const [password, setPassword] = useState('');

  const handleSignup = async () => {
    try {
      const response = await axios.post('http://127.0.0.1:8080/gym/account/createAccount', {
        name,
        surname,
        email,
        phoneNumber,
        dateOfBirth,
        password,
        userTypeId: '71BEAC26-4426-4620-9F74-DA6DCA89D792' // Change this to your desired userTypeId
      });
      // Handle successful signup, such as showing a success message or redirecting to login page
    } catch (error) {
      console.error('Error signing up:', error);
      // Handle signup error
    }
  };

  return (
    <div className="signup-container">
      <h2>Registracija</h2>
      <form onSubmit={handleSignup}>
        <label>
          Ime:
          <input type="text" value={name} onChange={(e) => setName(e.target.value)} />
        </label>
        <label>
          Prezime:
          <input type="text" value={surname} onChange={(e) => setSurname(e.target.value)} />
        </label>
        <label>
          Email:
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
        </label>
        <label>
          Broj telefona:
          <input type="text" value={phoneNumber} onChange={(e) => setPhoneNumber(e.target.value)} />
        </label>
        <label>
          Datum rođenja:
          <input type="date" value={dateOfBirth} onChange={(e) => setDateOfBirth(e.target.value)} />
        </label>
        <label>
          Lozinka:
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        </label>
        <button type="submit">Registrirajte se</button>
      </form>
      <p className="login-link">Već imate račun? <Link to="/login">Prijavite se</Link></p>
    </div>
  );
};

export default SignupPage;
