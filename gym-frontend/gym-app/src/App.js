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
  const [userId, setUserId] = React.useState(null);
  
  return (
    <div className="App">
      <BrowserRouter>
        <Navbar isLoggedIn={isLoggedIn} userRole={userRole} setIsLoggedIn={setIsLoggedIn} setUserRole={setUserRole} setUserId={setUserId}/> 
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/users" element={<Members userRole={userRole}/>} />
          <Route path="/services" element={<Memberships userRole={userRole} userId={userId}/>} />
          <Route path="/profile" element={<Profile userId={userId}/>} />
          <Route path="/reservations" element={<Reservations userId={userId}/>} />
          <Route path="/login" element={<Login setIsLoggedIn={setIsLoggedIn} setUserRole={setUserRole} setUserId={setUserId}/>} />
          <Route path="/signup" element={<Register setIsLoggedIn={setIsLoggedIn} setUserRole={setUserRole} setUserId={setUserId}/>} />
          <Route path="*" element={<NotFound />} /> 
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
