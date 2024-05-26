import React, { useState } from "react";
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

const HomePage = () => {
  const [numVisitors, setNumVisitors] = useState(30);  
  var ScrollArea = require('react-scrollbar');

  const chartData = {
    labels: Array.from({ length: 24 }, (_, i) => i),
    datasets: [
      {
        label: "Posjećenost teretane",
        backgroundColor: "rgba(75,192,192,0.2)",
        borderColor: "rgba(75,192,192,1)",
        borderWidth: 1,
        hoverBackgroundColor: "rgba(75,192,192,0.4)",
        hoverBorderColor: "rgba(75,192,192,1)",
        data: Array.from({ length: 24 }, () => Math.floor(Math.random() * 50)),
      },
    ],
  };

  const options = {
    scales: {
      x: {
        type: "category",
        title: {
          display: true,
          text: "Vrijeme (sati)", // Oznaka za x os
        },
        labels: Array.from({ length: 24 }, (_, i) => i),
      },
      y: {
        beginAtZero: true,
        title: {
          display: true,
          text: "Broj korisnika", // Oznaka za y os
        },
      },
    },
  };

  return (
    <div className="full-bcg">
      <h1 className="all-text">Dobrodošli na GYMS!</h1>
      <p className="all-text">Prijavite se kako biste pristupili uslugama.</p>
      <div className="visitors">
        <p className="all-text">Trenutni broj korisnika: {numVisitors}</p>
        <Bar data={chartData} options={options}></Bar>
      </div>
    </div>
  );
};

export default HomePage;
