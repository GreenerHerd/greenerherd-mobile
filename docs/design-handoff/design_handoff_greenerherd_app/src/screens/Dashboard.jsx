// GreenerHerd — Dashboard
const Dashboard = ({ nav }) => {
  const { FARM, ANIMALS, TASKS, FINANCE, GROUPS, SPECIES_LABEL, GROUP_KPI } = window.GH;
  const [species, setSpecies] = React.useState('all');
  const [menuOpen, setMenuOpen] = React.useState(false);
  const counts = {
    all: ANIMALS.length,
    cattle: ANIMALS.filter((a) => a.species === 'cattle').length,
    goat: ANIMALS.filter((a) => a.species === 'goat').length,
    sheep: ANIMALS.filter((a) => a.species === 'sheep').length
  };
  const tagCount = (t) => ANIMALS.filter((a) => a.tags.includes(t) && (species === 'all' || a.species === species)).length;
  const visibleTotal = species === 'all' ? counts.all : counts[species];
  const visibleAnimals = species === 'all' ? ANIMALS : ANIMALS.filter((a) => a.species === species);
  const visibleGroups = species === 'all' ? GROUPS : GROUPS.filter((g) => g.species === species);

  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <div style={{
        background: '#fff', padding: '14px 16px 18px', borderBottom: `1px solid ${GH_BORDER}`,
        display: 'flex', alignItems: 'center', gap: 12, position: 'relative', zIndex: 30
      }}>
        <button onClick={() => setMenuOpen(true)} aria-label="Menu" style={{
          background: 'none', border: 'none', padding: 6, cursor: 'pointer', color: GH_FG,
          display: 'flex', alignItems: 'center', justifyContent: 'center', marginLeft: -6
        }}>
          <Icon name="menu" size={24} />
        </button>
        <Logo />
        <div style={{ flex: 1 }} />
        <button onClick={() => nav('settings')} style={{ background: 'none', border: 'none', padding: 6, cursor: 'pointer', color: GH_FG }}>
          <Icon name="bell" size={22} />
        </button>
        <button onClick={() => nav('profile')} style={{ width: 32, height: 32, borderRadius: 99, background: GH_GREEN_LIGHT, color: GH_GREEN, display: 'flex', alignItems: 'center', justifyContent: 'center', font: '700 12px Helvetica, Arial, sans-serif', border: 'none', cursor: 'pointer', padding: 0 }}>YA</button>
      </div>

      <BurgerMenu open={menuOpen} onClose={() => setMenuOpen(false)} nav={nav} />

      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 18 }}>

        {/* Greeting */}
        <div>
          <div style={{ font: '400 13px/1.2 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>Friday, 8 May · {FARM.location}</div>
          <h1 style={{ font: '700 26px/1.2 Helvetica, Arial, sans-serif', color: GH_FG, margin: '4px 0 0' }}>Good morning, Yusuf</h1>
          <div style={{ font: '400 13px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 4 }}>
            <strong style={{ color: GH_FG, fontWeight: 700 }}>{FARM.name}</strong> · {visibleTotal} active animals
          </div>
        </div>

        {/* Species filter */}
        <div style={{ display: 'flex', gap: 8, overflow: 'auto', margin: '0 -16px', padding: '0 16px' }}>
          {[['all', 'All species'], ['cattle', 'Cattle'], ['goat', 'Goats'], ['sheep', 'Sheep']].map(([k, l]) =>
          <Chip key={k} active={species === k} onClick={() => setSpecies(k)}>
              {l} <span style={{ opacity: 0.7, marginLeft: 4 }}>{counts[k]}</span>
            </Chip>
          )}
        </div>

        {/* Status grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Stat label="Pregnant" value={tagCount('PREGNANT')} sub={species === 'all' ? '3 cattle · 11 goats' : `${species}`} icon="heart" onClick={() => nav('animals', { tag: 'PREGNANT', species })} />
          <Stat label="Ready to breed" value={tagCount('READY_TO_BREED')} sub="across 4 groups" icon="check" onClick={() => nav('animals', { tag: 'READY_TO_BREED', species })} />
          <Stat label="Sick" value={tagCount('SICK')} sub="under treatment" tone="err" icon="syringe" onClick={() => nav('animals', { tag: 'SICK', species })} />
          <Stat label="Cull flagged" value={tagCount('CULL')} sub="reviewable" tone="warn" illustrated="tag-id" onClick={() => nav('animals', { tag: 'CULL', species })} />
        </div>

        {/* Species-specific: demographics + groups with KPI */}
        {species !== 'all' && <DemographicsCard animals={visibleAnimals} species={species} />}
        {species !== 'all' && <GroupsKPIList groups={visibleGroups} kpis={GROUP_KPI} nav={nav} />}

        {/* Upcoming critical events */}
        <Card padding={16}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
            <h3 style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Upcoming · 7 days</h3>
            <Badge tone="warning">12</Badge>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <EventRow icon="baby" title="3 births due" sub="Bessie · Layla · Khulud" tone="primary" onClick={() => nav('animal', { id: 'a1' })} />
            <EventRow icon="syringe" title="FMD booster · 14 head" sub="Goats: Maintenance B" tone="warning" onClick={() => nav('group', { id: 'g5' })} />
            <EventRow icon="check" title="Pregnancy scan · 6 cattle" sub="Cattle: Breeding" tone="primary" onClick={() => nav('group', { id: 'g2' })} />
          </div>
        </Card>

        {/* Tasks due */}
        <Card padding={16} onClick={() => nav('tasks')}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
            <h3 style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Tasks due</h3>
            <span style={{ font: '700 13px Helvetica, Arial, sans-serif', color: GH_GREEN }}>View all →</span>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
            <MiniStat n={1} label="Overdue" color={GH_ERR} />
            <MiniStat n={3} label="Today" color={GH_WARN} />
            <MiniStat n={4} label="This week" color={GH_GREEN} />
          </div>
        </Card>

        {/* Livestock value — only on All species (cost split per species is unreliable) */}
        {species === 'all' &&
        <Card padding={16}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h3 style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG, margin: '0 0 6px' }}>Livestock value</h3>
              <div style={{ font: '700 28px/1 Helvetica, Arial, sans-serif', color: GH_FG }}>SAR {FINANCE.livestockValue.toLocaleString()}</div>
              <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 4 }}>
                Estimated · weight × meat price + 3-mo milk
              </div>
            </div>
            <SpeciesAvatar species="cattle" size={56} light />
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 8, marginTop: 14 }}>
            <ValueRow species="cattle" value="312k" />
            <ValueRow species="goat" value="64k" />
            <ValueRow species="sheep" value="36k" />
          </div>
        </Card>
        }

        {/* AI nudge */}
        <InfoBanner tone="primary" icon="leaf"
        title="Greener Herd suggests"
        body="Energy gap detected on Milking A — 41% below target. Add 14 kg barley concentrate to morning mix."
        action="Open feed plan" onAction={() => nav('feedRec', { id: 'g1' })} />

      </div>
    </div>);

};

const EventRow = ({ icon, title, sub, tone, onClick }) => {
  const fg = tone === 'warning' ? GH_WARN : GH_GREEN;
  const bg = tone === 'warning' ? GH_WARN_LIGHT : GH_GREEN_LIGHT;
  return (
    <div onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer' }}>
      <div style={{ width: 36, height: 36, borderRadius: 8, background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center', color: fg }}>
        <Icon name={icon} size={18} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ font: '700 14px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>{title}</div>
        <div style={{ font: '400 12px/1.2 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{sub}</div>
      </div>
      <Icon name="chevR" size={18} color={GH_FG_FAINT} />
    </div>);

};

const MiniStat = ({ n, label, color }) =>
<div style={{ padding: 12, background: GH_GREY_BG, borderRadius: 8 }}>
    <div style={{ font: '700 28px/1 Helvetica, Arial, sans-serif', color }}>{n}</div>
    <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{label}</div>
  </div>;


const Stack = ({ k, v, c }) =>
<div>
    <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{k}</div>
    <div style={{ font: '700 13px Helvetica, Arial, sans-serif', color: c, marginTop: 2 }}>{v}</div>
  </div>;


const MiniBars = ({ data }) => {
  const max = Math.max(...data.map((d) => Math.max(d.inc, d.exp)));
  return (
    <div style={{ display: 'flex', gap: 14, alignItems: 'flex-end', height: 100, padding: '0 4px' }}>
      {data.map((mo) =>
      <div key={mo.m} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
          <div style={{ display: 'flex', gap: 4, alignItems: 'flex-end', height: 80 }}>
            <div title="Income" style={{ width: 16, background: GH_GREEN, height: `${mo.inc / max * 80}px`, borderRadius: '4px 4px 0 0' }} />
            <div title="Expense" style={{ width: 16, background: '#80A5F9', height: `${mo.exp / max * 80}px`, borderRadius: '4px 4px 0 0' }} />
          </div>
          <div style={{ font: '700 11px Roboto, Helvetica, sans-serif', color: GH_FG_MUTED }}>{mo.m}</div>
        </div>
      )}
    </div>);

};

const ValueRow = ({ species, value }) =>
<div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: 8, background: GH_GREY_BG, borderRadius: 8 }}>
    <SpeciesAvatar species={species} size={28} light />
    <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{value}</div>
  </div>;


// --- Demographics card (species tab) -----------------------------
const DemographicsCard = ({ animals, species }) => {
  const total = animals.length || 1;
  const fem = animals.filter((a) => a.sex === 'F').length;
  const mal = animals.filter((a) => a.sex === 'M').length;
  // Breeds
  const breeds = animals.reduce((m, a) => (m[a.breed] = (m[a.breed] || 0) + 1, m), {});
  const breedList = Object.entries(breeds).sort((a, b) => b[1] - a[1]);
  // Age buckets
  const ageBuckets = { '0–6m': 0, '6–12m': 0, '1–2y': 0, '2–5y': 0, '5y+': 0 };
  animals.forEach((a) => {
    const m = (a.age || '').match(/(\d+)y\s*(\d+)?/);
    const mm = (a.age || '').match(/^(\d+)m/);
    let months = 0;
    if (m) months = parseInt(m[1]) * 12 + (parseInt(m[2]) || 0);else
    if (mm) months = parseInt(mm[1]);
    if (months <= 6) ageBuckets['0–6m']++;else
    if (months <= 12) ageBuckets['6–12m']++;else
    if (months <= 24) ageBuckets['1–2y']++;else
    if (months <= 60) ageBuckets['2–5y']++;else
    ageBuckets['5y+']++;
  });
  const SPLABEL = { cattle: 'Cattle', goat: 'Goat', sheep: 'Sheep' };
  return (
    <Card padding={16}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 12 }}>
        <h3 style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>{SPLABEL[species]} demographics</h3>
        <span style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{animals.length} loaded</span>
      </div>

      {/* Sex split bar */}
      <div>
        <div style={{ display: 'flex', justifyContent: 'space-between', font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginBottom: 4 }}>
          <span>Female {fem}</span><span>Male {mal}</span>
        </div>
        <div style={{ display: 'flex', height: 8, borderRadius: 99, overflow: 'hidden', background: GH_BORDER }}>
          <div style={{ width: `${fem / total * 100}%`, background: GH_GREEN }} />
          <div style={{ width: `${mal / total * 100}%`, background: '#80A5F9' }} />
        </div>
      </div>

      {/* Breeds */}
      <div style={{ marginTop: 14 }}>
        <LabelXS>Breeds</LabelXS>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 8 }}>
          {breedList.map(([b, n]) =>
          <span key={b} style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            padding: '6px 10px', borderRadius: 99, background: GH_GREY_BG,
            font: '700 12px Helvetica, Arial, sans-serif', color: GH_FG
          }}>{b} <span style={{ color: GH_FG_MUTED, fontWeight: 400 }}>{n}</span></span>
          )}
        </div>
      </div>

      {/* Age buckets */}
      <div style={{ marginTop: 14 }}>
        <LabelXS>Age range</LabelXS>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5,1fr)', gap: 6, marginTop: 8 }}>
          {Object.entries(ageBuckets).map(([k, v]) =>
          <div key={k} style={{ background: GH_GREY_BG, borderRadius: 8, padding: '8px 6px', textAlign: 'center' }}>
              <div style={{ font: '700 14px/1 Helvetica, Arial, sans-serif', color: v > 0 ? GH_FG : GH_FG_FAINT }}>{v}</div>
              <div style={{ font: '400 10px/1.2 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 4 }}>{k}</div>
            </div>
          )}
        </div>
      </div>
    </Card>);

};

// --- Groups list with relevant KPI per group --------------------
const ATTENTION_TAGS = ['SICK', 'CULL', 'MISCARRIAGE'];
const groupNeedsAttention = (groupId) => {
  const animals = (window.GH && window.GH.ANIMALS) || [];
  const hits = animals.filter(a => a.group === groupId && a.tags.some(t => ATTENTION_TAGS.includes(t)));
  return hits.length;
};
window.groupNeedsAttention = groupNeedsAttention;

const GroupsKPIList = ({ groups, kpis, nav }) => {
  if (!groups.length) return null;
  return (
    <Card padding={0}>
      <div style={{ padding: '14px 16px', borderBottom: `1px solid ${GH_BORDER}`, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Groups · {groups.length}</h3>
        <button onClick={() => nav('groups')} style={{ background: 'none', border: 'none', cursor: 'pointer', font: '700 13px Helvetica, Arial, sans-serif', color: GH_GREEN, padding: 4 }}>See all →</button>
      </div>
      {groups.map((g, i) => {
        const k = kpis[g.purpose] || { label: 'Animals', value: `${g.count}` };
        const purposeLabel = { MILK: 'Milking', BREEDING: 'Breeding', PREGNANT: 'Pregnant', FATTENING: 'Fattening', MAINTENANCE: 'Maintenance', WEANING: 'Weaning', DRY: 'Dry-off', SICK: 'Sick bay' }[g.purpose] || g.purpose;
        const attn = groupNeedsAttention(g.id);
        return (
          <div key={g.id} onClick={() => nav('group', { id: g.id })} style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px',
            borderBottom: i === groups.length - 1 ? 'none' : `1px solid ${GH_BORDER}`,
            cursor: 'pointer'
          }}>
            <div style={{ position: 'relative', flexShrink: 0 }}>
              <SpeciesAvatar species={g.species} size={40} />
              {attn > 0 && <AttentionDot count={attn} />}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{g.name}</div>
              </div>
              <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: attn > 0 ? GH_ERR : GH_FG_MUTED, marginTop: 2 }}>
                {attn > 0
                  ? `${attn} need${attn === 1 ? 's' : ''} attention · ${purposeLabel}`
                  : `${purposeLabel} · ${g.count} head`}
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ font: '700 9px/1 Helvetica, Arial, sans-serif', textTransform: 'uppercase', letterSpacing: '0.08em', color: GH_FG_MUTED }}>{k.label}</div>
              <div style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG, marginTop: 4 }}>{k.value}</div>
            </div>
            <Icon name="chevR" size={16} color={GH_FG_FAINT} />
          </div>);

      })}
    </Card>);

};

// Small red badge that sits on the corner of a group's avatar.
const AttentionDot = ({ count }) => (
  <span style={{
    position: 'absolute', top: -3, right: -3, minWidth: 16, height: 16, padding: '0 4px',
    borderRadius: 99, background: GH_ERR, color: '#fff',
    font: '700 10px/16px Helvetica, Arial, sans-serif', textAlign: 'center',
    border: '2px solid #fff', boxSizing: 'content-box',
  }}>{count > 9 ? '9+' : count}</span>
);
window.AttentionDot = AttentionDot;

const LabelXSDash = ({ children }) =>
<div style={{ font: '700 10px/1 Helvetica, Arial, sans-serif', textTransform: 'uppercase', color: GH_FG_MUTED, letterSpacing: '0.08em' }}>{children}</div>;


window.Dashboard = Dashboard;

// --- Burger menu (slides down from header) ---------------------
const BurgerMenu = ({ open, onClose, nav }) => {
  if (!open) return null;
  const items = [
    { icon: 'user',    label: 'Profile',     sub: 'Account · language · team',     go: () => nav('profile') },
    { icon: 'users',   label: 'Groups',      sub: 'Manage all groups',             go: () => nav('groups') },
    { icon: 'chart',   label: 'Reports',     sub: 'Production · downloadable PDF', go: () => nav('reports') },
    { icon: 'box',     label: 'Inventory',   sub: 'Feed · medical',                go: () => nav('inventory') },
    { icon: 'help',    label: 'Help',        sub: 'FAQ & support',                 go: () => nav('help') },
  ];
  const handle = (fn) => { onClose(); setTimeout(fn, 0); };
  return (
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, zIndex: 25,
      background: 'rgba(0,0,0,0.32)', animation: 'gh-fade 160ms ease',
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        position: 'absolute', top: 0, left: 0, right: 0, background: '#fff',
        borderBottomLeftRadius: 16, borderBottomRightRadius: 16,
        boxShadow: '0 8px 24px rgba(0,0,0,0.10)',
        animation: 'gh-slide-down 220ms cubic-bezier(0.2,0,0,1)',
        paddingTop: 70, paddingBottom: 8,
      }}>
        <div style={{ padding: '8px 8px 12px' }}>
          {items.map((it, i) => (
            <button key={it.label} onClick={() => handle(it.go)} style={{
              width: '100%', display: 'flex', alignItems: 'center', gap: 14,
              padding: '12px 12px', background: 'none', border: 'none', cursor: 'pointer',
              textAlign: 'left', borderRadius: 10,
            }}>
              <div style={{
                width: 38, height: 38, borderRadius: 10, flexShrink: 0,
                background: GH_GREEN_LIGHT, color: GH_GREEN,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Icon name={it.icon} size={20} />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: '700 15px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>{it.label}</div>
                <div style={{ font: '400 12px/1.3 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{it.sub}</div>
              </div>
              <Icon name="chevR" size={16} color={GH_FG_FAINT} />
            </button>
          ))}
        </div>
        <div style={{ height: 4, width: 40, background: GH_BORDER, borderRadius: 99, margin: '0 auto 10px' }} />
      </div>
    </div>
  );
};
window.BurgerMenu = BurgerMenu;