import MagicBell from '@magicbell/magicbell-react';
import React from 'react';

import BellIcon from './icons/BellIcon';

import '../assets/css/magicbell.css';
import NotificationContainer from './FloatingNotificationContainer';

type MagicBellProps = {
  userId: string;
  userEmail?: string;
  customTheme?: Record<string, unknown>;
};

const MAGICBELL_API_KEY = '93e3b766f152c9a44a4d3575d765cee62326eee8';

export default function SharedMagicBell({ userId, userEmail, customTheme }: MagicBellProps) {
  return (
    <div className="magic-bell-container">
      <MagicBell theme={customTheme} BellIcon={<BellIcon />} apiKey={MAGICBELL_API_KEY} userExternalId={userId} userEmail={userEmail}>
        {props => <NotificationContainer {...props} />}
      </MagicBell>
    </div>
  );
}
