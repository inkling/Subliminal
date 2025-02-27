import { broadcastToUsers } from './utils/magicbell';

const data = [
  {
    title: 'A user has provided feedback.',
    category: 'feedback',
    subHeading: 'Feedback from [User’s Name] on [Project Name]',
  },
  {
    title: '[User’s Name] assigned a comment to you.',
    category: 'comments',
    subHeading: 'Comment from [User’s Name] on [Project Name]',
    content:
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla nec purus feugiat, molestie ipsum et, consequat nunc. Nullam non fringilla purus. Nulla facilisi. Nullam sit amet vestibulum tortor. Sed nec purus vel nunc.',
  },
  {
    title: '[User’s Name] has requested that [Name] be added to a project.',
    category: 'access',
    subHeading: '[User’s Name] invited you to collaborate on a project',
  },
];

const testBroadcast = async () => {
  for (const item of data) {
    await broadcastToUsers(
      item.title,
      item.category,
      [
        {
          external_id: 'test-user-id',
        },
      ],
      undefined,
      item.content,
      {
        subHeading: item.subHeading,
      },
    );
  }

  console.log('Broadcasted notification');

  process.exit(0);
};

testBroadcast();
