/* eslint-disable @typescript-eslint/no-explicit-any */
import { useNotifications, NotificationList } from '@magicbell/magicbell-react';

import React from 'react';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
import 'react-tabs/style/react-tabs.css';

import '../assets/css/notificationContainer.css';
import NotificationItem from './NotificationItem';

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

export default function NotificationContainer({ launcherRef, isOpen, toggle }: FloatingNotificationInboxProps) {
  const store = useNotifications();

  return (
    <>
      {isOpen && <div role="button" onClick={toggle} className="notification-popup-mask"></div>}
      <div ref={launcherRef as any} className="notification-container">
        {/* <button onClick={toggle}>Close</button> */}
        <Tabs>
          <TabList className="react-tabs__tab-list notification-tabs">
            {TabItems.map(tabItem => (
              <Tab key={tabItem.id} className="react-tabs__tab notification-tab-item">
                {tabItem.title}
              </Tab>
            ))}
          </TabList>
          <div className="notification-content-container">
            <div className="notification-content--top">
              <input type="text" className="notification-searchbox" name="search" placeholder="Search"></input>
              {/* TODO: Update to a toggle between All/Unread */}
              <p className="notification-view-filter">View: All</p>
            </div>
            <TabPanel>
              <NotificationList height={400} notifications={store} ListItem={NotificationItem} />
            </TabPanel>
            <TabPanel>
              <h2>Any content 2</h2>
            </TabPanel>
          </div>
        </Tabs>
      </div>
    </>
  );
}
