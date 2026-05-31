// GreenerHerd — Inventory + Help screens
const InventoryScreen = ({ nav }) => {
  const [tab, setTab] = React.useState('feed');
  const feed = [
    { id: 'f1', name: 'Alfalfa hay (premium)',     unit: 'bale', qty: 180, low: false, exp: '14 Aug',  cost: '8.4 SAR/bale' },
    { id: 'f2', name: 'Barley grain',              unit: 'kg',   qty: 240, low: false, exp: '12 Sep',  cost: '0.42 SAR/kg' },
    { id: 'f3', name: 'Wheat bran',                unit: 'kg',   qty: 60,  low: true,  exp: '02 Jul',  cost: '0.31 SAR/kg' },
    { id: 'f4', name: 'Corn silage',               unit: 'kg',   qty: 410, low: false, exp: '20 May',  cost: '0.18 SAR/kg', expSoon: true },
    { id: 'f5', name: 'Mineral block · cattle',    unit: 'block',qty: 12,  low: false, exp: '—',       cost: '34 SAR/block' },
    { id: 'f6', name: 'Soybean meal 44%',          unit: 'kg',   qty: 18,  low: true,  exp: '02 Jun',  cost: '2.95 SAR/kg' },
  ];
  const meds = [
    { id: 'm1', name: 'Penicillin G',              unit: 'vial', qty: 14, low: false, exp: '11 Nov', wd: '3 d' },
    { id: 'm2', name: 'Oxytetracycline',           unit: 'vial', qty: 6,  low: true,  exp: '04 Aug', wd: '7 d' },
    { id: 'm3', name: 'FMD vaccine',               unit: 'dose', qty: 42, low: false, exp: '20 Sep', wd: '0 d' },
    { id: 'm4', name: 'Propylene glycol',          unit: 'L',    qty: 9,  low: false, exp: '14 Dec', wd: '0 d' },
    { id: 'm5', name: 'Ivermectin pour-on',        unit: 'L',    qty: 2,  low: true,  exp: '22 Jul', wd: '14 d' },
  ];
  const items = tab === 'feed' ? feed : meds;
  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title="Inventory" leftIcon="back" onLeft={() => nav.back()} rightLabel="+ Add" onRightLabel={() => {}} />
      <div style={{ background: '#fff', padding: '8px 16px 14px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <II name="inventory" size={40} />
        <div style={{ flex: 1, font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>
          Stock counts, expiry dates and low-stock alerts across feed and medical.
        </div>
      </div>
      <div style={{ padding: '12px 16px 0', display: 'flex', gap: 6, background: 'transparent' }}>
        <div style={{ display: 'flex', gap: 6, background: '#fff', border: `1px solid ${GH_BORDER}`, borderRadius: 12, padding: 4, width: '100%' }}>
          {[{ k: 'feed', l: 'Feed', n: feed.length }, { k: 'meds', l: 'Medical', n: meds.length }].map(t => (
            <button key={t.k} onClick={() => setTab(t.k)} style={{
              flex: 1, background: tab === t.k ? GH_GREEN : 'transparent', border: 'none',
              borderRadius: 8, padding: '8px 6px', cursor: 'pointer',
              color: tab === t.k ? '#fff' : GH_FG,
              font: '700 13px Helvetica, Arial, sans-serif',
            }}>{t.l} · {t.n}</button>
          ))}
        </div>
      </div>

      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 10 }}>
        {items.map(it => (
          <Card key={it.id} padding={14}>
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
              <div style={{
                width: 44, height: 44, borderRadius: 10,
                background: tab === 'feed' ? GH_GREEN_LIGHT : '#FEE2E2',
                display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
              }}>
                <II name={tab === 'feed' ? 'bottle' : 'medication'} size={30} />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
                  <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{it.name}</div>
                  {it.low && <Badge tone="warning">Low stock</Badge>}
                  {it.expSoon && <Badge tone="warning">Expiring soon</Badge>}
                </div>
                <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 4 }}>
                  {tab === 'feed' ? `${it.cost} · expires ${it.exp}` : `Withdrawal ${it.wd} · expires ${it.exp}`}
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ font: '700 18px/1 Helvetica, Arial, sans-serif', color: GH_FG }}>{it.qty}</div>
                <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{it.unit}</div>
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
};
window.InventoryScreen = InventoryScreen;

// --- Help screen --------------------------------------------------
const HelpScreen = ({ nav }) => {
  const topics = [
    { icon: 'check',   label: 'Getting started',   sub: 'Set up your farm, add your first animals' },
    { icon: 'list',    label: 'Animals & groups',  sub: 'Organising the herd · purposes · tags' },
    { icon: 'leaf',    label: 'Nutrition & feed',  sub: 'Reading the gap · feed recommendations' },
    { icon: 'syringe', label: 'Health & vet',      sub: 'Treatments · withdrawal · vaccinations' },
    { icon: 'baby',    label: 'Breeding cycles',   sub: 'Heat detection · AI · pregnancy tracking' },
    { icon: 'milk',    label: 'Milking & yield',   sub: 'Recording milk · reading dips' },
    { icon: 'wallet',  label: 'Finance & reports', sub: 'Logging income/expense · PDF exports' },
    { icon: 'bell',    label: 'Alerts & tasks',    sub: 'Auto vs manual · reminders · recurrence' },
  ];
  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title="Help & support" leftIcon="back" onLeft={() => nav.back()} />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>
        <Card padding={16} style={{ background: GH_GREEN_LIGHT, borderColor: GH_GREEN }}>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <div style={{
              width: 40, height: 40, borderRadius: 10, background: GH_GREEN, color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
            }}><Icon name="help" size={20} /></div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_GREEN }}>Need a hand?</div>
              <div style={{ font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: GH_GREEN, marginTop: 2 }}>
                Chat with support · weekdays 8:00–18:00 AST
              </div>
            </div>
            <Button size="sm" variant="primary">Chat</Button>
          </div>
        </Card>

        <SectionHeader title="Browse topics" />
        <Card padding={0}>
          {topics.map((t, i) => (
            <div key={t.label} style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '14px 16px',
              borderBottom: i === topics.length - 1 ? 'none' : `1px solid ${GH_BORDER}`,
              cursor: 'pointer',
            }}>
              <div style={{
                width: 32, height: 32, borderRadius: 8, background: GH_GREEN_LIGHT, color: GH_GREEN,
                display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
              }}><Icon name={t.icon} size={16} /></div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{t.label}</div>
                <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{t.sub}</div>
              </div>
              <Icon name="chevR" size={16} color={GH_FG_FAINT} />
            </div>
          ))}
        </Card>

        <SectionHeader title="Reach the team" />
        <Card padding={0}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderBottom: `1px solid ${GH_BORDER}` }}>
            <Icon name="bell" size={18} color={GH_FG_MUTED} />
            <div style={{ flex: 1 }}>
              <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>Email support</div>
              <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>support@greenerherd.sa</div>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px' }}>
            <Icon name="info" size={18} color={GH_FG_MUTED} />
            <div style={{ flex: 1 }}>
              <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>App version</div>
              <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>2.4.0 · build 1428</div>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
};
window.HelpScreen = HelpScreen;
