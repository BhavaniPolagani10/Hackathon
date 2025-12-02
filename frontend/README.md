# Dealer Management System - Frontend

A React-based frontend application for the Dealer Sales & Customer Management System.

## Features

- Firebase Authentication (Login & Registration)
- Dashboard with navigation to system modules
- Responsive design for desktop and mobile

## Tech Stack

- **Framework:** React 19
- **Build Tool:** Vite
- **Routing:** React Router v7
- **Authentication:** Firebase Auth
- **Styling:** CSS

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Firebase project with Authentication enabled

### Installation

1. Install dependencies:
   ```bash
   npm install
   ```

2. Configure Firebase:
   - Create a `.env.local` file from `.env.example`
   - Add your Firebase project credentials:
     ```
     VITE_FIREBASE_API_KEY=your-api-key
     VITE_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
     VITE_FIREBASE_PROJECT_ID=your-project-id
     VITE_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
     VITE_FIREBASE_MESSAGING_SENDER_ID=your-sender-id
     VITE_FIREBASE_APP_ID=your-app-id
     ```

3. Start the development server:
   ```bash
   npm run dev
   ```

4. Open http://localhost:5173 in your browser

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## Project Structure

```
frontend/
├── src/
│   ├── components/
│   │   └── auth/           # Authentication components
│   │       ├── Login.jsx
│   │       ├── Register.jsx
│   │       └── Auth.css
│   ├── config/
│   │   └── firebase.js     # Firebase configuration
│   ├── pages/
│   │   ├── Dashboard.jsx   # Main dashboard page
│   │   └── Dashboard.css
│   ├── services/
│   │   └── authService.js  # Authentication service
│   ├── App.jsx             # Main application component
│   ├── App.css             # Global styles
│   └── main.jsx            # Application entry point
├── .env.example            # Environment variables template
├── package.json
└── vite.config.js
```

## Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Enable Email/Password authentication:
   - Navigate to Authentication → Sign-in method
   - Enable Email/Password provider
4. Get your Firebase config from Project Settings → General
5. Add the config values to your `.env.local` file

## License

MIT
