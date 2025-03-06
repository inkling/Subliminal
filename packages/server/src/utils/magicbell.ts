import { ProjectClient } from 'magicbell/project-client';
import { settings } from './settings';

const magicbell = new ProjectClient({
  apiKey: settings.magicbell.apiKey,
  apiSecret: settings.magicbell.apiSecret,
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
    console.error('Error broadcasting to users', error);
    throw error;
  }
};
