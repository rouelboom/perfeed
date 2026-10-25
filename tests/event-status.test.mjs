import assert from 'node:assert/strict';
import { test } from 'node:test';
import { effectiveStatus, kalugaDate } from '../src/lib/event-status.ts';

test('открытый класс остаётся актуальным в день встречи и уходит в архив на следующий день', () => {
  const event = { status: 'open', startDate: '2026-11-01' };
  assert.equal(effectiveStatus(event, '2026-10-31'), 'open');
  assert.equal(effectiveStatus(event, '2026-11-01'), 'open');
  assert.equal(effectiveStatus(event, '2026-11-02'), 'past');
});

test('регулярная группа актуальна до последней встречи включительно', () => {
  const event = { status: 'open', startDate: '2026-11-03', endDate: '2026-11-28' };
  assert.equal(effectiveStatus(event, '2026-11-04'), 'open');
  assert.equal(effectiveStatus(event, '2026-11-28'), 'open');
  assert.equal(effectiveStatus(event, '2026-11-29'), 'past');
});

test('явные статусы и анонс без даты сохраняются', () => {
  assert.equal(effectiveStatus({ status: 'upcoming' }, '2026-12-01'), 'upcoming');
  assert.equal(effectiveStatus({ status: 'closed', startDate: '2026-11-01' }, '2026-10-25'), 'closed');
  assert.equal(effectiveStatus({ status: 'past', startDate: '2026-11-01' }, '2026-10-25'), 'past');
});

test('граница календарного дня учитывает часовой пояс Калуги', () => {
  assert.equal(kalugaDate(new Date('2026-11-01T20:59:59Z')), '2026-11-01');
  assert.equal(kalugaDate(new Date('2026-11-01T21:00:00Z')), '2026-11-02');
});
