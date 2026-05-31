// GreenerHerd — Tasks list
const TasksScreen = ({ nav }) => {
  const { TASKS } = window.GH;
  const [filter, setFilter] = React.useState('today');
  const filtered = TASKS.filter((t) => {
    if (filter === 'today') return t.due === 'today';
    if (filter === 'week') return t.due === 'week' || t.due === 'today';
    if (filter === 'recurring') return t.due === 'recurring';
    return true;
  });
  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title="Tasks" subtitle={`${filtered.length} due · ${TASKS.filter((t) => t.overdue).length} overdue`} rightLabel="+ New" onRightLabel={() => nav.openSheet('newTask')} />
      <div style={{ padding: '12px 16px 0', display: 'flex', gap: 8, overflow: 'auto' }}>
        {[['today', 'Today'], ['week', 'This week'], ['recurring', 'Recurring'], ['all', 'All']].map(([k, l]) =>
        <Chip key={k} active={filter === k} onClick={() => setFilter(k)}>{l}</Chip>
        )}
      </div>

      <div style={{ padding: 16 }}>
        <Card padding={14}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 40, height: 40, borderRadius: 99, background: GH_GREEN_LIGHT, color: GH_GREEN, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="mic" size={18} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>Voice add a task</div>
              <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>EN · AR · UR · FR · transcribed by AI</div>
            </div>
            <Button variant="outline" size="sm" icon="mic" onClick={() => nav.openSheet('voiceTask')}>Hold to talk</Button>
          </div>
        </Card>
      </div>

      <div style={{ padding: '0 16px 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {filtered.map((t) => <TaskRow key={t.id} t={t} nav={nav} />)}
        {filtered.length === 0 && <NotApplicable text="Nothing for this filter — clear sky 🌤" />}
      </div>
    </div>);

};

const TaskRow = ({ t, nav }) => {
  const tones = {
    primary: { bg: GH_GREEN_LIGHT, fg: GH_GREEN },
    warning: { bg: GH_WARN_LIGHT, fg: GH_WARN },
    error: { bg: GH_ERR_LIGHT, fg: GH_ERR },
    neutral: { bg: GH_BORDER, fg: GH_FG_MUTED }
  }[t.tone];
  return (
    <Card padding={14} onClick={() => nav.openSheet('editTask', { task: t })}>
      <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
        <div style={{ width: 36, height: 36, borderRadius: 8, background: tones.bg, color: tones.fg, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <Icon name={t.icon} size={18} />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 8 }}>
            <div style={{ font: '700 14px/1.3 Helvetica, Arial, sans-serif', color: GH_FG }}>{t.title}</div>
            {t.overdue ? <Badge tone="error">Overdue</Badge> : <span style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, whiteSpace: 'nowrap' }}>{t.when}</span>}
          </div>
          <div style={{ font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 4 }}>{t.sub}</div>
        </div>
      </div>
    </Card>);

};

window.TasksScreen = TasksScreen;