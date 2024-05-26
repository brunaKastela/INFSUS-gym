import React, { useState, useEffect } from "react";
import axios from "axios";
import "./Profile.css";
import { useNavigate } from 'react-router-dom';

const ProfilePage = ({ userId, setIsLoggedIn }) => {
  const [profile, setProfile] = useState({
    name: "",
    surname: "",
    phoneNumber: "",
    dateOfBirth: "",
    email: "",
    userTypeId: "",
    userTypeName: "",
    id: userId,
  });
  const [initialProfile, setInitialProfile] = useState({});
  const [isEditing, setIsEditing] = useState(false);
  const [isDeleted, setIsDeleted] = useState(false);
  const navigate = useNavigate();

  const fetchProfile = async () => {
    try {
      const response = await axios.get(
        `https://infsus-project-gym.fly.dev/gym/admin/users/${userId}`
      );
      setProfile(response.data);
      setInitialProfile(response.data);
    } catch (error) {
      console.error("Error fetching profile:", error);
    }
  };

  useEffect(() => {
    if (!isDeleted) {
      fetchProfile();
    }
  }, [userId, isDeleted]);

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

  const handleDelete = async () => {
    try {      
      await axios.delete(
        `https://infsus-project-gym.fly.dev/gym/account/deleteAccount/${profile.id}`
      );      
      setIsLoggedIn(false);
      setIsDeleted(true);
      navigate('/');
    } catch (error) {
      console.error("Error deleting profile:", error);
    }
  };

  const handleCancel = () => {
    setProfile(initialProfile);
    setIsEditing(false);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const updatedProfile = {
        id: profile.id,
        name: profile.name,
        surname: profile.surname,
        phoneNumber: profile.phoneNumber,
        email: profile.email,
      };
      await axios.put(
        `https://infsus-project-gym.fly.dev/gym/admin/users`,
        updatedProfile
      );
      setIsEditing(false);
      fetchProfile();
    } catch (error) {
      console.error("Error updating profile:", error);
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
            value={profile.dateOfBirth.split("T")[0]}
            onChange={handleChange}
            disabled={true}
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
            <button className="edit-btn submit-btn" type="submit">
              Spremi
            </button>
            <button
              className="edit-btn cancel-btn"
              type="button"
              onClick={handleCancel}
            >
              Odustani
            </button>
          </>
        ) : (
          <button className="edit-btn" onClick={handleEdit}>
            Uredi
          </button>          
        )}
        {!isEditing && <button className="edit-btn" onClick={handleDelete}>
            Obriši
          </button>}
      </form>
    </div>
  );
};

export default ProfilePage;
