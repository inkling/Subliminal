import MagicBell from '@magicbell/magicbell-react';
import React from 'react';

import UnreadBadge from '../images/new-unread-icon.svg';

import BellIcon from './icons/BellIcon';

import '../assets/css/magicbell.css';
import NotificationContainer from './FloatingNotificationContainer';
import { NotificationCategory } from '../constants';
import { UserClient } from 'magicbell/user-client';

type MagicBellProps = {
  userId: string;
  userEmail?: string;
  customTheme?: Record<string, unknown>;
  userAPIKey: string;
};

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

export default function SharedMagicBell({ userId, userEmail, customTheme, userAPIKey }: MagicBellProps) {
  const magicbell = new UserClient({
    apiKey: userAPIKey,
    userEmail: userEmail,
    userExternalId: userId,
  });

  return (
    <div className="magic-bell-container">
      <MagicBell
        stores={stores}
        theme={customTheme}
        BellIcon={<BellIcon />}
        apiKey={userAPIKey}
        userExternalId={userId}
        userEmail={userEmail}
        Badge={Badge}
        bellCounter="unread"
      >
        {props => <NotificationContainer {...props} userClient={magicbell} />}
      </MagicBell>
    </div>
  );
}
