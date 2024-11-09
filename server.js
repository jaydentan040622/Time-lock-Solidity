const express = require("express");
const nodemailer = require('nodemailer');
const bodyParser = require('body-parser');
const path = require("path");
const app = express();
app.use(bodyParser.json()); // Parse JSON request bodies
// Serve static files from the current directory (for images, CSS, JS)
app.use(express.static(path.join(__dirname+"/images")));
// Route for index2.html
app.get("/", (req, res) => {
    res.sendFile(path.join(__dirname + "/Main.html"));
});
app.get("/interest", (req, res) => {
    res.sendFile(path.join(__dirname + "/interest.html"));
});

app.get("/DepositAndWithdraw", (req, res) => {
    res.sendFile(path.join(__dirname + "/DepositAndWithdraw.html"));
});

app.get("/Transaction", (req, res) => {
    res.sendFile(path.join(__dirname + "/Transaction.html"));
});
app.get("/Reward", (req, res) => {
    res.sendFile(path.join(__dirname + "/Reward.html"));
});
app.get("/AccountInfo", (req, res) => {
    res.sendFile(path.join(__dirname + "/AccountInfo.html"));
});
app.get("/index3", (req, res) => {
    res.sendFile(path.join(__dirname + "/index3.html"));
});




// Variables to store OTP and its expiration time
let currentOTP;
let otpExpirationTime;

// Generate a random 6-digit OTP
function generateOTP() {
    return Math.floor(100000 + Math.random() * 900000); // Generates a 6-digit number
}

// Email sending route
app.post('/send-otp', (req, res) => {
    const email = req.body.email; // User's email passed from the frontend
    currentOTP = generateOTP(); // Generate the OTP
    otpExpirationTime = Date.now() + 300000; // OTP valid for 5 minutes

    var transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: 'kowyunshen@gmail.com',
            pass: 'sdfo twkl shfj wpmn'
        }
    });

    var mailOptions = {
        from: 'kowyunshen@gmail.com',
        to: email,
        subject: 'OTP Code',
        text: 'Your OTP code is: ' + currentOTP +'.Valid for 5 minutes.'
    };

    transporter.sendMail(mailOptions, function (error, info) {
        if (error) {
            console.log(error);
            res.status(500).send('Error sending OTP');
        } else {
            console.log('Email sent: ' + info.response);
            res.status(200).send('OTP sent');
        }
    });
});

// OTP verification route
app.post('/verify-otp', (req, res) => {
    const userOTP = req.body.otp;

    // Check if the OTP matches and if it's not expired
    if (userOTP == currentOTP && Date.now() < otpExpirationTime) {
        res.status(200).send('OTP verified');
    } else {
        res.status(400).send('Incorrect or expired OTP');
    }
});


const server = app.listen(5001, () => {
    console.log(`Server is running on port ${server.address().port}`);
});
