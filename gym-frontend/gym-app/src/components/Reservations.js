import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Reservations.css';

const ReservationsPage = () => {
//   const [reservations, setReservations] = useState([]);
//   const [timeslots, setTimeslots] = useState([]);
  const [selectedTimeslot, setSelectedTimeslot] = useState('');
  const [isAdding, setIsAdding] = useState(false);
  const userId = 'C6B58047-25C7-426F-95CD-A78FEB57ACE5'; // Replace with the actual user ID

  const dummyReservations = [
    {
      reservationId: 'EBD36E37-5E19-4FC7-9D84-E638815551F8',
      location: {
        address: 'Heinzlova 47',
        description: 'Modern gym space',
        closing: 19,
        opening: 11,
        phoneNumber: '0996578393',
        email: 'infoHeinzlovaGym@gmail.com',
        capacity: 50
      },
      timeslot: {
        id: 'E8E728B4-54FC-446D-B19E-73D0162082D6',
        startTime: '2024-05-29T10:00:00Z',
        endTime: '2024-05-29T11:00:00Z'
      }
    }
  ];

  // Dummy data for new reservation timeslots
  const dummyTimeslots = [
    {
      id: '1',
      startTime: '2024-06-01T10:00:00Z',
      endTime: '2024-06-01T11:00:00Z'
    },
    {
      id: '2',
      startTime: '2024-06-01T11:00:00Z',
      endTime: '2024-06-01T12:00:00Z'
    }
  ];

  
  const [reservations, setReservations] = useState(dummyReservations);
  const [timeslots, setTimeslots] = useState(dummyTimeslots);

//   useEffect(() => {
//     // Fetch existing reservations
//     const fetchReservations = async () => {
//       try {
//         const response = await axios.get(`http://127.0.0.1:8080/gym/locations/reservations/${userId}`);
//         setReservations(response.data);
//       } catch (error) {
//         console.error('Error fetching reservations:', error);
//       }
//     };

//     // Fetch available timeslots
//     const fetchTimeslots = async () => {
//       try {
//         const response = await axios.get('http://127.0.0.1:8080/gym/locations/DC76CD32-19FB-4ABF-A21F-26829F25ADAC/2024-05-28T00:00:00Z');
//         setTimeslots(response.data);
//       } catch (error) {
//         console.error('Error fetching timeslots:', error);
//       }
//     };

//     fetchReservations();
//     fetchTimeslots();
//   }, []);

  const handleAddReservation = () => {
    setIsAdding(true);
  };

  const handleTimeslotChange = (e) => {
    setSelectedTimeslot(e.target.value);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (selectedTimeslot) {
      const newReservation = {
        userId,
        timeslotId: selectedTimeslot
      };

      try {
        const response = await axios.post('http://127.0.0.1:8080/gym/reservations', newReservation);
        setReservations([...reservations, response.data]);
        setIsAdding(false);
        setSelectedTimeslot('');
      } catch (error) {
        console.error('Error creating reservation:', error);
      }
    }
  };

  const handleCancel = () => {
    setIsAdding(false);
    setSelectedTimeslot('');
  };

  return (
    <div className="reservations-page">
      <h1>Rezervirani termini</h1>
      <ul className="reservations-list">
        {reservations.map((reservation) => (
          <li key={reservation.reservationId}>
            <h2>{reservation.location.address}</h2>
            <p>{reservation.location.description}</p>
            <p>
              {new Date(reservation.timeslot.startTime).toLocaleString()} -{' '}
              {new Date(reservation.timeslot.endTime).toLocaleString()}
            </p>
          </li>
        ))}
      </ul>
      <button className='res-btns res-btn' onClick={handleAddReservation}>Rezervirajte novi termin</button>
      {isAdding && (
        <form onSubmit={handleSubmit} className="add-reservation-form">
          <label>
            Odaberite termin:
            <select value={selectedTimeslot} onChange={handleTimeslotChange}>
              <option value="">--Odaberite termin--</option>
              {timeslots.map((slot) => (
                <option key={slot.id} value={slot.id}>
                  {new Date(slot.startTime).toLocaleString()} - {new Date(slot.endTime).toLocaleString()}
                </option>
              ))}
            </select>
          </label>
          <button className='res-btns' type="submit">Spremi</button>
          <button className='res-btns' type="button" onClick={handleCancel}>Odustani</button>
        </form>
      )}
    </div>
  );
};

export default ReservationsPage;
