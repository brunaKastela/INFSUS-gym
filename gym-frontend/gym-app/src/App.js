import logo from './logo.svg';
import './App.css';
import React, { useEffect } from 'react';
import { BrowserRouter, Route, Routes, Navigate } from 'react-router-dom';
import Home from './components/HomePage';
import Navbar from './components/Navbar'
import Members from './components/Members'
import Memberships from './components/Memberships'
import NotFound from './components/NotFound'
import Profile from './components/Profile'
import Reservations from './components/Reservations'
import Login from './components/Login'
import Register from './components/SignUp'

function App() {
  const [isLoggedIn, setIsLoggedIn] = React.useState(false);
  const [userRole, setUserRole] = React.useState("guest");
  
  return (
    <div className="App">
      <BrowserRouter>
        <Navbar isLoggedIn={isLoggedIn} userRole={userRole} setIsLoggedIn={setIsLoggedIn} setUserRole={setUserRole} /> {/* Include the Navbar component */}
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/users" element={<Members userRole={userRole}/>} />
          <Route path="/services" element={<Memberships userRole={userRole}/>} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/reservations" element={<Reservations />} />
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<Register />} />
          <Route path="*" element={<NotFound />} /> {/* Handle not found routes */}
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
