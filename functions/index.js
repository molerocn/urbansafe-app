const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// Initialize Firebase Admin
admin.initializeApp();

// Read configured credentials (Gmail or Outlook)
// For Gmail: set `gmail.email` and `gmail.password` (app password recommended)
// For Outlook/Hotmail: set `outlook.email` and `outlook.password` (App Password if using 2FA)
const gmailEmail = functions.config().gmail?.email;
const gmailPassword = functions.config().gmail?.password;
const outlookEmail = functions.config().outlook?.email;
const outlookPassword = functions.config().outlook?.password;

// Build transporter depending on available config
let transporter;
if (gmailEmail && gmailPassword) {
  transporter = nodemailer.createTransport({
    service: "gmail",
    auth: { user: gmailEmail, pass: gmailPassword },
    });
} else if (outlookEmail && outlookPassword) {
  // Use SMTP for Outlook/Hotmail (Office365)
  transporter = nodemailer.createTransport({
    host: "smtp.office365.com",
    port: 587,
    secure: false,
    auth: { user: outlookEmail, pass: outlookPassword },
    tls: { ciphers: "SSLv3" },
  });
} else {
  transporter = null;
}

/**
 * HTTP Cloud Function to send password recovery email
 */
exports.sendPasswordRecoveryEmail = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST");
  res.set("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.status(200).send("");
    return;
  }

  try {
    const { email, code } = req.body;

    if (!email || !code) {
      return res.status(400).json({ error: "Missing email or code" });
    }

    if (!gmailEmail || !gmailPassword) {
      console.warn("Gmail credentials not configured - email not sent");
      return res.status(200).json({ message: "Code stored (email service not configured)" });
    }

    const emailContent = `
      <h2>Recuperación de Contraseña / Password Recovery</h2>
      
      <h3>Español:</h3>
      <p>Has solicitado restablecer tu contraseña en UrbanSafe.</p>
      <p>Tu código de recuperación es:</p>
      <h1 style="color: #1976D2; letter-spacing: 2px; font-family: monospace;">${code}</h1>
      <p>Este código expirará en 15 minutos.</p>
      <p>Si no solicitaste este cambio, ignora este correo.</p>
      
      <hr>
      
      <h3>English:</h3>
      <p>You requested to reset your password on UrbanSafe.</p>
      <p>Your recovery code is:</p>
      <h1 style="color: #1976D2; letter-spacing: 2px; font-family: monospace;">${code}</h1>
      <p>This code will expire in 15 minutes.</p>
      <p>If you didn't request this change, please ignore this email.</p>
    `;

    const mailOptions = {
      from: gmailEmail,
      to: email,
      subject: "UrbanSafe - Código de Recuperación / Recovery Code",
      html: emailContent,
    };

    await transporter.sendMail(mailOptions);
    return res.status(200).json({ message: "Email sent successfully" });
  } catch (error) {
    console.error("Error sending email:", error);
    return res.status(500).json({ error: "Failed to send email", details: error.message });
  }
});

/**
 * Callable Cloud Function to reset password (alternative to HTTP)
 */
exports.resetPassword = functions.https.onCall(async (data, context) => {
  try {
    const { email, code, newPassword } = data;

    if (!email || !code || !newPassword) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields"
      );
    }

    if (newPassword.length < 6) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Password must be at least 6 characters"
      );
    }

    // Find user by email
    const userQuery = await admin
      .firestore()
      .collection("users")
      .where("correo", "==", email)
      .limit(1)
      .get();

    if (userQuery.empty) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    const userId = userQuery.docs[0].id;

    // Get recovery code
    const recoveryDoc = await admin
      .firestore()
      .collection("password_recovery")
      .doc(userId)
      .get();

    if (!recoveryDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "No recovery code found"
      );
    }

    const recoveryData = recoveryDoc.data();
    const storedCode = recoveryData.code;
    const expiresAt = recoveryData.expiresAt;
    const used = recoveryData.used;

    // Validate code
    if (storedCode !== code) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid recovery code"
      );
    }

    // Check expiration
    if (!expiresAt || expiresAt.toDate() < new Date()) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Recovery code has expired"
      );
    }

    // Check if code was already used
    if (used) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Recovery code has already been used"
      );
    }

    // Hash password (simple hash for demo - in production use bcrypt)
    const crypto = require("crypto");
    const hash = crypto
      .createHash("sha256")
      .update(newPassword + email)
      .digest("hex");

    // Update user password
    await admin.firestore().collection("users").doc(userId).update({
      passwordHash: hash,
    });

    // Mark code as used
    await admin
      .firestore()
      .collection("password_recovery")
      .doc(userId)
      .update({ used: true });

    return { success: true, message: "Password reset successfully" };
  } catch (error) {
    throw error;
  }
});
