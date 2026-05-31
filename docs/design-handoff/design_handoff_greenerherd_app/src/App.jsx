// GreenerHerd — App shell with simple state-based router

const App = () => {
  // Tweaks
  const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
    "language": "EN",
    "darkChrome": false,
    "accent": "#3B5A2A",
    "showFAB": true
  } /*EDITMODE-END*/;
  const [tweaks, setTweak] = useTweaks(TWEAK_DEFAULTS);

  // Apply accent dynamically
  React.useEffect(() => {
    if (tweaks.accent !== '#3B5A2A') {
      document.documentElement.style.setProperty('--gh-primary-override', tweaks.accent);
    }
  }, [tweaks.accent]);

  // Routing — simple stack
  const [stack, setStack] = React.useState([{ route: 'home', params: {} }]);
  const [tab, setTab] = React.useState('home');
  const [sheet, setSheet] = React.useState({ kind: null, params: {} });

  const current = stack[stack.length - 1];

  const nav = {
    go: (route, params = {}) => {
      // Tab-level routes are root; others are pushed
      if (['home', 'animals', 'tasks', 'finance', 'reports'].includes(route)) {
        setTab(route);
        setStack([{ route, params }]);
      } else {
        setStack((s) => [...s, { route, params }]);
      }
    },
    back: () => setStack((s) => s.length > 1 ? s.slice(0, -1) : s),
    openSheet: (kind, params = {}) => setSheet({ kind, params }),
    closeSheet: () => setSheet({ kind: null, params: {} })
  };

  const onTabChange = (id) => {
    setTab(id);
    setStack([{ route: id, params: {} }]);
  };

  const renderScreen = () => {
    switch (current.route) {
      case 'home':return <Dashboard nav={(r, p) => nav.go(r, p)} />;
      case 'settings':return <SettingsScreen nav={nav} />;
      case 'profile':return <ProfileScreen nav={nav} />;
      case 'animals':return <AnimalsList nav={nav} params={current.params} />;
      case 'allAnimals':return <AnimalsList nav={nav} params={current.params} />;
      case 'animal':return <AnimalProfile nav={nav} params={current.params} />;
      case 'groups':return <GroupsList nav={nav} />;
      case 'group':return <GroupDetail nav={nav} params={current.params} />;
      case 'tasks':return <TasksScreen nav={nav} />;
      case 'finance':return <FinanceScreen nav={nav} />;
      case 'reports':return <ReportsScreen nav={nav} />;
      case 'report':return <ReportDetailScreen nav={nav} params={current.params} />;
      case 'feedRec':return <FeedRecommendations nav={nav} params={current.params} />;
      case 'inventory':return <InventoryScreen nav={nav} />;
      case 'help':return <HelpScreen nav={nav} />;
      default:return <Dashboard nav={(r, p) => nav.go(r, p)} />;
    }
  };

  // Map route → tab for highlight
  const routeToTab = { home: 'home', profile: 'home', settings: 'home', inventory: 'home', help: 'home', animals: 'animals', allAnimals: 'animals', animal: 'animals', groups: 'animals', group: 'animals', tasks: 'tasks', finance: 'finance', reports: 'reports', report: 'reports' };
  const activeTab = routeToTab[current.route] || tab;

  // Listen for ⓘ tweaks: language toggles RTL
  const dir = tweaks.language === 'AR' || tweaks.language === 'UR' ? 'rtl' : 'ltr';

  return (
    <>
      <div dir={dir} style={{ display: 'flex', flexDirection: 'column', height: '100%', background: GH_GREY_BG, position: 'relative' }}>
        <div style={{ flex: 1, overflowY: 'auto', position: 'relative', paddingBottom: 90 }}>
          {renderScreen()}
        </div>

        {/* Floating action button */}
        {tweaks.showFAB && current.route !== 'animal' &&
        <button onClick={() => {
          if (current.route === 'tasks') nav.openSheet('newTask');else
          if (current.route === 'animals' || current.route === 'home') nav.openSheet('addChooser');else
          if (current.route === 'finance') nav.openSheet('addFinance');else
          if (current.route === 'group' && current.params.tab === 'milking') nav.openSheet('recordMilk', { group: window.GH.GROUPS.find((g) => g.id === current.params.id) });else
          nav.openSheet('addChooser');
        }} style={{
          position: 'absolute', right: 16, bottom: 96, width: 52, height: 52, borderRadius: 99,
          background: GH_GREEN, color: '#fff', border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 8px 20px rgba(59,90,42,0.35), 0 2px 6px rgba(0,0,0,0.10)', zIndex: 20
        }}>
            <Icon name="plus" size={24} />
          </button>
        }

        <TabBar active={activeTab} onChange={onTabChange} />

        {/* Sheets */}
        <NewTaskSheet open={sheet.kind === 'newTask'} onClose={nav.closeSheet} params={sheet.params} />
        <VoiceTaskSheet open={sheet.kind === 'voiceTask'} onClose={nav.closeSheet} />
        <RecordMilkSheet open={sheet.kind === 'recordMilk'} onClose={nav.closeSheet} params={sheet.params} />
        <RecordFeedingSheet open={sheet.kind === 'recordFeeding'} onClose={nav.closeSheet} params={sheet.params} />
        <RecordVaccinationSheet open={sheet.kind === 'recordVaccination'} onClose={nav.closeSheet} params={sheet.params} />
        <RecordHealthSheet
          open={sheet.kind === 'recordHealth'}
          onClose={() => {
            if (sheet.params?.onClose) sheet.params.onClose();
            else nav.closeSheet();
          }}
          params={sheet.params} />
        <AddAnimalSheet open={sheet.kind === 'addAnimal'} onClose={nav.closeSheet} />
        <EditAnimalSheet open={sheet.kind === 'editAnimal'} onClose={nav.closeSheet} params={sheet.params} />
        <EditTaskSheet open={sheet.kind === 'editTask'} onClose={nav.closeSheet} params={sheet.params} />
        <AddGroupSheet open={sheet.kind === 'addGroup'} onClose={nav.closeSheet} />
        <AddChooserSheet
          open={sheet.kind === 'addChooser'} onClose={nav.closeSheet}
          onPickAnimal={() => nav.openSheet('addAnimal')}
          onPickGroup={() => nav.openSheet('addGroup')} />
        <MoveAnimalSheet open={sheet.kind === 'moveAnimal'} onClose={nav.closeSheet} params={sheet.params} />
        <AddFinanceEntrySheet open={sheet.kind === 'addFinance'} onClose={nav.closeSheet} />
        <EditPricesSheet open={sheet.kind === 'editPrices'} onClose={nav.closeSheet} params={sheet.params} />
        <StatusChangeSheet open={sheet.kind === 'statusChange'} onClose={nav.closeSheet} params={sheet.params} />
      </div>

      {/* Tweaks panel */}
      <TweaksPanel title="Tweaks">
        <TweakSection title="Locale">
          <TweakRadio label="Language" value={tweaks.language} onChange={(v) => setTweak('language', v)}
          options={[{ value: 'EN', label: 'English' }, { value: 'AR', label: 'العربية' }, { value: 'UR', label: 'اردو' }, { value: 'FR', label: 'FR' }]} />
        </TweakSection>
        <TweakSection title="Brand">
          <TweakColor label="Accent" value={tweaks.accent} onChange={(v) => setTweak('accent', v)}
          options={['#3B5A2A', '#1A107A', '#5C8A3F', '#0F766E']} />
        </TweakSection>
        <TweakSection title="UI">
          <TweakToggle label="Floating action button" value={tweaks.showFAB} onChange={(v) => setTweak('showFAB', v)} />
        </TweakSection>
      </TweaksPanel>
    </>);

};

// Mount inside the iOS frame
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <div style={{
    minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
    background: '#E9E7E2', padding: '24px 16px'
  }}>
    <IOSDevice width={402} height={874}>
      <div style={{ height: '100%', paddingTop: 50, boxSizing: 'border-box', display: 'flex', flexDirection: 'column' }}>
        <App />
      </div>
    </IOSDevice>
  </div>
);