import moment from 'moment';

export const formatLocalDate = (date: number) => {
  const localDate = moment(date).local();
  const localToday = moment().local();

  let localDateText;

  switch (true) {
    case localToday.isSame(localDate, 'days'):
      localDateText = 'Today';
      break;
    case moment().local().subtract(1, 'days').isBefore(localDate):
      // Not using "localToday" for this validation since subtract changes
      // the object it gets passed and this would affect the other valitations.
      localDateText = 'Yesterday';
      break;
    case localToday.isSame(localDate, 'weeks'):
      localDateText = localDate.format('dddd');
      break;
    case localToday.isSame(localDate, 'years'):
      localDateText = localDate.format('MMMM D');
      break;
    default:
      localDateText = localDate.format('MMMM D, y');
      break;
  }

  return localDateText;
};
