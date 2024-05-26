import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Members.css'; 

const MembersPage = ({ userRole }) => {
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get('https://infsus-project-gym.fly.dev/gym/admin/users');
        setMembers(response.data);
      } catch (error) {
        console.error('Error fetching members:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  // const handleApproveProfile = async (memberId) => {
  //   try {
  //     await axios.put(`http://127.0.0.1:8080/gym/admin/users/${memberId}`);
  //     setMembers((prevMembers) =>
  //       prevMembers.map((member) =>
  //         member.id === memberId ? { ...member, approved: true } : member
  //       )
  //     );
  //   } catch (error) {
  //     console.error('Error approving profile:', error);
  //   }
  // };

  const handleApproveSubscription = async (memberId) => {
    try {
      await axios.post(`http://127.0.0.1:8080/gym/memberships`, {
        userId: memberId,
        membershipId: 'your-membership-id',
        subscriptionTypeId: 'your-subscription-type-id'
      });
      setMembers((prevMembers) =>
        prevMembers.map((member) =>
          member.id === memberId ? { ...member, subscriptionApproved: true } : member
        )
      );
    } catch (error) {
      console.error('Error approving subscription:', error);
    }
  };

  const handleDeleteProfile = async (memberId) => {
    try {
      await axios.delete(`https://infsus-project-gym.fly.dev/gym/admin/users/${memberId}`);
      setMembers((prevMembers) => prevMembers.filter((member) => member.id !== memberId));
    } catch (error) {
      console.error('Error deleting profile:', error);
    }
  };

  // if (loading) {
  //   return <div>Loading...</div>;
  // }

  return (
    <div className="members-page">
      <h1>Članovi</h1>
      <table>
        <thead>
          <tr>
            <th>Ime</th>
            <th>Email</th>
            {/* <th>Članarina</th> */}
            {/* <th>Odobri profil</th> */}
            {userRole === 'employee' && <th>Odobri članarinu</th>}
            {userRole === 'admin' && <th>Obriši profil</th>}
          </tr>
        </thead>
        <tbody>
          {members.map((member) => (
            <tr key={member.id}>
              <td>{member.name} {member.surname}</td>
              <td>{member.email}</td>
              {/* <td className={member.subscription.approved ? 'approved' : 'pending'}>
                {member.subscription.approved ? 'Odobren' : 'Neriješen'}
              </td> */}
              {/* <td>
                {member.approved ? (
                  <div className="approved">Odobren</div>
                ) : (
                  <button onClick={() => handleApproveProfile(member.id)}>Odobri</button>
                )}
              </td> */}
              {userRole === 'employee' && <td>
                {member.subscriptionApproved ? (
                  <div className="approved">Odobren</div>
                ) : (
                  <button onClick={() => handleApproveSubscription(member.id)}>Odobri</button>
                )}
              </td>}
              {userRole === 'admin' && <td>
                <button onClick={() => handleDeleteProfile(member.id)}>Obriši</button>
              </td>}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default MembersPage;
