import type { ImageMetadata } from 'astro';
import actor3 from '../../content/photos/actor3.jpg';
import foilWide from '../assets/images/foil-wide-selective-color.png';

export interface ArchivedEvent {
  slug: string;
  title: string;
  date: string;
  dateLabel: string;
  venue: string;
  status: string;
  summary: string;
  announcement: {
    opening: string;
    intro: string;
    duration: string;
    roles: readonly (readonly [string, string])[];
    collaboration: string;
    artist: {
      name: string;
      bio: readonly string[];
    };
  };
  images: {
    hero: ImageMetadata;
    artist: ImageMetadata;
  };
  report?: readonly string[];
  gallery?: readonly { image: ImageMetadata; alt: string }[];
}

export const archivedEvents = [
  {
    slug: 'challenge-jam-2026-08-15',
    title: 'Челлендж-джем «Гнозис Текстур»',
    date: '2026-08-15',
    dateLabel: '15 августа 2026',
    venue: 'Билибина 33, 5 этаж',
    status: 'Мероприятие завершено',
    summary: 'Открытая танцевальная встреча-знакомство с ведущими, атмосферой проекта и совместной практикой движения.',
    announcement: {
      opening: 'Это первое открывающее событие лаборатории.',
      intro: 'Умопомрачительная практика танца, перформанса и импровизации. Исследуем восприятие во всех его проявлениях.',
      duration: '2 сета × 40 минут',
      roles: [
        ['Исполнитель', 'Ты танцуешь. Для того, чтобы было любопытнее - тебе дадут задачи для импровизации и только ты решаешь, когда во время твоей практики их активировать.'],
        ['Наблюдатель', 'Твоя позиция наблюдения активная. Ты поддерживаешь вниманием то, что происходит в пространстве. После смены сета роли Исполнителя и Наблюдателя меняются.'],
        ['Зритель', 'Ты поддерживаешь участников эмоциями и присутствием, наслаждаешься процессом. Возможно, в другой раз ты будешь готов поделиться своим танцем.'],
      ],
      collaboration: 'Джем прошёл в коллаборации с музыкантом dub a yaga.',
      artist: {
        name: "Аля · dj 'dub a yaga'",
        bio: [
          '"dub a yaga" - Это классическая рейв-история о танцоре, ставшем диджеем. История погружения в атмосферу андеграундных вечеринок и постепенного перехода от танцпола к пульту. История, где человек, знающий толк в "качающем" звуке и ритме изнутри, начинает сам создавать эту магию для других.',
          'В этот вечер "dub a yaga" порадует нас двумя контрастными сетами — каждый со своей особой атмосферой.\nПервый сет — энергичная смесь современного техно и винтажных ритмов отечественной и зарубежной эстрады. Этот микс непременно зарядит энергией и заставит активно двигаться на танцполе.\nВторой сет в стиле псай‑чилл, напротив, создаст атмосферу спокойствия, умиротворения и ритуальной таинственности— в нём можно расслабиться и насладиться танцем.',
        ],
      },
    },
    images: { hero: foilWide, artist: actor3 },
  },
] as const satisfies readonly ArchivedEvent[];
