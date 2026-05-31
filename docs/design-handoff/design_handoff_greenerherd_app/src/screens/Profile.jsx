// GreenerHerd — User profile
const ProfileScreen = ({ nav }) => {
  const { FARM, USERS } = window.GH;
  const me = USERS.find((u) => u.id === 'u1') || USERS[0];

  const [lang, setLang] = React.useState(localStorage.getItem('gh_lang') || 'en');
  const [dark, setDark] = React.useState(localStorage.getItem('gh_dark') === '1');

  React.useEffect(() => {
    localStorage.setItem('gh_lang', lang);
    document.documentElement.setAttribute('dir', lang === 'ar' || lang === 'ur' ? 'rtl' : 'ltr');
  }, [lang]);
  React.useEffect(() => {
    localStorage.setItem('gh_dark', dark ? '1' : '0');
    document.documentElement.setAttribute('data-gh-theme', dark ? 'dark' : 'light');
  }, [dark]);

  const LANGS = [
    { k: 'en', label: 'English',  native: 'English' },
    { k: 'ar', label: 'Arabic',   native: 'العربية' },
    { k: 'ur', label: 'Urdu',     native: 'اردو' },
    { k: 'fr', label: 'French',   native: 'Français' },
  ];
  const currentLangNative = (LANGS.find(l => l.k === lang) || LANGS[0]).native;
  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title="Profile" leftIcon="back" onLeft={() => nav.back()} rightIcon="settings" onRight={() => nav.go('settings')} />

      <div style={{ background: '#fff', padding: '20px 16px 22px', borderBottom: `1px solid ${GH_BORDER}`, display: 'flex', alignItems: 'center', gap: 14 }}>
        <div style={{
          width: 64, height: 64, borderRadius: 99, background: GH_GREEN_LIGHT, color: GH_GREEN,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          font: '700 22px Helvetica, Arial, sans-serif'
        }}>{me.initials}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ font: '700 20px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>{me.name}</div>
          <div style={{ font: '400 13px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>
            {me.role.replace('_', ' ').toLowerCase()} · {FARM.name}
          </div>
          <div style={{ marginTop: 8 }}>
            <Badge tone="primary" dot>Pro plan · annual</Badge>
          </div>
        </div>
      </div>

      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
          <Stat label="Tasks done" value="142" sub="last 30 days" tone="ok" />
          <Stat label="Animals" value="86" sub="under your care" />
          <Stat label="On streak" value="12" sub="days active" icon="flame" />
        </div>

        <SectionHeader title="Account" />
        <Card padding={0}>
          <KVRow k="Email" v="yusuf@greenerherd.sa" />
          <KVRow k="Phone" v="+966 55 234 8821" />
          <KVRow k="Language" v={currentLangNative} />
          <KVRow k="Time zone" v="Asia/Riyadh · UTC+3" last />
        </Card>

        <SectionHeader title="Language" />
        <Card padding={8}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, padding: 6 }}>
            {LANGS.map(l => (
              <button key={l.k} onClick={() => setLang(l.k)} style={{
                border: `1.5px solid ${lang === l.k ? GH_GREEN : GH_BORDER}`,
                background: lang === l.k ? '#F0F7EB' : '#fff',
                borderRadius: 10, padding: '12px 14px', cursor: 'pointer', textAlign: 'left',
                display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8,
              }}>
                <div>
                  <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{l.native}</div>
                  <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{l.label}</div>
                </div>
                {lang === l.k && <Icon name="check" size={16} color={GH_GREEN} />}
              </button>
            ))}
          </div>
        </Card>

        <SectionHeader title="Display" />
        <Card padding={0}>
          <ToggleRow
            icon="settings" label="Dark mode" sub="Easier on the eyes in the barn at dawn"
            on={dark} onChange={setDark} />
          <ToggleRow
            icon="bell" label="Daily summary push" sub="Tomorrow's tasks at 06:00"
            on={true} onChange={() => {}} last />
        </Card>

        <SectionHeader title="People" action="Manage" />
        <Card padding={0}>
          {USERS.map((u, i, arr) => (
            <div key={u.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderBottom: i === arr.length - 1 ? 'none' : `1px solid ${GH_BORDER}` }}>
              <div style={{ width: 36, height: 36, borderRadius: 99, background: GH_GREEN_LIGHT, color: GH_GREEN, display: 'flex', alignItems: 'center', justifyContent: 'center', font: '700 12px Helvetica, Arial, sans-serif' }}>{u.initials}</div>
              <div style={{ flex: 1 }}>
                <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{u.name}</div>
                <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{u.role.replace('_', ' ').toLowerCase()}</div>
              </div>
              <Icon name="chevR" size={16} color={GH_FG_FAINT} />
            </div>
          ))}
        </Card>

        <SectionHeader title="Farm" action="Switch" />
        <Card padding={0}>
          <KVRow k="Farm name" v={FARM.name} />
          <KVRow k="Location" v={FARM.location} />
          <KVRow k="Role" v="Owner" sub="Full access" last />
        </Card>

        <SectionHeader title="Preferences" />
        <Card padding={0}>
          <SettingRow icon="bell" label="Notifications" sub="Daily digest at 06:00" />
          <SettingRow icon="settings" label="App settings" onClick={() => nav.go('settings')} />
          <SettingRow icon="info" label="Help & support" last />
        </Card>

        <Button variant="outline" full>Sign out</Button>
      </div>
    </div>);

};

window.ProfileScreen = ProfileScreen;