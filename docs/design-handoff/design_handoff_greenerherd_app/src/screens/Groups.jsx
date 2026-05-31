// GreenerHerd — Groups list + detail
const GroupsList = ({ nav, params }) => {
  const { GROUPS, ANIMALS } = window.GH;
  const [species, setSpecies] = React.useState('all');
  const filtered = GROUPS.filter(g => species === 'all' || g.species === species);
  const totalAnimals = ANIMALS.filter(a => species === 'all' || a.species === species).length;
  const isTabRoot = !params?.fromBack;
  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar
        title="Animals"
        subtitle={`${filtered.length} groups · ${totalAnimals} animals`}
        leftIcon={isTabRoot ? null : 'back'}
        onLeft={isTabRoot ? null : () => nav.back()}
        rightLabel="+ New"
        onRightLabel={() => nav.openSheet('addChooser')}
      />
      <div style={{ padding: '12px 16px 0', display: 'flex', gap: 8, overflow: 'auto' }}>
        {['all','cattle','goat','sheep'].map(s => (
          <Chip key={s} active={species === s} onClick={() => setSpecies(s)}>
            {window.GH.SPECIES_LABEL[s]}
          </Chip>
        ))}
      </div>
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 10 }}>
        <Card padding={14} onClick={() => nav.go('allAnimals')} style={{ background: '#fff' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 48, height: 48, borderRadius: 8, background: GH_GREEN_LIGHT, color: GH_GREEN, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="list" size={22} />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG }}>All animals</div>
              <div style={{ font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>
                Search and filter the full herd
              </div>
            </div>
            <Icon name="chevR" size={20} color={GH_FG_FAINT} />
          </div>
        </Card>
        {filtered.map(g => {
          const attn = (window.groupNeedsAttention || (() => 0))(g.id);
          return (
          <Card key={g.id} padding={14} onClick={() => nav.go('group', { id: g.id })}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{ position: 'relative', flexShrink: 0 }}>
                <SpeciesAvatar species={g.species} />
                {attn > 0 && <AttentionDot count={attn} />}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG }}>{g.name}</div>
                <div style={{ font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: attn > 0 ? GH_ERR : GH_FG_MUTED, marginTop: 2 }}>
                  {attn > 0
                    ? `${attn} need${attn === 1 ? 's' : ''} attention · ${g.count} animals`
                    : `${g.count} animals · purpose: ${g.purpose.toLowerCase()}`}
                </div>
                <div style={{ marginTop: 6 }}><PurposeBadge purpose={g.purpose} /></div>
              </div>
              <Icon name="chevR" size={20} color={GH_FG_FAINT} />
            </div>
          </Card>
          );
        })}
      </div>
    </div>
  );
};

const PurposeBadge = ({ purpose }) => {
  const map = {
    MILK: ['Milking','primary'], BREEDING: ['Breeding','primary'], PREGNANT: ['Pregnant','primary'],
    SICK: ['Sick bay','error'],   FATTENING: ['Fattening','info'], MAINTENANCE: ['Maintenance','neutral'],
  };
  const [l, t] = map[purpose] || [purpose, 'neutral'];
  return <Badge tone={t}>{l}</Badge>;
};

const GroupDetail = ({ nav, params }) => {
  const { GROUPS, ANIMALS, PURPOSES, GROUP_KPI } = window.GH;
  const g = GROUPS.find(x => x.id === params.id) || GROUPS[0];
  const inGroup = ANIMALS.filter(a => a.group === g.id);
  const [tab, setTab] = React.useState(params.tab || 'overview');
  // Tabs depend on purpose — a milking group has no breeding tab; a fattening group has neither breeding nor milking
  const purposeTabs = {
    MILK:        ['overview','animals','nutrition','milking','health'],
    BREEDING:    ['overview','animals','nutrition','breeding','health'],
    PREGNANT:    ['overview','animals','nutrition','breeding','health'],
    FATTENING:   ['overview','animals','nutrition','health'],
    MAINTENANCE: ['overview','animals','nutrition','health'],
    WEANING:     ['overview','animals','nutrition','health'],
    DRY:         ['overview','animals','nutrition','health'],
    SICK:        ['overview','animals','health'],
  };
  const tabs = purposeTabs[g.purpose] || ['overview','animals','nutrition','health'];
  React.useEffect(() => { if (!tabs.includes(tab)) setTab('overview'); }, [g.id]);

  const purposeLabel = (PURPOSES.find(p => p.value === g.purpose) || {}).label || g.purpose;

  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title={g.name} subtitle={`${g.count} ${g.species} · ${purposeLabel.toLowerCase()}`} leftIcon="back" onLeft={() => nav.back()} rightIcon="settings" />
      <div style={{ display: 'flex', gap: 0, background: '#fff', borderBottom: `1px solid ${GH_BORDER}`, overflowX: 'auto' }}>
        {tabs.map(t => (
          <button key={t} onClick={() => setTab(t)} style={{
            background: 'none', border: 'none', cursor: 'pointer',
            padding: '12px 16px', textTransform: 'capitalize',
            font: '700 13px/1 Helvetica, Arial, sans-serif',
            color: tab === t ? GH_GREEN : GH_FG_MUTED,
            borderBottom: tab === t ? `2px solid ${GH_GREEN}` : '2px solid transparent',
            marginBottom: -1, whiteSpace: 'nowrap', flex: '0 0 auto',
          }}>{t}</button>
        ))}
      </div>
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>
        {tab === 'overview'   && <GroupOverview g={g} animals={inGroup} nav={nav} />}
        {tab === 'animals'    && <GroupAnimals animals={inGroup} nav={nav} />}
        {tab === 'nutrition'  && <GroupNutrition g={g} nav={nav} />}
        {tab === 'breeding'   && <GroupBreeding g={g} />}
        {tab === 'milking'    && <GroupMilking g={g} animals={inGroup} nav={nav} />}
        {tab === 'health'     && <GroupHealth g={g} nav={nav} />}
      </div>
    </div>
  );
};

const GroupOverview = ({ g, animals, nav }) => {
  const { PURPOSES, GROUP_KPI } = window.GH;
  const [editing, setEditing] = React.useState(false);
  const [desc, setDesc] = React.useState(g.desc || '');
  const [purpose, setPurpose] = React.useState(g.purpose);
  const purposeLabel = (PURPOSES.find(p => p.value === purpose) || {}).label || purpose;
  const kpi = GROUP_KPI[purpose] || {};
  // Save back to live data so changes persist within the session
  const onSave = () => { g.desc = desc; g.purpose = purpose; setEditing(false); };

  // Purpose-driven extra KPI cards
  const purposeKpis = {
    MILK:        [{ k: 'Avg / head', v: '21.4 L' }, { k: 'Today total', v: '406 L' }, { k: 'On withdrawal', v: '3' }],
    BREEDING:    [{ k: 'Pregnancy rate', v: '64%' }, { k: 'AI attempts (30d)', v: '14' }, { k: 'Confirmed', v: '9' }],
    PREGNANT:    [{ k: 'Due ≤0 30d', v: '3' }, { k: 'Avg gestation', v: '153 d' }, { k: 'Pre-calving', v: '2' }],
    FATTENING:   [{ k: 'ADG (avg)', v: '0.42 kg/d' }, { k: 'Avg weight', v: '52 kg' }, { k: 'Days on feed', v: '64 d' }],
    MAINTENANCE: [{ k: 'Avg weight', v: '184 kg' }, { k: 'BCS avg', v: '3.2 / 5' }, { k: 'Cull flagged', v: '1' }],
    WEANING:     [{ k: 'Avg weight', v: '74 kg' }, { k: 'Avg ADG', v: '0.31 kg/d' }, { k: 'Days to wean', v: '12 d' }],
    DRY:         [{ k: 'Avg days dry', v: '32 d' }, { k: 'Due to calve', v: '4' }, { k: 'BCS avg', v: '3.4' }],
    SICK:        [{ k: 'Active tx', v: '9' }, { k: 'Withdrawal', v: '5' }, { k: 'Recovered (30d)', v: '7' }],
  }[purpose] || [{ k: 'Animals', v: g.count }];

  return (
    <>
      {/* Description + purpose card — editable */}
      <Card padding={16}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8, marginBottom: editing ? 12 : 8 }}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <LabelXS>Purpose</LabelXS>
            {!editing ? (
              <div style={{ marginTop: 6 }}><PurposeBadge purpose={purpose} /></div>
            ) : (
              <div style={{ marginTop: 6 }}>
                <Select value={purpose} onChange={setPurpose} options={PURPOSES} />
              </div>
            )}
          </div>
          {!editing && (
            <button onClick={() => setEditing(true)} style={{ background: 'none', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4, color: GH_GREEN, font: '700 13px Helvetica, Arial, sans-serif', padding: 4 }}>
              <Icon name="edit" size={16} /> Edit
            </button>
          )}
        </div>
        <div style={{ marginTop: 4 }}>
          <LabelXS>Description</LabelXS>
          {!editing ? (
            <div style={{ font: '400 14px/1.5 Helvetica, Arial, sans-serif', color: desc ? GH_FG : GH_FG_MUTED, marginTop: 6 }}>{desc || 'Tap edit to add a description for this group.'}</div>
          ) : (
            <textarea value={desc} onChange={e => setDesc(e.target.value)} rows={3}
              style={{ width: '100%', boxSizing: 'border-box', marginTop: 6,
                border: `1.5px solid ${GH_BORDER}`, borderRadius: 8, padding: '10px 12px',
                font: '400 14px/1.5 Helvetica, Arial, sans-serif', color: GH_FG, outline: 'none', resize: 'vertical' }} />
          )}
        </div>
        {editing && (
          <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
            <Button variant="outline" onClick={() => { setDesc(g.desc || ''); setPurpose(g.purpose); setEditing(false); }}>Cancel</Button>
            <Button full onClick={onSave}>Save</Button>
          </div>
        )}
      </Card>

      {/* Purpose-relevant KPI strip */}
      <Card padding={0}>
        <div style={{ padding: '14px 16px', borderBottom: `1px solid ${GH_BORDER}`, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>{purposeLabel} KPIs</h3>
          <Badge tone="primary" dot>Live</Badge>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: `repeat(${purposeKpis.length},1fr)`, gap: 0 }}>
          {purposeKpis.map((p, i) => (
            <div key={p.k} style={{ padding: '14px 12px', borderRight: i === purposeKpis.length - 1 ? 'none' : `1px solid ${GH_BORDER}` }}>
              <LabelXS>{p.k}</LabelXS>
              <div style={{ font: '700 18px/1 Helvetica, Arial, sans-serif', color: GH_FG, marginTop: 6 }}>{p.v}</div>
            </div>
          ))}
        </div>
      </Card>

      {/* Composition grid */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <Stat label="Animals"   value={g.count} sub={`${animals.length} loaded`} icon="list" />
        <Stat label="Females"   value={animals.filter(a => a.sex === 'F').length} icon="heart" />
        <Stat label="Pregnant"  value={animals.filter(a => a.tags.includes('PREGNANT')).length} icon="baby" tone="ok" />
        <Stat label="Sick"      value={animals.filter(a => a.tags.includes('SICK')).length} icon="syringe" tone="err" />
      </div>

      {/* Nutrition card — only on groups where nutrition is meaningful */}
      {purpose !== 'SICK' && (
      <Card padding={16} onClick={() => nav.go('group', { id: g.id, tab: 'nutrition' })}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
          <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Nutrition</h3>
          <Badge tone="warning" dot>Energy gap</Badge>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <Progress label="Dry matter" value={194}  target={202}  unit="kg" />
          <Progress label="Energy"     value={1500} target={2552} unit="MJ" />
        </div>
      </Card>
      )}

      <Card padding={16}>
        <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: '0 0 10px' }}>Tasks · 7 days</h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <CompactTaskRow icon="syringe" tone="warning" title="FMD booster" sub="Fri 14:00" />
          <CompactTaskRow icon="check"   tone="primary" title="Pregnancy scan" sub="Today 16:30" />
          <CompactTaskRow icon="leaf"    tone="neutral" title="Adjust morning ration" sub="Daily" />
        </div>
      </Card>
    </>
  );
};

const CompactTaskRow = ({ icon, tone, title, sub }) => {
  const tones = { primary: [GH_GREEN_LIGHT, GH_GREEN], warning: [GH_WARN_LIGHT, GH_WARN], neutral: [GH_BORDER, GH_FG_MUTED] }[tone];
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
      <div style={{ width: 32, height: 32, borderRadius: 8, background: tones[0], color: tones[1], display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name={icon} size={16} />
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ font: '700 13px Helvetica, Arial, sans-serif', color: GH_FG }}>{title}</div>
        <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 1 }}>{sub}</div>
      </div>
    </div>
  );
};

const GroupAnimals = ({ animals, nav }) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
    {animals.length === 0 && <NotApplicable text="No animals loaded for this group in the prototype." />}
    {animals.map(a => (
      <Card key={a.id} padding={12} onClick={() => nav.go('animal', { id: a.id })}>
        <div style={{ display: 'grid', gridTemplateColumns: '40px 1fr auto', gap: 10, alignItems: 'center' }}>
          <SpeciesAvatar species={a.species} size={40} />
          <div style={{ minWidth: 0 }}>
            <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>
              {a.name !== '—' ? a.name : ''} <span style={{ color: GH_FG_MUTED }}>#{a.tag}</span>
            </div>
            <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{a.breed} · {a.wt} kg</div>
          </div>
          {a.tags.length > 0 ? (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 4, alignItems: 'flex-end' }}>
              {a.tags.slice(0, 2).map(t => <StatusTag key={t} tag={t} />)}
            </div>
          ) : <Icon name="chevR" size={16} color={GH_FG_FAINT} />}
        </div>
      </Card>
    ))}
  </div>
);

const GroupNutrition = ({ g, nav }) => (
  <>
    <Card padding={16}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 14 }}>
        <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Today vs requirement</h3>
        <button style={{ background: 'none', border: 'none', font: '700 12px Helvetica, Arial, sans-serif', color: GH_GREEN, cursor: 'pointer' }}>Per head</button>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Progress label="Dry matter"     value={194}  target={202}  unit="kg" />
        <Progress label="Crude protein"  value={16.3} target={22.0} unit="kg" />
        <Progress label="Energy (ME)"    value={1500} target={2552} unit="MJ" />
        <Progress label="NDF"            value={64}   target={62}   unit="kg" />
      </div>
      <div style={{ display: 'flex', gap: 14, marginTop: 14, font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, flexWrap: 'wrap' }}>
        <span><Dot c={GH_GREEN}/> ±10% OK</span>
        <span><Dot c={GH_WARN}/> 10–30% Warning</span>
        <span><Dot c={GH_ERR}/> &gt;30% Action</span>
      </div>
    </Card>

    <InfoBanner tone="primary" icon="leaf"
      title="Energy gap detected"
      body="Group is 41% below energy target. Greener Herd suggests adding 14 kg of barley concentrate to morning mix."
      action="Fix the gap" onAction={() => nav.go('feedRec', { id: g.id })} />

    <Card padding={0}>
      <div style={{ padding: '14px 16px', borderBottom: `1px solid ${GH_BORDER}`, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Today's feed</h3>
        <Button variant="ghost" size="sm" onClick={() => nav.openSheet('recordFeeding', { group: g })}>+ Record</Button>
      </div>
      <FeedRow name="Morning Mix · alfalfa + barley" kg="148 kg" head="6.7 kg/head" cost="SAR 412" />
      <FeedRow name="Afternoon · corn silage"        kg="46 kg"  head="2.1 kg/head" cost="SAR 138" last />
    </Card>

    <Card padding={14}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <LabelXS>Daily cost / head</LabelXS>
          <div style={{ font: '700 22px Helvetica, Arial, sans-serif', color: GH_FG, marginTop: 4 }}>SAR 25.00</div>
        </div>
        <Badge tone="success">−4% vs last week</Badge>
      </div>
    </Card>
  </>
);

const Dot = ({ c }) => <span style={{ display: 'inline-block', width: 10, height: 10, borderRadius: 99, background: c, marginRight: 4, verticalAlign: -1 }} />;

const FeedRow = ({ name, kg, head, cost, last }) => (
  <div style={{ padding: '14px 16px', borderBottom: last ? 'none' : `1px solid ${GH_BORDER}`, display: 'flex', alignItems: 'center', gap: 14 }}>
    <div style={{ width: 36, height: 36, borderRadius: 8, background: GH_GREEN_LIGHT, color: GH_GREEN, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <Icon name="leaf" size={18} />
    </div>
    <div style={{ flex: 1 }}>
      <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{name}</div>
      <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{kg} · {head}</div>
    </div>
    <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{cost}</div>
  </div>
);

const GroupBreeding = ({ g }) => (
  <>
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
      <Stat label="AI attempts (30d)" value="14" icon="syringe" />
      <Stat label="Confirmed pregnant" value="9" icon="check" tone="ok" />
      <Stat label="Success rate" value="64%" sub="Above 50% threshold" tone="ok" />
      <Stat label="Miscarriages" value="1" tone="warn" />
    </div>
    <Card padding={0}>
      <KVHead title="AI provider performance" />
      <KVRow k="Dr. Rashed · Tabuk" v="71%" sub="10 of 14 confirmed" />
      <KVRow k="Al-Wafi Genetics"   v="50%" sub="2 of 4 confirmed" last />
    </Card>
    <InfoBanner tone="warning" icon="info"
      title="2 failed AI on Khulud #0470"
      body="Consider finding an alternative AI provider for the next attempt." />
  </>
);

const GroupMilking = ({ g, animals, nav }) => {
  if (g.purpose !== 'MILK') return <NotApplicable text="Milking applies to groups with purpose: Milk." />;
  const total = animals.reduce((s, a) => s + (a.milkToday || 0), 0);
  return (
    <>
      <Card padding={16}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <div>
            <LabelXS>Today's volume</LabelXS>
            <div style={{ font: '700 30px Helvetica, Arial, sans-serif', color: GH_FG, marginTop: 4 }}>{total.toFixed(1)} L</div>
            <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>Avg {(total / animals.length).toFixed(1)} L/head · {animals.length} milking</div>
          </div>
          <Button variant="primary" size="sm" icon="plus" onClick={() => nav.openSheet('recordMilk', { group: g })}>Record</Button>
        </div>
      </Card>
      <Card padding={0}>
        <KVHead title="Top producers" />
        {animals.filter(a => a.milkToday).sort((a, b) => b.milkToday - a.milkToday).map((a, i, arr) => (
          <KVRow key={a.id} k={`${a.name !== '—' ? a.name : '#' + a.tag}`} v={`${a.milkToday} L`} sub={a.withdrawal ? `Withdrawal · ${a.withdrawal} d` : a.breed} last={i === arr.length - 1} />
        ))}
      </Card>
      <Card padding={16}>
        <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: '0 0 10px' }}>30-day group total</h3>
        <div style={{ display: 'flex', gap: 2, alignItems: 'flex-end', height: 90 }}>
          {Array.from({ length: 30 }).map((_, i) => {
            const h = 50 + Math.sin(i / 4) * 18 + (i % 6) * 1.5;
            return <div key={i} style={{ flex: 1, height: `${h}%`, background: GH_GREEN, borderRadius: 2 }} />;
          })}
        </div>
      </Card>
    </>
  );
};

const GroupHealth = ({ g, nav }) => (
  <>
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
      <Stat label="Sick"  value="2" tone="err" icon="syringe" />
      <Stat label="On withdrawal" value="3" tone="warn" sub="Avg 4 d remaining" />
    </div>
    <InfoBanner tone="warning" icon="overdue"
      title="FMD booster due Fri"
      body="14 head · last vaccinated 14 Apr · 4-week interval reached." action="Schedule vaccination" onAction={() => nav.openSheet('recordVaccination', { group: g })} />
    <Card padding={0}>
      <KVHead title="Recent vaccinations" />
      <KVRow k="FMD"            v="14 Apr 2026" sub="Booster Fri 12 May" />
      <KVRow k="Brucellosis"    v="22 Sep 2025" sub="Annual cycle" last />
    </Card>
    <Card padding={0}>
      <KVHead title="Active treatments" />
      <KVRow k="Mastitis · Sara #0444"  v="day 3 of 5" sub="Penicillin G · 5ml IM" />
      <KVRow k="Ketosis · Bessie #0421" v="day 1 of 7" sub="Propylene glycol" last />
    </Card>
  </>
);

window.GroupsList = GroupsList;
window.GroupDetail = GroupDetail;

const addRowStyle = {
  display: 'flex', alignItems: 'center', gap: 12,
  padding: '14px 14px', border: `1.5px solid ${GH_BORDER}`, borderRadius: 12,
  background: '#fff', cursor: 'pointer', width: '100%',
};
const addIconBox = {
  width: 40, height: 40, borderRadius: 10, background: GH_GREEN_LIGHT, color: GH_GREEN,
  display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
};
