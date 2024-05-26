import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Reservations.css'

const ReservationsPage = ({ userId }) => {
  const [reservations, setReservations] = useState([]);
  const [locations, setLocations] = useState([]);
  const [selectedLocation, setSelectedLocation] = useState(null);
  const [timeslots, setTimeslots] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedDate, setSelectedDate] = useState(null);
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [selectedTimeSlot, setselectedTimeSlot] = useState(null);

  const fetchReservations = async () => {
    try {
      const response = await axios.get(`https://infsus-project-gym.fly.dev/gym/reservations/${userId}`);
      setReservations(response.data);
    } catch (error) {
      console.error('Error fetching reservations:', error);
    }
  };

  useEffect(() => {
    const fetchLocations = async () => {
      try {
        const response = await axios.get(`https://infsus-project-gym.fly.dev/gym/locations`);
        setLocations(response.data);
      } catch (error) {
        console.error('Error fetching locations:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchReservations();
    fetchLocations();
  }, [userId]);

  const handleSelectLocation = async (locationId) => {
    setSelectedLocation(locationId);
    setShowDatePicker(true);
  };

  const handleDeleteReservation = async (reservationId) => {
    try {
      await axios.delete(`https://infsus-project-gym.fly.dev/gym/reservations/${reservationId}`);
      setReservations(reservations.filter((reservation) => reservation.reservationId !== reservationId));
    } catch (error) {
      console.error('Error deleting reservation:', error);
    }
  }

  const handleDateChange = async (event) => {
    var selectedDate = event.target.value + 'T00:00:00Z';
    setSelectedDate(selectedDate);

    try {
      const response = await axios.get(`https://infsus-project-gym.fly.dev/gym/locations/${selectedLocation}/${selectedDate}`);
      setTimeslots(response.data);
    } catch (error) {
      console.error('Error fetching timeslots:', error);
    }
  };

  const handleSelectTimeslot = async (timeslotId) => {
    setselectedTimeSlot(timeslotId);
  };

  const makeReservation = async () => {
    try {
      await axios.post('https://infsus-project-gym.fly.dev/gym/reservations', {
        userId: userId,
        timeslotLocationId: selectedTimeSlot
      });
      setSelectedDate(null);
      setShowDatePicker(false);
      fetchReservations();
    } catch (error) {
      console.error('Error making reservation:', error);
    }
  };

  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  return (
    <div className="reservations-container">
      <h1 className="reservations-title">Rezervacije</h1>
      {reservations.length === 0 ? (
  <p>Nema pronađenih rezervacija.</p>
) : (
  <table className="reservations-table">
        <thead>
          <tr>
            <th>Lokacija</th>
            <th>Početak termina</th>
            <th>Kraj termina</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {reservations.map((reservation) => (
            <tr key={reservation.reservationId} className="reservation-row">
              <td>{reservation.timeslot.location.address}</td>
              <td>{new Date(reservation.timeslot.timeslot.startTime).toLocaleString()}</td>
              <td>{new Date(reservation.timeslot.timeslot.endTime).toLocaleString()}</td>
              <td>
                <button className="delete-button" onClick={() => handleDeleteReservation(reservation.reservationId)}>Obriši</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
)}

<h1 className="locations-title">Lokacije</h1>
      <ul className="locations-list">
        {locations.map((location) => (
          <li key={location.id} className="location-item">
            <h2>{location.address}</h2>
            <p>{location.description}</p>
            <p>Radno vrijeme: {location.opening}-{location.closing}</p>
            <p>Broj telefona: {location.phoneNumber}</p>
            <p>{location.email}</p>
            <p>Kapacitet: {location.capacity}</p>
            <button className="select-button" onClick={() => handleSelectLocation(location.id)}>Odaberi vrijeme</button>
          </li>
        ))}
      </ul>

      {showDatePicker && (
        <div className="date-picker">
          <label htmlFor="date">Odaberite datum: </label>
          <input type="date" id="date" onChange={handleDateChange} />
        </div>
      )}

    {selectedDate && (
        <div>
          <h3>Dostupni termini</h3>
          <select onChange={(e) => handleSelectTimeslot(e.target.value)}>
            <option value="">Odaberite termin</option>
            {timeslots.map((timeslot) => (
              <option key={timeslot.id} value={timeslot.id}>
                {new Date(timeslot.timeslot.startTime).toLocaleString()} - {new Date(timeslot.timeslot.endTime).toLocaleString()}
              </option>
            ))}
          </select>
          <button className="reserve-button" onClick={() => makeReservation()} disabled={selectedTimeSlot == null || selectedTimeSlot === ''}>Rezerviraj termin</button>
        </div>
      )}
    </div>
  );
};

export default ReservationsPage;
