import React, { useState, useEffect } from "react";
import { Bar } from "react-chartjs-2";
import "./HomePage.css";
import {
  Chart,
  BarElement,
  CategoryScale,
  LinearScale,
  Tooltip,
  Legend,
} from "chart.js";

Chart.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend);

const HomePage = ({isLoggedIn, userRole}) => {
  const [numVisitors, setNumVisitors] = useState(30);
  const [gyms, setGyms] = useState(null);
  const [selectedGym, setSelectedGym] = useState(null);
  const [chartData, setChartData] = useState(null);
  const [openHours, setOpenHours] = useState([11, 12, 13, 14, 15, 16, 17, 18]); 

  useEffect(() => {
    fetch("https://infsus-project-gym.fly.dev/gym/locations/")
      .then((response) => response.json())
      .then((data) => {
        setGyms(data);
        setSelectedGym(data[0]);
        generateChartData(data[0]); 
      })
      .catch((error) => console.error("Error fetching gyms:", error));
  }, []);

  const generateChartData = (gym) => {
    const data = {
      labels: Array.from({ length: 24 }, (_, i) => i),
      datasets: [
        {
          label: "Posjećenost teretane",
          backgroundColor: "rgba(75,192,192,0.2)",
          borderColor: "rgba(75,192,192,1)",
          borderWidth: 1,
          hoverBackgroundColor: "rgba(75,192,192,0.4)",
          hoverBorderColor: "rgba(75,192,192,1)",
          data: Array.from({ length: 24 }, (_, i) => openHours.includes(i) ? Math.floor(Math.random() * gym.capacity) : 0),
        },
      ],
    };
    setChartData(data);
  };

  const options = {
    scales: {
      x: {
        type: "category",
        title: {
          display: true,
          text: "Vrijeme (sati)",
        },
        labels: Array.from({ length: 24 }, (_, i) => i),
      },
      y: {
        beginAtZero: true,
        title: {
          display: true,
          text: "Broj korisnika", 
        },
      },
    },
  };

  const handleButtonClick = (selectedGymId) => {
    const selected = gyms.find((gym) => gym.id === selectedGymId);
    setSelectedGym(selected);
    generateChartData(selected);
  };

  return (
    <div className="full-bcg">
      <h1 className="all-text">Dobrodošli na GYMS!</h1>
      {isLoggedIn === false && <p className="all-text">Prijavite se kako biste pristupili uslugama.</p>}
      {isLoggedIn ===  true && <div className="gym-buttons">
        {gyms && gyms.map(gym => (
          <button className="gym-btn" key={gym.id} onClick={() => handleButtonClick(gym.id)}>
            {gym.address}
          </button>
        ))}
      </div>}
      <div className="visitors">
        {isLoggedIn === true && chartData && <Bar data={chartData} options={options}></Bar>}
      </div>
    </div>
  );
};

export default HomePage;
