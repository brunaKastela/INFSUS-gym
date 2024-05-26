import React, { useState, useEffect } from "react";
import axios from "axios";
import "./Members.css";

const MembersPage = ({ userRole }) => {
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchData = async () => {
    try {
      // const response = await axios.get('https://infsus-project-gym.fly.dev/gym/admin/users');
      var response;
      if (userRole === "employee") {
        response = await axios.get(
          "https://infsus-project-gym.fly.dev/gym/employee/members/subscriptions"
        );
      } else {
        response = await axios.get(
          "https://infsus-project-gym.fly.dev/gym/admin/users"
        );
      }
      setMembers(response.data);
    } catch (error) {
      console.error("Error fetching members:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleApproveSubscription = async (subId) => {
    try {
      await axios.post(
        `https://infsus-project-gym.fly.dev/gym/employee/members/approveSubsctiption/${subId}`,
        {}
      );
      fetchData();
    } catch (error) {
      console.error("Error approving subscription:", error);
    }
  };

  const handleDeleteProfile = async (memberId) => {
    try {
      await axios.delete(
        `https://infsus-project-gym.fly.dev/gym/admin/users/${memberId}`
      );
      setMembers((prevMembers) =>
        prevMembers.filter((member) => member.id !== memberId)
      );
    } catch (error) {
      console.error("Error deleting profile:", error);
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="members-page">
      <h1>Članovi</h1>
      <table>
        <thead>
          <tr>
            <th>Ime</th>
            <th>Email</th>
            {userRole === "employee" && <th>Članarina</th>}
            {userRole === "employee" && <th>Tip</th>}
            {userRole === "employee" && <th>Vrijedi od</th>}
            {userRole === "employee" && <th>Vrijedi do</th>}
            {userRole === "employee" && <th>Odobri članarinu</th>}
            {userRole === "admin" && <th>Obriši profil</th>}
          </tr>
        </thead>
        <tbody>
          {members.map(
            (member) =>
              ((!member.approved && userRole === "employee") ||
                userRole === "admin") && (
                <tr
                  key={userRole === "admin" ? member.id : member.subscriptionId}
                >
                  <td>
                    {userRole === "admin" ? member.name : member.member.name}{" "}
                    {userRole === "admin"
                      ? member.surname
                      : member.member.surname}
                  </td>
                  <td>
                    {userRole === "admin" ? member.email : member.member.email}
                  </td>
                  {userRole === "employee" && (
                    <>
                      <td>{member.membership.title}</td>
                      <td>
                        {member.subscriptionType.title === "weekly"
                          ? "Tjedna"
                          : member.subscriptionType.title === "monthly"
                          ? "Mjesečna"
                          : "Godišnja"}
                      </td>
                      <td>{new Date(member.validFrom).toLocaleDateString()}</td>
                      <td>
                        {new Date(member.validUntil).toLocaleDateString()}
                      </td>
                      <td>
                        {member.subscriptionApproved ? (
                          <div className="approved">Tip</div>
                        ) : (
                          <button
                            className="approve-btn"
                            onClick={() =>
                              handleApproveSubscription(member.subscriptionId)
                            }
                          >
                            Odobri
                          </button>
                        )}
                      </td>
                    </>
                  )}
                  {userRole === "admin" && (
                    <td>
                      <button onClick={() => handleDeleteProfile(member.id)}>
                        Obriši
                      </button>
                    </td>
                  )}
                </tr>
              )
          )}
        </tbody>
      </table>
    </div>
  );
};

export default MembersPage;
