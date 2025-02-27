import React from 'react';
import ReactDOM from 'react-dom/client';

import MagicBell from './components/MagicBell';
import './index.css';

const App: React.FC = () => {
  return (
    <div
      style={{
        backgroundColor: '#1274a3',
      }}
      className="react-playground-container"
    >
      <MagicBell
        customTheme={{
          icon: {
            width: '50px',
          },
        }}
        userId="test-user-id"
        userEmail="test-user@gmail.com"
      />
    </div>
  );
};

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);

root.render(<App />);
