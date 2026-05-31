// GreenerHerd — Individual animal profile
const AnimalProfile = ({ nav, params }) => {
  const { ANIMALS, GROUPS } = window.GH;
  const a = ANIMALS.find((x) => x.id === params.id) || ANIMALS[0];
  const group = GROUPS.find((g) => g.id === a.group);
  const [tab, setTab] = React.useState(params.tab || 'overview');
  const [, force] = React.useState(0);
  const refresh = () => force(n => n + 1);
  const isFemale = a.sex === 'F';
  const isLactating = a.tags.includes('LACTATING') || !!a.milkToday;
  const isSick = a.tags.includes('SICK');

  // Persisted media (per-animal, in localStorage)
  const mediaKey = `gh_animal_media_${a.id}`;
  const profKey  = `gh_animal_prof_${a.id}`;
  const [photos, setPhotos] = React.useState(() => {
    try { return JSON.parse(localStorage.getItem(mediaKey) || '[]'); } catch { return []; }
  });
  const [profilePic, setProfilePic] = React.useState(() => localStorage.getItem(profKey) || '');
  React.useEffect(() => { localStorage.setItem(mediaKey, JSON.stringify(photos)); }, [photos, mediaKey]);
  React.useEffect(() => {
    if (profilePic) localStorage.setItem(profKey, profilePic);
    else localStorage.removeItem(profKey);
  }, [profilePic, profKey]);

  // Camera roll picker, used for profile or gallery
  const profFileRef = React.useRef(null);
  const galFileRef = React.useRef(null);
  const onPickProf = (e) => {
    const f = e.target.files?.[0]; if (!f) return;
    const r = new FileReader(); r.onload = () => setProfilePic(r.result); r.readAsDataURL(f);
    e.target.value = '';
  };
  const onPickGallery = (e) => {
    const files = Array.from(e.target.files || []);
    Promise.all(files.map(f => new Promise(res => {
      const r = new FileReader();
      r.onload = () => res({ id: `p${Date.now()}_${Math.random().toString(36).slice(2,6)}`, url: r.result, name: f.name });
      r.readAsDataURL(f);
    }))).then(items => setPhotos(p => [...items, ...p]));
    e.target.value = '';
  };

  // Mutators
  const markCured = () => { a.tags = a.tags.filter(t => t !== 'SICK'); refresh(); };
  const onCloseTreatment = () => {
    // Recording a treatment marks the animal as ill until cured
    if (!a.tags.includes('SICK')) a.tags = [...a.tags, 'SICK'];
    nav.closeSheet();
    refresh();
  };

  const tabs = ['overview', 'weight', 'breeding', 'milking', 'health', 'tasks', 'media'];

  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title={`#${a.tag}`} subtitle={a.name !== '—' ? a.name : a.breed} leftIcon="back" onLeft={() => nav.back()} rightIcon="edit" onRight={() => nav.openSheet('editAnimal', { animal: a })} />

      <div style={{ background: '#fff', padding: '14px 16px 0' }}>
        <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
          {/* Profile picture (tap to change) */}
          <button onClick={() => profFileRef.current && profFileRef.current.click()} style={{
            width: 64, height: 64, borderRadius: 12, padding: 0, border: 'none', cursor: 'pointer',
            background: profilePic ? `center/cover no-repeat url(${profilePic})` : GH_GREEN_LIGHT,
            position: 'relative', overflow: 'hidden', flexShrink: 0,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            {!profilePic && <SpeciesAvatar species={a.species} size={64} />}
            <span style={{
              position: 'absolute', right: 4, bottom: 4, width: 22, height: 22, borderRadius: 99,
              background: '#fff', color: GH_FG, border: `1px solid ${GH_BORDER}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}><Icon name="camera" size={12} /></span>
          </button>
          <input ref={profFileRef} type="file" accept="image/*" onChange={onPickProf} style={{ display: 'none' }} />

          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ font: '700 22px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>
              {a.name !== '—' ? a.name : `#${a.tag}`}
            </div>
            <div style={{ font: '400 13px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>
              {a.breed} · {a.age} · <span onClick={(e) => {e.stopPropagation();group && nav.go('group', { id: group.id });}} style={{ color: GH_GREEN, cursor: 'pointer' }}>{group?.name || 'Unassigned'}</span>
            </div>
            <div style={{ display: 'flex', gap: 6, marginTop: 8, flexWrap: 'wrap' }}>
              {a.tags.map((t) => <StatusTag key={t} tag={t} />)}
              {a.withdrawal && <Badge tone="warning">Withdrawal · {a.withdrawal}d</Badge>}
              {a.twin && <Badge tone="info">Twin</Badge>}
            </div>
          </div>
        </div>

        {/* Quick actions */}
        <div style={{ display: 'flex', gap: 8, marginTop: 14, overflowX: 'auto', paddingBottom: 4 }}>
          {isLactating && (
            <QuickAction icon="milk" label="Record milk" onClick={() => nav.openSheet('recordMilk', { animal: a })} />
          )}
          {isSick ? (
            <QuickAction illustrated="sheep-happy" label="Mark cured" tone="ok" onClick={markCured} />
          ) : (
            <QuickAction illustrated="medication" label="Treatment" onClick={() => nav.openSheet('recordHealth', { animal: a, onClose: onCloseTreatment })} />
          )}
          <QuickAction icon="arrow" label="Move group" onClick={() => nav.openSheet('moveAnimal', { animal: a, onMoved: refresh })} />
          <QuickAction illustrated="tag-id" label="Status" onClick={() => nav.openSheet('statusChange', { animal: a, onChanged: refresh })} />
          <QuickAction illustrated="records" label="Add task" onClick={() => nav.openSheet('newTask', { animal: a })} />
          <QuickAction icon="camera" label="Add photo" onClick={() => galFileRef.current && galFileRef.current.click()} />
          <input ref={galFileRef} type="file" accept="image/*" multiple onChange={onPickGallery} style={{ display: 'none' }} />
        </div>

        <div style={{ display: 'flex', gap: 0, marginTop: 14, borderBottom: `1px solid ${GH_BORDER}`, overflowX: 'auto', margin: '14px -16px 0' }}>
          {tabs.map((t) =>
          <button key={t} onClick={() => setTab(t)} style={{
            background: 'none', border: 'none', cursor: 'pointer',
            padding: '12px 14px', textTransform: 'capitalize',
            font: '700 13px/1 Helvetica, Arial, sans-serif',
            color: tab === t ? GH_GREEN : GH_FG_MUTED,
            borderBottom: tab === t ? `2px solid ${GH_GREEN}` : '2px solid transparent',
            marginBottom: -1, whiteSpace: 'nowrap', flex: '0 0 auto'
          }}>{t}</button>
          )}
        </div>
      </div>

      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>
        {tab === 'overview' && <OverviewTab a={a} group={group} nav={nav} />}
        {tab === 'weight' && <WeightTab a={a} />}
        {tab === 'breeding' && (isFemale ? <BreedingTab a={a} /> : <NotApplicable text="Breeding history shown for females only." />)}
        {tab === 'milking' && (isLactating ? <MilkingTab a={a} nav={nav} /> : <NotApplicable text="Milking shown for lactating females only." />)}
        {tab === 'health' && <HealthTab a={a} nav={nav} markCured={markCured} onTreatmentClose={onCloseTreatment} />}
        {tab === 'tasks' && <TasksTabCmp a={a} nav={nav} />}
        {tab === 'media' && <MediaTab photos={photos} setPhotos={setPhotos} onAdd={() => galFileRef.current && galFileRef.current.click()} />}
      </div>
    </div>);

};

const QuickAction = ({ icon, illustrated, label, onClick, tone }) => (
  <button onClick={onClick} style={{
    flex: '0 0 auto', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
    background: 'none', border: 'none', cursor: 'pointer', padding: '4px 4px', minWidth: 64,
  }}>
    <div style={{
      width: 44, height: 44, borderRadius: 12,
      background: tone === 'ok' ? GH_OK_LIGHT : GH_GREEN_LIGHT,
      color: tone === 'ok' ? GH_OK : GH_GREEN,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {illustrated ? <II name={illustrated} size={32} /> : <Icon name={icon} size={20} />}
    </div>
    <div style={{ font: '700 11px/1.2 Helvetica, Arial, sans-serif', color: GH_FG, textAlign: 'center' }}>{label}</div>
  </button>
);

const NotApplicable = ({ text }) =>
<Card padding={28} style={{ textAlign: 'center' }}>
    <div style={{ font: '400 14px/1.5 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{text}</div>
  </Card>;


const OverviewTab = ({ a, group, nav }) =>
<>
    <Card padding={0}>
      <KVRow k="Ear tag" v={`#${a.tag}`} />
      {a.name !== '—' && <KVRow k="Name" v={a.name} />}
      <KVRow k="Sex" v={`${a.sex === 'F' ? 'Female' : 'Male'}${a.heifer ? ' · heifer' : ''}`} />
      <KVRow k="Date of birth" v={a.dob || '—'} />
      <KVRow k="Origin" v="Born on farm" />
      <KVRow k="Weight" v={`${a.wt} kg`} sub="recorded 2 May" />
      {a.bcs && <KVRow k="BCS" v={`${a.bcs} / 5`} />}
      <KVRow k="Group" v={group?.name || '—'} link />
      {a.sire && <KVRow k="Sire" v={`${a.sire} · ${a.breed}`} link />}
      {a.dam && <KVRow k="Dam" v={`${a.dam} · ${a.breed}`} link last />}
    </Card>
    {a.id === 'a1' && <ChildrenCard nav={nav} />}
  </>;


const ChildrenCard = ({ nav }) => {
  const { ANIMALS } = window.GH;
  const kids = ANIMALS.filter((x) => x.dam === 'Bessie');
  return (
    <Card padding={16}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, margin: '0 0 12px' }}>
        <II name="calf-feeding" size={28} />
        <h3 style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Children · {kids.length}</h3>
      </div>
      <div style={{ display: 'flex', gap: 10, overflowX: 'auto' }}>
        {kids.map((c) =>
        <button key={c.id} onClick={() => nav && nav.go('animal', { id: c.id })} style={{ minWidth: 110, padding: 10, background: GH_GREY_BG, borderRadius: 8, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, border: 'none', cursor: 'pointer' }}>
            <SpeciesAvatar species="cattle" size={36} />
            <div style={{ font: '700 13px/1 Helvetica, Arial, sans-serif', color: GH_FG }}>#{c.tag}</div>
            <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{c.name !== '—' ? c.name : 'unnamed'}</div>
            {c.twin && <Badge tone="info">Twin</Badge>}
          </button>
        )}
      </div>
    </Card>);

};

const KVRow = ({ k, v, sub, link, last }) =>
<div style={{
  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
  padding: '14px 16px', borderBottom: last ? 'none' : `1px solid ${GH_BORDER}`
}}>
    <div style={{ font: '400 13px/1.2 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{k}</div>
    <div style={{ textAlign: 'right' }}>
      <div style={{ font: '700 14px/1.2 Helvetica, Arial, sans-serif', color: link ? GH_GREEN : GH_FG }}>{v}</div>
      {sub && <div style={{ font: '400 11px/1.2 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{sub}</div>}
    </div>
  </div>;


const WeightTab = ({ a }) => {
  const data = [
  { d: 'Jan', w: a.wt - 40 }, { d: 'Feb', w: a.wt - 28 }, { d: 'Mar', w: a.wt - 16 },
  { d: 'Apr', w: a.wt - 8 }, { d: 'May', w: a.wt }];

  const max = a.wt + 8,min = a.wt - 50;
  return (
    <>
      <Card padding={16}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 14 }}>
          <h3 style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Weight · 5 months</h3>
          <Badge tone="success">+11%</Badge>
        </div>
        <div style={{ display: 'flex', gap: 18, alignItems: 'flex-end', height: 140 }}>
          {data.map((p) =>
          <div key={p.d} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
              <div style={{ font: '700 11px/1 Roboto, Helvetica, sans-serif', color: GH_FG_MUTED }}>{p.w}</div>
              <div style={{ width: '100%', maxWidth: 36, background: GH_GREEN, borderRadius: '4px 4px 0 0', height: `${(p.w - min) / (max - min) * 100}px` }} />
              <div style={{ font: '700 11px/1 Roboto, Helvetica, sans-serif', color: GH_FG_MUTED }}>{p.d}</div>
            </div>
          )}
        </div>
      </Card>
      <Card padding={0}>
        {data.slice().reverse().map((p, i) =>
        <KVRow key={p.d} k={`${p.d} 2026`} v={`${p.w} kg`} sub={i === 0 ? 'Current' : `${p.w - data[Math.max(0, data.length - 2 - i)]?.w >= 0 ? '+' : ''}${p.w - data[Math.max(0, data.length - 2 - i)]?.w} kg`} last={i === data.length - 1} />
        )}
      </Card>
    </>);

};

const BreedingTab = ({ a }) =>
<>
    {a.tags.includes('PREGNANT') &&
  <Card padding={16}>
        <h3 style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG, margin: '0 0 12px' }}>Active pregnancy</h3>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
          <div><LabelXS>Started</LabelXS><div style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, marginTop: 4 }}>22 Dec 2025</div></div>
          <div><LabelXS>Due date</LabelXS><div style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_GREEN, marginTop: 4 }}>30 Sep 2026</div></div>
        </div>
        <div style={{ marginTop: 14, height: 8, background: GH_BORDER, borderRadius: 99, overflow: 'hidden' }}>
          <div style={{ height: '100%', width: '54%', background: GH_GREEN }} />
        </div>
        <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 6 }}>153 / 283 days · 130 days remaining</div>
      </Card>
  }
    <Card padding={0}>
      <KVRow k="Method" v="Artificial insemination" />
      <KVRow k="Sire" v="ISIS-7714 · Holstein" link />
      <KVRow k="Provider" v="Dr. Rashed · Tabuk Genetics" />
      <KVRow k="Attempt #" v="1 of 1" sub="Conceived first attempt" last />
    </Card>
    <Card padding={0}>
      <KVHead title="Breeding history" />
      <KVRow k="22 Dec 2025" v="AI · Confirmed" sub="Pregnancy ongoing" />
      <KVRow k="14 Mar 2024" v="Birth · 1 calf" sub="Yara #0512 · 36 kg" />
      <KVRow k="04 Jun 2023" v="AI · Confirmed" sub="Attempt 1" />
      <KVRow k="14 Mar 2022" v="Born on farm" sub="Dam: Faten" last />
    </Card>
  </>;


const KVHead = ({ title }) =>
<div style={{ padding: '14px 16px', borderBottom: `1px solid ${GH_BORDER}`, font: '700 14px/1 Helvetica, Arial, sans-serif', color: GH_FG }}>{title}</div>;


const LabelXS = ({ children }) =>
<div style={{ font: '700 10px/1 Helvetica, Arial, sans-serif', textTransform: 'uppercase', color: GH_FG_MUTED, letterSpacing: '0.08em' }}>{children}</div>;


const MilkingTab = ({ a, nav }) => {
  if (!a.milkToday && !a.tags.includes('LACTATING')) return <NotApplicable text="No milk records yet — animal not lactating." />;
  const today = a.milkToday || 0;
  return (
    <>
      <Card padding={16}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 12 }}>
          <h3 style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>30-day milk</h3>
          <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_GREEN }}>Avg {(today * 1.05).toFixed(1)} L/day</div>
        </div>
        <div style={{ display: 'flex', gap: 2, alignItems: 'flex-end', height: 110 }}>
          {Array.from({ length: 30 }).map((_, i) => {
            const h = 40 + Math.sin(i / 3) * 20 + i % 5;
            return <div key={i} style={{ flex: 1, height: `${h}%`, background: GH_GREEN, borderRadius: 2 }} />;
          })}
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, font: '700 11px Roboto, Helvetica, sans-serif', color: GH_FG_MUTED }}>
          <span>9 Apr</span><span>24 Apr</span><span>8 May</span>
        </div>
      </Card>      <Card padding={16}>
        <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: '0 0 12px' }}>Today</h3>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
          <Stat label="Morning" value={`${(today * 0.55).toFixed(1)} L`} />
          <Stat label="Evening" value={`${(today * 0.45).toFixed(1)} L`} />
          <Stat label="Total" value={`${today} L`} tone="ok" />
        </div>
      </Card>
      <Button variant="primary" full icon="plus" onClick={() => nav.openSheet('recordMilk', { animal: a })}>Record milk</Button>
    </>);

};

const HealthTab = ({ a, nav, markCured, onTreatmentClose }) =>
<>
    {a.withdrawal &&
  <InfoBanner tone="warning" icon="overdue"
  title="Withdrawal period active"
  body={`Milk safe from 11 May. Do not sell ${a.name !== '—' ? a.name : '#' + a.tag}'s milk until cleared.`} />
  }
    {a.tags.includes('SICK') &&
  <Card padding={14} style={{ background: '#FEF2F2', borderColor: GH_ERR_LIGHT }}>
    <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
      <II name="sheep-sick" size={48} style={{ flexShrink: 0 }} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ font: '700 14px/1.3 Helvetica, Arial, sans-serif', color: GH_ERR }}>Active illness</div>
        <div style={{ font: '400 13px/1.5 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 4 }}>Mastitis · day 3 of 5 of treatment. Penicillin G — 5 ml IM daily.</div>
        <div style={{ marginTop: 10 }}><Button variant="outline" size="sm" onClick={markCured}>Mark cured</Button></div>
      </div>
    </div>
  </Card>
  }
    <Card padding={0}>
      <KVHead title="Healthcare history" />
      <KVRow k="Ketosis · 4 May" v="Active" link sub="Propylene glycol · 250 ml/day" />
      <KVRow k="FMD vaccine · 14 Apr" v="Booster 12 May" sub="Withdrawal cleared" />
      <KVRow k="Mastitis · 22 Feb" v="Resolved" sub="Penicillin G · 5 ml IM" last />
    </Card>
    <Card padding={0}>
      <KVHead title="Vaccinations" />
      <KVRow k="FMD" v="14 Apr 2026" sub="Booster due 12 May" />
      <KVRow k="Brucellosis" v="22 Sep 2025" sub="Annual" />
      <KVRow k="Lumpy Skin" v="03 Jul 2025" sub="Annual" last />
    </Card>
    <Button variant="outline" full icon="plus" onClick={() => nav.openSheet('recordHealth', { animal: a, onClose: onTreatmentClose })}>Record treatment</Button>
  </>;


const TasksTabCmp = ({ a, nav }) =>
<>
  <Card padding={0}>
    <KVRow k="Pregnancy scan" v="Due 12 May" sub="Auto · 45-day check" />
    <KVRow k="Booster · FMD" v="Due 12 May" sub="Auto · 4 weeks" />
    <KVRow k="Move to pre-calving" v="Due 31 Aug" sub="Auto · 30 days before due" last />
  </Card>
  <Button variant="outline" full icon="plus" onClick={() => nav.openSheet('newTask', { animal: a })}>Add task for {a.name !== '—' ? a.name : `#${a.tag}`}</Button>
</>;

const MediaTab = ({ photos, setPhotos, onAdd }) => (
  <>
    <Button variant="outline" full icon="camera" onClick={onAdd}>Add photos</Button>
    {photos.length === 0 ? (
      <NotApplicable text="No media yet. Tap 'Add photos' to capture or upload images of this animal." />
    ) : (
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        {photos.map(p => (
          <div key={p.id} style={{ position: 'relative', aspectRatio: '1 / 1', borderRadius: 12, overflow: 'hidden', background: '#fff', border: `1px solid ${GH_BORDER}` }}>
            <img src={p.url} alt={p.name} style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }} />
            <button onClick={() => setPhotos(ph => ph.filter(x => x.id !== p.id))} style={{
              position: 'absolute', top: 6, right: 6, width: 26, height: 26, borderRadius: 99,
              background: 'rgba(0,0,0,0.55)', color: '#fff', border: 'none', cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}><Icon name="close" size={14} /></button>
          </div>
        ))}
      </div>
    )}
  </>
);


window.AnimalProfile = AnimalProfile;