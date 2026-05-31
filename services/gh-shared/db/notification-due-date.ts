/**
 * Parses catalogue `due_date_rule` strings into concrete due dates.
 */
export function computeDueDate(
  rule: string | null | undefined,
  asOf: Date,
  options: { anchorDate?: Date } = {},
): Date {
  const base = options.anchorDate ?? asOf;
  const due = new Date(base);
  due.setUTCHours(0, 0, 0, 0);

  if (!rule?.trim()) {
    due.setDate(due.getDate() + 1);
    return due;
  }

  const text = rule.trim().toLowerCase();

  if (text === 'next day' || text === 'same day') {
    due.setUTCDate(due.getUTCDate() + (text === 'same day' ? 0 : 1));
    return due;
  }

  const daysAfter = text.match(/(\d+)\s*days?\s+after/);
  if (daysAfter) {
    due.setUTCDate(due.getUTCDate() + Number(daysAfter[1]));
    return due;
  }

  const daysBefore = text.match(/(\d+)\s*days?\s+before/);
  if (daysBefore && options.anchorDate) {
    due.setTime(options.anchorDate.getTime());
    due.setUTCDate(due.getUTCDate() - Number(daysBefore[1]));
    return due;
  }

  const weeksAfter = text.match(/(\d+)\s*weeks?\s+after/);
  if (weeksAfter) {
    due.setDate(due.getDate() + Number(weeksAfter[1]) * 7);
    return due;
  }

  const weekBefore = text.match(/(\d+)\s*weeks?\s+before/);
  if (weekBefore && options.anchorDate) {
    due.setTime(options.anchorDate.getTime());
    due.setUTCDate(due.getUTCDate() - Number(weekBefore[1]) * 7);
    return due;
  }

  const hoursAfter = text.match(/(\d+)\s*hours?\s+after/);
  if (hoursAfter) {
    const out = new Date(asOf);
    out.setHours(out.getHours() + Number(hoursAfter[1]));
    return out;
  }

  // Default: tomorrow
  due.setUTCDate(due.getUTCDate() + 1);
  return due;
}

export function formatDueDateIso(date: Date): string {
  return date.toISOString().slice(0, 10);
}
