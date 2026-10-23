export const site = {
  name: 'unlimited position / запредельная позиция',
  title: 'Unlimited Position / Запредельная позиция — современный танец в Калуге',
  description:
    'Практика современного танца Анастасии Сенокосовой в Калуге: импровизация, регулярные группы, открытые классы, показы и события.',
  city: 'калуга',
  nav: [
    ['практика', '/#practice'],
    ['программа', '/#program'],
    ['об авторе', '/#about'],
    ['контакты', '/#contact'],
  ],
  /** Ссылки на Telegram, Instagram и почту появятся, когда их передаст автор практики. */
  contacts: [] as readonly { label: string; href: string }[],
} as const;
