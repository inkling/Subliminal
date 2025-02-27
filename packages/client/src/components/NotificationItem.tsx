import React from 'react';
import { INotification, IRemoteNotification } from '@magicbell/magicbell-react';
import { NotificationCategory, NotificationCategoryLabel } from '../constants';
import '../assets/css/notificationItem.css';
import { formatLocalDate } from '../utils/dateUtils';

export type ListItemProps = {
  notification: IRemoteNotification;
  onClick?: (notification: INotification) => void | boolean;
};

const CATEGORY_ICON_CLASSES = {
  [NotificationCategory.COMMENTS]: 'notification-category-comments',
  [NotificationCategory.FEEDBACK]: 'notification-category-feedback',
  [NotificationCategory.ACCESS]: 'notification-category-access',
};

const extractSubHeading = (notification: IRemoteNotification): string | null => {
  const customAttr = notification.customAttributes;
  if (typeof customAttr === 'object' && customAttr !== null) {
    if ('subHeading' in customAttr) {
      return customAttr.subHeading as string;
    }
  }

  return null;
};

export default function NotificationItem({ notification }: ListItemProps) {
  const categoryIconClass = notification.category ? CATEGORY_ICON_CLASSES[notification.category as NotificationCategory] : '';

  const subHeading = extractSubHeading(notification);

  return (
    <div className="notification-item-container">
      <div className="notification-item-status">
        {notification.readAt === null ? <div className="notification-read-status"></div> : null}
      </div>
      <div className="notification-item-content-wrapper">
        <div className="notification-item-header">
          <p className="notification-category">
            {notification.category && notification.category in NotificationCategoryLabel
              ? NotificationCategoryLabel[notification.category as NotificationCategory]
              : ''}
          </p>
          <p>{notification.sentAt ? formatLocalDate(notification.sentAt * 1000) : ''}</p>
        </div>
        <div className="notification-item-body">
          <div className={`notification-category-icon ${categoryIconClass}`}></div>
          <div className="notification-item-content">
            <p>{notification.title}</p>
            {subHeading && <p className="notification-item-subheading">{subHeading}</p>}
            {notification.content && <p className="notification-item-description">{notification.content}</p>}
          </div>
        </div>
      </div>
    </div>
  );
}
