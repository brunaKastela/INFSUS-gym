import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Profile.css';

const ProfilePage = () => {
//   const [profile, setProfile] = useState({
//     name: '',
//     surname: '',
//     phoneNumber: '',
//     dateOfBirth: '',
//     email: '',
//     userTypeId: '',
//     userTypeName: ''
//   });
//   const [isEditing, setIsEditing] = useState(false);
  const [userId, setUserId] = useState('6B0E6BDF-6F14-48C7-B523-F4155849FFFD'); // replace with actual user ID

//   useEffect(() => {
//     const fetchProfile = async () => {
//       try {
//         const response = await axios.get(`http://127.0.0.1:8080/gym/admin/members/${userId}`);
//         setProfile(response.data);
//       } catch (error) {
//         console.error('Error fetching profile:', error);
//       }
//     };

//     fetchProfile();
//   }, [userId]);

    const dummyProfile = {
        name: 'Mia',
        surname: 'Lovric',
        phoneNumber: '0996571382',
        dateOfBirth: '2004-05-25',
        email: 'mia@example.com',
        userTypeId: '26519AEA-35B9-49A3-8E56-FCBB370E617D',
        userTypeName: 'employee'
    };

    const [profile, setProfile] = useState(dummyProfile);
    const [isEditing, setIsEditing] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setProfile((prevProfile) => ({
      ...prevProfile,
      [name]: value,
    }));
  };

  const handleEdit = () => {
    setIsEditing(true);
  };

  const handleCancel = () => {
    setIsEditing(false);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.put(`http://127.0.0.1:8080/gym/admin/users/${userId}`, profile);
      setIsEditing(false);
    } catch (error) {
      console.error('Error updating profile:', error);
    }
  };

  return (
    <div className="profile-page">
      <h1>Pregled profila</h1>
      <form onSubmit={handleSubmit} className="profile-form">
        <label>
          Ime:
          <input
            type="text"
            name="name"
            value={profile.name}
            onChange={handleChange}
            disabled={!isEditing}
          />
        </label>
        <label>
          Prezime:
          <input
            type="text"
            name="surname"
            value={profile.surname}
            onChange={handleChange}
            disabled={!isEditing}
          />
        </label>
        <label>
          Broj telefona:
          <input
            type="text"
            name="phoneNumber"
            value={profile.phoneNumber}
            onChange={handleChange}
            disabled={!isEditing}
          />
        </label>
        <label>
          Datum rođenja:
          <input
            type="date"
            name="dateOfBirth"
            value={profile.dateOfBirth.split('T')[0]}
            onChange={handleChange}
            disabled={!isEditing}
          />
        </label>
        <label>
          Email:
          <input
            type="email"
            name="email"
            value={profile.email}
            onChange={handleChange}
            disabled={!isEditing}
          />
        </label>
        {isEditing ? (
          <>
            <button type="submit">Spremi</button>
            <button type="button" onClick={handleCancel}>
              Odustani
            </button>
          </>
        ) : (
          <button className='edit-btn' onClick={handleEdit}>
            Uredi
          </button>
        )}
      </form>
    </div>
  );
};

export default ProfilePage;
