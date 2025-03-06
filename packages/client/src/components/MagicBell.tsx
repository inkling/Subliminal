import MagicBell from '@magicbell/magicbell-react';
import React from 'react';

import UnreadBadge from '../images/unread.svg';

import BellIcon from './icons/BellIcon';

import '../assets/css/magicbell.css';
import NotificationContainer from './FloatingNotificationContainer';
import { NotificationCategory } from '../constants';

type MagicBellProps = {
  userId: string;
  userEmail?: string;
  customTheme?: Record<string, unknown>;
};

const MAGICBELL_API_KEY = '93e3b766f152c9a44a4d3575d765cee62326eee8';

function Badge({ count }: { count: number }) {
  if (count === 0) return null;

  return <img src={UnreadBadge} className="magic-bell-badge"></img>;
}

const stores = [
  {
    id: 'default',
    defaultQueryParams: {},
  },
  {
    id: 'feedback',
    defaultQueryParams: {
      category: NotificationCategory.FEEDBACK,
    },
  },
  {
    id: 'comments',
    defaultQueryParams: {
      category: NotificationCategory.COMMENTS,
    },
  },
  {
    id: 'access',
    defaultQueryParams: {
      category: NotificationCategory.ACCESS,
    },
  },
];

export default function SharedMagicBell({ userId, userEmail, customTheme }: MagicBellProps) {
  return (
    <div className="magic-bell-container">
      <MagicBell
        stores={stores}
        theme={customTheme}
        BellIcon={<BellIcon />}
        apiKey={MAGICBELL_API_KEY}
        userExternalId={userId}
        userEmail={userEmail}
        Badge={Badge}
        bellCounter="unread"
      >
        {props => <NotificationContainer {...props} />}
      </MagicBell>
    </div>
  );
}
