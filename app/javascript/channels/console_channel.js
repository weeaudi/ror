// app/javascript/channels/console_channel.js

console.log("Script loaded");

import consumer from "channels/consumer";

console.log("Consumer Imported");

let numOfCommands = 0;

let cpuChart;
let memoryChart;
let cpuData = [];
let memoryData = [];
const maxDataPoints = 20;

const createChart = (ctx, label, data, yLabel) => {
  return new Chart(ctx, {
    type: 'line',
    data: {
      labels: Array(data.length).fill(''), // Placeholder labels
      datasets: [{
        label: label,
        data: data,
        fill: false,
        borderColor: 'rgb(75, 192, 192)',
        tension: 0.1
      }]
    },
    options: {
      animation: {
        duration: 0 // Disable animation
      },
      scales: {
        y: {
          beginAtZero: true,
          title: {
            display: true,
            text: yLabel
          }
        }
      }
    }
  });
};

document.addEventListener("DOMContentLoaded", () => {
  const cpuCtx = document.getElementById('cpuChart').getContext('2d');
  cpuChart = createChart(cpuCtx, 'CPU Usage (%)', cpuData, 'CPU %');

  const memoryCtx = document.getElementById('memoryChart').getContext('2d');
  memoryChart = createChart(memoryCtx, 'Memory Usage (MB)', memoryData, 'Memory MB');
});

const updateChart = (chart, data) => {
  chart.data.labels.push(''); // Add placeholder label
  chart.data.datasets[0].data.push(data);
  if (chart.data.labels.length > maxDataPoints) {
    chart.data.labels.shift();
    chart.data.datasets[0].data.shift();
  }
  chart.update();
};

const channel = consumer.subscriptions.create({ channel: "ConsoleChannel", server_uuid: window.serverUuid, server_id: window.serverId }, {
  received(data) {
    const consoleOutput = document.getElementById('console_output');
    const line = document.createElement('div');
    data = JSON.parse(data);
    if (data["event"] === "RC") {
      line.textContent = data["args"][0];
      consoleOutput.appendChild(line);
      consoleOutput.scrollTop = consoleOutput.scrollHeight;
      numOfCommands+=1;
      console.log(numOfCommands);
    } else if (data["event"] === "RS") {
      const stats = JSON.parse(data["args"][0]);

      // Update CPU chart
      updateChart(cpuChart, stats.cpu_absolute);

      // Update memory chart
      const memoryUsageMB = stats.memory_bytes / (1024 * 1024);
      updateChart(memoryChart, memoryUsageMB);
    }
  },

  hookConsoleInput() {
    console.log("Starting Hook");
    document.getElementById('command_form').addEventListener('submit', (event) => {
      event.preventDefault();
      var commandInput = document.getElementById('command_input');
      var command = commandInput.value.trim();
      console.log(command);
      if (command) {
        console.log("Sending Command");
        this.perform("command", { command }); // Use an object to send the command data
        commandInput.value = ''; // Clear input field
        console.log("Command Sent");
      }
    });
    console.log("Hook Created");
  },

  connected() {
    console.log("Hooking Console");
    this.hookConsoleInput();
    console.log("Console Hooked");
  },
});

console.log("Consumer Subscribed");
