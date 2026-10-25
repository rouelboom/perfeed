/** upcoming — анонс, open — идёт запись, closed — запись закрыта, past — архив. */
export type EventStatus = 'upcoming' | 'open' | 'closed' | 'past';

export function kalugaDate(now = new Date()): string {
  return new Intl.DateTimeFormat('sv-SE', { timeZone: 'Europe/Moscow' }).format(now);
}

export function effectiveStatus(
  event: { status: EventStatus; startDate?: string; endDate?: string },
  today = kalugaDate(),
): EventStatus {
  const lastDate = event.endDate ?? event.startDate;
  return lastDate && lastDate < today ? 'past' : event.status;
}
