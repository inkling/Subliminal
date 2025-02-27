import { ProjectClient } from 'magicbell/project-client';
import logger from './logger';

const magicbell = new ProjectClient({
  apiKey: '93e3b766f152c9a44a4d3575d765cee62326eee8',
  //   TODO: Replace with fetch from Secrets manager
  apiSecret: 'nya9pFS8lnxD5P62h+I1OAnX2nqzSY2/leaJIKFK',
});

export type Recipient = {
  [x: string]: unknown;
  topic?:
    | {
        [x: string]: unknown;
      }
    | undefined;
  matches?: string | undefined;
  email?: string | null | undefined;
  external_id?: string | null | undefined;
};

export const broadcastToUsers = async (
  title: string,
  category: string,
  recipients: Recipient[],
  actionUrl?: string,
  content?: string,
  customAttr?: Record<string, string>,
) => {
  try {
    const notifications = await magicbell.broadcasts.create({
      title,
      content,
      category,
      action_url: actionUrl,
      recipients,
      custom_attributes: customAttr,
    });

    return notifications;
  } catch (error) {
    logger.error('Error broadcasting to users', error);
    throw error;
  }
};
