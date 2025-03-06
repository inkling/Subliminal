// import { broadcastToUsers } from './utils/magicbell';
import { broadcastToUsers } from './utils/magicbell';
// import { settings } from './utils/settings';
const data = [
  // {
  //   title: 'A user has provided feedback. - 2',
  //   category: 'feedback',
  //   subHeading: 'Feedback from [User’s Name] on [Project Name]',
  // },
  {
    title: '[User’s Name] assigned a comment to you.',
    category: 'comments',
    actionUrl: 'https://www.google.com',
    subHeading: 'Comment from [User’s Name] on [Project Name]',
    content:
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla nec purus feugiat, molestie ipsum et, consequat nunc. Nullam non fringilla purus. Nulla facilisi. Nullam sit amet vestibulum tortor. Sed nec purus vel nunc.',
  },
  // {
  //   title: '[User’s Name] has requested that [Name] be added to a project.',
  //   category: 'access',
  //   subHeading: '[User’s Name] invited you to collaborate on a project',
  // },
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
        // {
        //   external_id: '0296e630b50b62b41a5ab9797a04bdbf114',
        // },
      ],
      'actionUrl' in item ? (item.actionUrl as string) : undefined,
      'content' in item ? (item.content as string) : undefined,
      {
        subHeading: item.subHeading,
      },
    );
  }

  console.log('Broadcasted notification');
};

// testBroadcast();

async function main() {
  // console.log(settings);
  await testBroadcast();
  process.exit(0);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
