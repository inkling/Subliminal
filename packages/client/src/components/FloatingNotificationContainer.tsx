/* eslint-disable @typescript-eslint/no-explicit-any */
import { useNotifications, NotificationList } from '@magicbell/magicbell-react';
import { UserClient } from 'magicbell/user-client';

import React, { useEffect, useState } from 'react';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
import 'react-tabs/style/react-tabs.css';

import '../assets/css/notificationContainer.css';
import NotificationItem from './NotificationItem';

import MarkAllAsRead from '../images/markAllAsRead.svg';
import EmptyBell from '../images/emtpy-bell.svg';
import { NotificationCategory } from '../constants';

type FloatingNotificationInboxProps = {
  launcherRef: React.RefObject<Element>;
  isOpen: boolean;
  toggle: () => void;
  userClient: UserClient;
};

const TabItems = [
  {
    id: 'latest',
    title: 'Latest',
  },
  {
    id: 'feedback',
    title: 'Feedback',
  },
  {
    id: 'comments',
    title: 'Comments',
  },
  {
    id: 'access',
    title: 'Access',
  },
];

const FILTER_OPTIONS = {
  all: {
    value: 'all',
    label: 'All',
  },
  unread: {
    value: 'unread',
    label: 'Unread',
  },
};

// For some reason NotificationStore type is not exported from Magicbell.
// Unfortunately have to use any here
function NotificationContent({ store }: { store: any | null }) {
  if (!store || !store?.notifications || store?.notifications === 0 || store.isEmpty) {
    return (
      <div className="notification-empty">
        <img src={EmptyBell} alt=""></img>
        <p>No New Notifications</p>
      </div>
    );
  }

  return <NotificationList height={400} notifications={store} ListItem={NotificationItem} />;
}

export default function NotificationContainer({ launcherRef, isOpen, toggle, userClient }: FloatingNotificationInboxProps) {
  // StoreId only works when using string.
  const store = useNotifications();
  const feedbackStore = useNotifications('feedback');
  const commentsStore = useNotifications('comments');
  const accessStore = useNotifications('access');

  const [defaultFilter, setDefaultFilter] = useState<{
    value: string;
    label: string;
  }>(FILTER_OPTIONS.all);
  const [selectedTabIndex, setSelectedTabIndex] = useState(0);

  useEffect(() => {
    async function fetchNotifications() {
      const queryParam = defaultFilter.value === 'unread' ? { read: false } : {};
      await store?.fetch(queryParam, { reset: true });
      await feedbackStore?.fetch(queryParam, { reset: true });
      await commentsStore?.fetch(queryParam, { reset: true });
      await accessStore?.fetch(queryParam, { reset: true });
    }

    fetchNotifications();
  }, [defaultFilter]);

  const markTabAsRead = async () => {
    const queryParam = defaultFilter.value === 'unread' ? { read: false } : {};
    switch (selectedTabIndex) {
      case 3:
        await userClient.notifications.markAllRead({
          category: NotificationCategory.ACCESS,
        });
        await accessStore?.fetch(queryParam, { reset: true });
        break;
      case 1:
        await userClient.notifications.markAllRead({
          category: NotificationCategory.FEEDBACK,
        });
        await feedbackStore?.fetch(queryParam, { reset: true });
        break;
      case 2:
        await userClient.notifications.markAllRead({
          category: NotificationCategory.COMMENTS,
        });
        await commentsStore?.fetch(queryParam, { reset: true });
        break;
      default:
        await userClient.notifications.markAllRead();
        break;
    }

    await store?.fetch(queryParam, { reset: true });
  };

  return (
    <>
      {isOpen && <div role="button" onClick={toggle} className="notification-popup-mask"></div>}
      <div ref={launcherRef as any} className="notification-container">
        {/* <button onClick={toggle}>Close</button> */}
        <Tabs defaultIndex={selectedTabIndex} onSelect={index => setSelectedTabIndex(index)}>
          <TabList className="react-tabs__tab-list notification-tabs">
            <div className="notification-tab-items">
              {TabItems.map(tabItem => (
                <Tab key={tabItem.id} className="react-tabs__tab notification-tab-item">
                  {tabItem.title}
                </Tab>
              ))}
            </div>
            <button onClick={markTabAsRead} className="notification__mark-all-as-read">
              <img src={MarkAllAsRead} alt="Mark all notifications as read"></img>
            </button>
          </TabList>
          <div className="notification-content-container">
            <div className="notification-content--top">
              {/* <input type="text" className="notification-searchbox" name="search" placeholder="Search"></input> */}
              <div className="notification-view-filter">
                <p>View: </p>
                <select value={defaultFilter.value} onChange={e => setDefaultFilter((FILTER_OPTIONS as any)[e.target.value])}>
                  {Object.keys(FILTER_OPTIONS).map(key => (
                    <option key={key} value={key}>
                      {(FILTER_OPTIONS as any)[key].label}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            <TabPanel>
              <NotificationContent store={store} />
            </TabPanel>
            <TabPanel>
              <NotificationContent store={feedbackStore} />
            </TabPanel>
            <TabPanel>
              <NotificationContent store={commentsStore} />
            </TabPanel>
            <TabPanel>
              <NotificationContent store={accessStore} />
            </TabPanel>
          </div>
        </Tabs>
      </div>
    </>
  );
}
