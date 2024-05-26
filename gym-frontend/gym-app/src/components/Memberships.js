import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Memberships.css';

const MembershipsPage = ({userRole}) => {
  const [memberships, setMemberships] = useState([]);

  useEffect(() => {
    const fetchMemberships = async () => {
      try {
        const response = await axios.get('https://infsus-project-gym.fly.dev/gym/memberships');
        setMemberships(response.data);
        
      } catch (error) {
        console.error('Error fetching memberships:', error);
      }
    };

    fetchMemberships();
  }, []);

  const [showForm, setShowForm] = useState(false);
  const [newMembership, setNewMembership] = useState({
    title: '',
    description: '',
    weeklyPrice: '',
    monthlyPrice: '',
    yearlyPrice: '',
  });

  const handleApprove = async (membershipId) => {
    // Add your approval logic here
    console.log('Approve membership:', membershipId);
  };

  // const handleApprove = (membershipId) => {
  //   setMemberships((prevMemberships) =>
  //     prevMemberships.map((membership) =>
  //       membership.id === membershipId ? { ...membership, approved: true } : membership
  //     )
  //   );
  // };

  const handleEdit = (membershipId) => {
    // Add your edit logic here
    console.log('Edit membership:', membershipId);
  };

  // const handleEdit = (membershipId) => {
  //   console.log('Edit membership:', membershipId);
  //   setMemberships((prevMemberships) =>
  //     prevMemberships.map((membership) =>
  //       membership.id === membershipId
  //         ? { ...membership, description: 'Edited description' }
  //         : membership
  //     )
  //   );
  // };

  const handleDelete = async (membershipId) => {
    try {
      await axios.delete(`http://127.0.0.1:8080/gym/memberships/${membershipId}`);
      setMemberships(memberships.filter((membership) => membership.id !== membershipId));
    } catch (error) {
      console.error('Error deleting membership:', error);
    }
  };

  // const handleDelete = (membershipId) => {
  //   setMemberships((prevMemberships) =>
  //     prevMemberships.filter((membership) => membership.id !== membershipId)
  //   );
  // };

  const handleAddNew = () => {
    setShowForm(true);
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setNewMembership((prevMembership) => ({
      ...prevMembership,
      [name]: value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('http://127.0.0.1:8080/gym/memberships', newMembership);
      setMemberships([...memberships, response.data]);
      setShowForm(false);
      setNewMembership({
        title: '',
        description: '',
        weeklyPrice: '',
        monthlyPrice: '',
        yearlyPrice: '',
      });
    } catch (error) {
      console.error('Error adding new membership:', error);
    }
  };

  return (
    <div className="memberships-page">
      <h1>Članarine</h1>
      <table className="memberships-table">
        <thead>
          <tr>
            <th>Naziv</th>
            <th>Opis</th>
            <th>Tjedna cijena</th>
            <th>Mjesečna cijena</th>
            <th>Godišnja cijena</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {memberships.map((membership) => (
            <tr key={membership.id}>
              <td>{membership.title}</td>
              <td>{membership.description}</td>
              <td>{membership.weeklyPrice}</td>
              <td>{membership.monthlyPrice}</td>
              <td>{membership.yearlyPrice}</td>
              <td>
                {userRole === 'member' && <button className='action-btn choose-btn' onClick={() => handleApprove(membership.id)}>Odaberi</button>}
                {userRole === 'admin' && <button className='action-btn' onClick={() => handleEdit(membership.id)}>Uredi</button>}
                {userRole === 'admin' && <button className='action-btn' onClick={() => handleDelete(membership.id)}>Obriši</button>}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      {userRole === 'admin' && <button className="add-new-btn action-btn" onClick={handleAddNew}>Dodaj članarinu</button>}
      {showForm && (
        <form className="membership-form" onSubmit={handleSubmit}>
          <h2>Dodaj članarinu</h2>
          <label>
            Naziv:
            <input
              type="text"
              name="title"
              value={newMembership.title}
              onChange={handleChange}
              required
            />
          </label>
          <label>
            Opis:
            <input
              type="text"
              name="description"
              value={newMembership.description}
              onChange={handleChange}
              required
            />
          </label>
          <label>
            Tjedna cijena:
            <input
              type="number"
              name="weeklyPrice"
              value={newMembership.weeklyPrice}
              onChange={handleChange}
              required
            />
          </label>
          <label>
            Mjesečna cijena:
            <input
              type="number"
              name="monthlyPrice"
              value={newMembership.monthlyPrice}
              onChange={handleChange}
              required
            />
          </label>
          <label>
            Godišnja cijena:
            <input
              type="number"
              name="yearlyPrice"
              value={newMembership.yearlyPrice}
              onChange={handleChange}
              required
            />
          </label>
          <button type="submit" className='action-btn'>Dodaj</button>
          <button type="button" className='action-btn cancel-btn' onClick={() => setShowForm(false)}>
            Odustani
          </button>
        </form>
      )}
    </div>
  );
};

export default MembershipsPage;
