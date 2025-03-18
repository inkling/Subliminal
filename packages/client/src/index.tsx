import React from 'react';
import ReactDOM from 'react-dom/client';

import MagicBell from './components/MagicBell';
import './index.css';

const MAGICBELL_API_KEY = '93e3b766f152c9a44a4d3575d765cee62326eee8';

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
        userAPIKey={MAGICBELL_API_KEY}
      />
    </div>
  );
};

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);

root.render(<App />);
