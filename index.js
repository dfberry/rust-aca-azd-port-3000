// Import the express module
const express = require('express');

// Initialize the express application
const app = express();

// Define a simple route
app.get('/', (req, res) => {
  res.json({ message: 'Hello, world - 1' });
});

// Start the server on port 3000
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});