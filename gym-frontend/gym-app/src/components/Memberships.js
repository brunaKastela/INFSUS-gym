import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Memberships.css';

const MembershipsPage = ({ userRole, userId }) => {
  const [memberships, setMemberships] = useState([]);
  const [selectedMembership, setSelectedMembership] = useState(null);
  const [membershipTypes, setMembershipTypes] = useState([]);
  const [userSubscription, setUserSubscription] = useState([]);

  const fetchMemberships = async () => {
    try {
      const response = await axios.get('https://infsus-project-gym.fly.dev/gym/memberships');
      setMemberships(response.data);
    } catch (error) {
      console.error('Error fetching memberships:', error);
    }
  };

  const fetchMembershipTypes = async () => {
    try {
      const response = await axios.get('https://infsus-project-gym.fly.dev/gym/memberships/types');
      setMembershipTypes(response.data);
    } catch (error) {
      console.error('Error fetching membership types:', error);
    }
  };

  const fetchSubscriptions = async () => {
    try {
      const response = await axios.get(`https://infsus-project-gym.fly.dev/gym/memberships/subscriptions/${userId}`);
      setUserSubscription(response.data);
      console.log(response.data)
    } catch (error) {
      console.error('Error fetching subscriptions:', error);
    }
  };

  useEffect(() => {
    fetchMemberships();
    fetchMembershipTypes();
    fetchSubscriptions();
  }, []);

  const handleSelect = async (membershipId, type) => {
    try {
      const selectedType = membershipTypes.find(membershipType => membershipType.title === type);
      const postData = {
        userId: userId,
        membershipId,
        subscriptionTypeId: selectedType.id
      };
      const response = await axios.post('https://infsus-project-gym.fly.dev/gym/memberships', postData);
      await fetchSubscriptions();
    } catch (e) {
      console.error('Error selecting membership:', e);
    }
    setSelectedMembership({ id: membershipId, type });
  };

  const handleEdit = (membershipId) => {
    // Add your edit logic here
    console.log('Edit membership:', membershipId);
  };

  const handleDelete = async (membershipId) => {
    try {
      await axios.delete(`https://infsus-project-gym.fly.dev/gym/memberships/${membershipId}`);
      setMemberships(memberships.filter((membership) => membership.id !== membershipId));
    } catch (error) {
      console.error('Error deleting membership:', error);
    }
  };

  const handleAddNew = () => {
    // Add your logic to show the form for adding new membership
    console.log('Add new membership');
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
            {userRole === 'admin' && <th></th>}
          </tr>
        </thead>
        <tbody>
          {memberships.map((membership) => (
            <tr key={membership.id}>
              <td>{membership.title}</td>
              <td>{membership.description}</td>
              <td>
                {membership.weeklyPrice} €
                <br/>
                {userRole === 'member' && (
                  <button className='action-btn choose-btn' onClick={() => handleSelect(membership.id, 'weekly')}>Odaberi</button>
                )}
              </td>
              <td>
                {membership.monthlyPrice} €
                <br/>
                {userRole === 'member' && (
                  <button className='action-btn choose-btn' onClick={() => handleSelect(membership.id, 'monthly')}>Odaberi</button>
                )}
              </td>
              <td>
                {membership.yearlyPrice} €
                <br/>
                {userRole === 'member' && (
                  <button className='action-btn choose-btn' onClick={() => handleSelect(membership.id, 'yearly')}>Odaberi</button>
                )}
              </td>
              {userRole === 'admin' && 
              <td> (
                  <>
                    <button className='action-btn' onClick={() => handleEdit(membership.id)}>Uredi</button>
                    <button className='action-btn' onClick={() => handleDelete(membership.id)}>Obriši</button>
                  </>
                )
              </td>}
            </tr>
          ))}
        </tbody>
      </table>
      {userRole === 'admin' && <button className="add-new-btn action-btn" onClick={handleAddNew}>Dodaj članarinu</button>}
      <h2>Vaše pretplate</h2>
      <table className="subscriptions-table">
  <thead>
    <tr>
      <th>Tip</th>
      <th>Vrijedi od</th>
      <th>Vrijedi do</th>
      <th>Naziv</th>
      <th>Odobrena</th>
    </tr>
  </thead>
  <tbody>
    {userSubscription.map((subscription) => (
      <tr key={subscription.subscriptionId}>
        <td>{subscription.subscriptionType.title === 'weekly' ? 'Tjedna' 
        : subscription.subscriptionType.title === 'monthly' ? 'Mjesečna' : 'Godišnja'}</td>
        <td>{new Date(subscription.validFrom).toLocaleDateString()}</td>
        <td>{new Date(subscription.validUntil).toLocaleDateString()}</td>
        <td>{subscription.membership.title}</td>
        <td>{subscription.approved ? 'Yes' : 'No'}</td>
      </tr>
    ))}
  </tbody>
</table>

    </div>
  );
};

export default MembershipsPage;
