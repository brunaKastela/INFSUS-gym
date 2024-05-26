import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import './Navbar.css'

const Navbar = ({ isLoggedIn, userRole, setIsLoggedIn, setUserRole, setUserId }) => {
    console.log(userRole)
  const handleLogin = () => {
    navigate('/login')
    // setIsLoggedIn(true);
    // setUserRole('member');
  };

  const navigate = useNavigate();

  const handleLogout = () => {
    setIsLoggedIn(false);
    setUserRole('guest');
    navigate('/')
    setUserId(null);
  };

  return (
    <div className='nav-div'>
        <nav>
        <ul>
            <li><Link to="/">Početna</Link></li>
            {!isLoggedIn && <li><button onClick={handleLogin}>Prijava</button></li>}
            {isLoggedIn && (
            <>
                {(userRole === 'member' || userRole === 'admin') && <li><Link to="/services">Usluge</Link></li>}
                {userRole === 'member' && <li><Link to="/reservations">Rezervacije</Link></li>}
                {userRole === 'member' && <li><Link to="/profile">Profil</Link></li>}
                {(userRole === 'employee' || userRole === 'admin') && <li><Link to="/users">Korisnici</Link></li>}
                <li><button onClick={handleLogout}>Odjava</button></li>
            </>
            )}
        </ul>
        </nav>
    </div>
  );
}

export default Navbar;