import React from 'react';
import ReactDOM from 'react-dom/client';

import MagicBell from './components/MagicBell';

const App: React.FC = () => {
  return (
    <div
      style={{
        backgroundColor: '#f0f0f0',
      }}
    >
      <h1>My App</h1>
      <MagicBell
        customTheme={{
          icon: {
            width: '50px',
          },
        }}
        userId="testUserId"
      />
    </div>
  );
};

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);

root.render(<App />);
