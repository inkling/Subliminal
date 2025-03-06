/* eslint-disable @typescript-eslint/no-explicit-any */
import { useNotifications, NotificationList } from '@magicbell/magicbell-react';

import React, { useEffect, useState } from 'react';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
import 'react-tabs/style/react-tabs.css';

import '../assets/css/notificationContainer.css';
import NotificationItem from './NotificationItem';

import MarkAllAsRead from '../images/markAllAsRead.svg';

type FloatingNotificationInboxProps = {
  launcherRef: React.RefObject<Element>;
  isOpen: boolean;
  toggle: () => void;
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

export default function NotificationContainer({ launcherRef, isOpen, toggle }: FloatingNotificationInboxProps) {
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

  async function markAllAsRead() {
    await store?.markAllAsRead();
  }

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
            <button onClick={markAllAsRead} className="notification__mark-all-as-read">
              <img src={MarkAllAsRead} alt="Mark all notifications as read"></img>
            </button>
          </TabList>
          <div className="notification-content-container">
            <div className="notification-content--top">
              <input type="text" className="notification-searchbox" name="search" placeholder="Search"></input>
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
            <TabPanel>{store && <NotificationList height={400} notifications={store} ListItem={NotificationItem} />}</TabPanel>
            <TabPanel>
              {feedbackStore && <NotificationList height={400} notifications={feedbackStore} ListItem={NotificationItem} />}
            </TabPanel>
            <TabPanel>
              {commentsStore && <NotificationList height={400} notifications={commentsStore} ListItem={NotificationItem} />}
            </TabPanel>
            <TabPanel>{accessStore && <NotificationList height={400} notifications={accessStore} ListItem={NotificationItem} />}</TabPanel>
          </div>
        </Tabs>
      </div>
    </>
  );
}
