// GreenerHerd — Settings (alerts & tasks)
const SettingsScreen = ({ nav }) => {
  const { USERS, TASKS } = window.GH;
  const todayTasks = TASKS.filter(t => t.due === 'today');

  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title="Alerts & Tasks" leftIcon="back" onLeft={() => nav.back()} />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>

        <SectionHeader title="Notifications" />
        <Card padding={0}>
          <NotifRow tone="error"  icon="overdue" title="Bessie #0421 · birth alert" sub="Calving signs · check now" />
          <NotifRow tone="warning" icon="syringe" title="FMD booster · 14 head" sub="Goats Maintenance B · Fri 14:00" />
          <NotifRow tone="primary" icon="leaf" title="Energy gap · Milking A" sub="41% below target · open feed plan" />
          <NotifRow tone="primary" icon="check" title="Daily milk recorded" sub="406.4 L · 22 cattle · 22.1 L avg" last />
        </Card>

        <SectionHeader title={`Tasks · ${todayTasks.length}`} action="See all" onAction={() => nav.go('tasks')} />
        <Card padding={0}>
          {todayTasks.map((t, i) => (
            <NotifRow
              key={t.id}
              tone={t.tone === 'neutral' ? 'primary' : t.tone}
              icon={t.icon}
              title={t.title}
              sub={t.overdue ? `Overdue · ${t.sub}` : `${t.when} · ${t.sub}`}
              last={i === todayTasks.length - 1}
            />
          ))}
          {todayTasks.length === 0 && (
            <div style={{ padding: '24px 16px', textAlign: 'center', font: '400 13px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>
              Nothing due today — clear sky 🌤
            </div>
          )}
        </Card>
      </div>
    </div>
  );
};

const ToggleRow = ({ icon, label, sub, on, onChange, last }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderBottom: last ? 'none' : `1px solid ${GH_BORDER}` }}>
    <Icon name={icon} size={18} color={GH_FG_MUTED} />
    <div style={{ flex: 1 }}>
      <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{label}</div>
      {sub && <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{sub}</div>}
    </div>
    <button onClick={() => onChange(!on)} style={{
      width: 44, height: 26, borderRadius: 99, padding: 2,
      background: on ? GH_GREEN : GH_BORDER, border: 'none', cursor: 'pointer',
      display: 'flex', alignItems: 'center', justifyContent: on ? 'flex-end' : 'flex-start',
      transition: 'background 0.2s',
    }}>
      <span style={{ width: 22, height: 22, borderRadius: 99, background: '#fff', boxShadow: '0 1px 2px rgba(0,0,0,0.2)', transition: 'all 0.2s' }} />
    </button>
  </div>
);

const NotifRow = ({ tone, icon, title, sub, last }) => {
  const tones = { primary: [GH_GREEN_LIGHT, GH_GREEN], warning: [GH_WARN_LIGHT, GH_WARN], error: [GH_ERR_LIGHT, GH_ERR] }[tone];
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderBottom: last ? 'none' : `1px solid ${GH_BORDER}` }}>
      <div style={{ width: 36, height: 36, borderRadius: 8, background: tones[0], color: tones[1], display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name={icon} size={18} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{title}</div>
        <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{sub}</div>
      </div>
      <Icon name="chevR" size={16} color={GH_FG_FAINT} />
    </div>
  );
};

const SettingRow = ({ icon, label, sub, onClick, last }) => (
  <div onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderBottom: last ? 'none' : `1px solid ${GH_BORDER}`, cursor: onClick ? 'pointer' : 'default' }}>
    <Icon name={icon} size={18} color={GH_FG_MUTED} />
    <div style={{ flex: 1 }}>
      <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{label}</div>
      {sub && <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{sub}</div>}
    </div>
    <Icon name="chevR" size={16} color={GH_FG_FAINT} />
  </div>
);

window.SettingsScreen = SettingsScreen;
window.ToggleRow = ToggleRow;
