import React from 'react';
import { INotification, IRemoteNotification } from '@magicbell/magicbell-react';
import { NotificationCategory, NotificationCategoryLabel } from '../constants';
import '../assets/css/notificationItem.css';
import { formatLocalDate } from '../utils/dateUtils';

import commentsIcon from '../images/comments-icon.svg';
import feedbackIcon from '../images/feedback-icon.svg';
import accessIcon from '../images/access-icon.svg';

export type ListItemProps = {
  notification: IRemoteNotification;
  onClick?: (notification: INotification) => void | boolean;
};

const CATEGORY_ICON_SRC = {
  [NotificationCategory.COMMENTS]: commentsIcon,
  [NotificationCategory.FEEDBACK]: feedbackIcon,
  [NotificationCategory.ACCESS]: accessIcon,
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
          <img src={CATEGORY_ICON_SRC[notification.category as NotificationCategory]} className={`notification-category-icon`} alt="" />
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
