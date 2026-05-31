// GreenerHerd — Animals list
const AnimalsList = ({ nav, params }) => {
  const { ANIMALS, SPECIES_LABEL } = window.GH;
  const [species, setSpecies] = React.useState(params?.species || 'all');
  const [tag, setTag] = React.useState(params?.tag || 'all');
  const [groupFilter, setGroupFilter] = React.useState(params?.groupId || null);
  const [q, setQ] = React.useState('');

  // Smart placeholder reflects active filters — "Search pregnant cattle…" etc
  const placeholder = (() => {
    const tagLabel = tag !== 'all' ? (tag === 'DUE_SOON' ? 'pregnant near due' : (TAG_LOOKUP[tag]?.label || tag).toLowerCase()) : null;
    const sLabel = species !== 'all' ? SPECIES_LABEL[species].toLowerCase() : null;
    if (tagLabel && sLabel) return `Search ${tagLabel} ${sLabel}…`;
    if (tagLabel) return `Search ${tagLabel} animals…`;
    if (sLabel) return `Search ${sLabel}…`;
    return 'Search tag, name, breed…';
  })();

  const filtered = ANIMALS.filter((a) =>
  (species === 'all' || a.species === species) && (
  tag === 'all'
    ? true
    : tag === 'DUE_SOON'
      ? a.tags.includes('PREGNANT') && a.species === 'cattle'
      : a.tags.includes(tag)) && (
  !groupFilter || a.group === groupFilter) && (
  q === '' || a.name.toLowerCase().includes(q.toLowerCase()) || a.tag.toLowerCase().includes(q.toLowerCase()) || a.breed.toLowerCase().includes(q.toLowerCase()))
  );

  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title="Animals" subtitle={`${filtered.length} of ${ANIMALS.length}`} rightLabel="+ Add" onRightLabel={() => nav.openSheet('addAnimal')} />

      {/* Search */}
      <div style={{ padding: '12px 16px 0' }}>
        <div style={{ position: 'relative' }}>
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder={placeholder} style={{
            width: '100%', boxSizing: 'border-box',
            border: 'none', borderRadius: 10, padding: '12px 14px 12px 40px',
            font: '400 15px/1 Helvetica, Arial, sans-serif',
            background: '#fff', boxShadow: `inset 0 0 0 1px ${GH_BORDER}`, outline: 'none', color: GH_FG
          }} />
          <div style={{ position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)', color: GH_FG_FAINT }}>
            <Icon name="search" size={18} />
          </div>
        </div>
      </div>

      {/* Species */}
      <div style={{ padding: '12px 16px 0', display: 'flex', gap: 8, overflow: 'auto' }}>
        {['all', 'cattle', 'goat', 'sheep'].map((s) =>
        <Chip key={s} active={species === s} onClick={() => setSpecies(s)}>
            {SPECIES_LABEL[s]}
          </Chip>
        )}
      </div>

      {/* Tag */}
      <div style={{ padding: '8px 16px 4px', display: 'flex', gap: 8, overflow: 'auto' }}>
        {['all', 'DUE_SOON', 'PREGNANT', 'LACTATING', 'READY_TO_BREED', 'SICK', 'CULL', 'WEANING'].map((t) =>
        <Chip key={t} active={tag === t} onClick={() => setTag(t)}>
            {t === 'all' ? 'Any status' : t === 'DUE_SOON' ? 'Due soon' : TAG_LOOKUP[t]?.label || t}
          </Chip>
        )}
      </div>

      {/* Groups for selected species */}
      <GroupsStrip species={species} nav={nav} selected={groupFilter} onSelect={setGroupFilter} />

      <div style={{ padding: '4px 16px 4px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <h3 style={{ font: '700 14px/1 Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>
          {groupFilter ? (window.GH.GROUPS.find(g => g.id === groupFilter)?.name || 'Group') : 'All animals'}
        </h3>
        <span style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{filtered.length} shown</span>
      </div>

      <div style={{ padding: '8px 16px 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {filtered.length === 0 &&
        <Card padding={24} style={{ textAlign: 'center' }}>
            <div style={{ font: '700 15px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>No animals match.</div>
          </Card>
        }
        {filtered.map((a) =>
        <Card key={a.id} padding={14} onClick={() => nav.go('animal', { id: a.id })}>
            <div style={{ display: 'grid', gridTemplateColumns: '48px 1fr auto', gap: 12, alignItems: 'center' }}>
              <SpeciesAvatar species={a.species} />
              <div style={{ minWidth: 0 }}>
                <div style={{ font: '700 16px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>
                  {a.name !== '—' ? `${a.name} · ` : ''}<span style={{ color: GH_FG_MUTED }}>#{a.tag}</span>
                </div>
                <div style={{ font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>
                  {a.breed} · {a.wt} kg · {a.age}
                </div>
                {a.tags.length > 0 &&
              <div style={{ display: 'flex', gap: 6, marginTop: 6, flexWrap: 'wrap' }}>
                    {a.tags.map((t) => <StatusTag key={t} tag={t} />)}
                  </div>
              }
              </div>
              <div style={{ textAlign: 'right' }}>
                {a.milkToday ?
              <>
                    <div style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_GREEN }}>{a.milkToday} L</div>
                    <div style={{ font: '400 11px/1.3 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>today</div>
                  </> :
              <Icon name="chevR" size={20} color={GH_FG_FAINT} />}
              </div>
            </div>
          </Card>
        )}
      </div>
    </div>);

};

const GroupsStrip = ({ species, nav, selected, onSelect }) => {
  const { GROUPS, GROUP_KPI } = window.GH;
  const visible = GROUPS.filter((g) => species === 'all' || g.species === species);
  if (visible.length === 0) return null;
  const purposeMap = {
    MILK: ['Milking', 'primary'], BREEDING: ['Breeding', 'primary'], PREGNANT: ['Pregnant', 'primary'],
    SICK: ['Sick bay', 'error'], FATTENING: ['Fattening', 'info'], MAINTENANCE: ['Maintenance', 'neutral'],
    WEANING: ['Weaning', 'info'], DRY: ['Dry-off', 'neutral']
  };
  return (
    <div style={{ padding: '14px 0 4px' }}>
      <div style={{ padding: '0 16px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <h3 style={{ font: '700 14px/1 Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>
          Groups <span style={{ color: GH_FG_MUTED, fontWeight: 400 }}>· {visible.length}</span>
          {selected && (
            <button onClick={() => onSelect(null)} style={{
              marginLeft: 8, background: GH_GREEN_LIGHT, color: GH_GREEN, border: 'none',
              borderRadius: 99, padding: '2px 8px 2px 10px', cursor: 'pointer',
              font: '700 11px Helvetica, Arial, sans-serif',
              display: 'inline-flex', alignItems: 'center', gap: 4,
            }}>Clear <Icon name="close" size={12} /></button>
          )}
        </h3>
        <button onClick={() => nav.go('groups', { fromBack: true })} style={{ background: 'none', border: 'none', cursor: 'pointer', font: '700 13px Helvetica, Arial, sans-serif', color: GH_GREEN, padding: 4 }}>
          See all →
        </button>
      </div>
      <div style={{ display: 'flex', gap: 10, overflowX: 'auto', padding: '0 16px 4px', scrollSnapType: 'x mandatory' }}>
        {visible.map((g) => {
          const [pl, pt] = purposeMap[g.purpose] || [g.purpose, 'neutral'];
          const kpi = GROUP_KPI[g.purpose];
          const isActive = selected === g.id;
          const attn = (window.groupNeedsAttention || (() => 0))(g.id);
          return (
            <button key={g.id} onClick={() => onSelect(isActive ? null : g.id)} style={{
              minWidth: 184, flex: '0 0 auto', textAlign: 'left',
              background: isActive ? GH_GREEN_LIGHT : '#fff',
              border: `1.5px solid ${isActive ? GH_GREEN : GH_BORDER}`, borderRadius: 12,
              padding: 12, cursor: 'pointer', boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
              display: 'flex', flexDirection: 'column', gap: 10, scrollSnapAlign: 'start'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <div style={{ position: 'relative' }}>
                  <SpeciesAvatar species={g.species} size={36} />
                  {attn > 0 && window.AttentionDot && <window.AttentionDot count={attn} />}
                </div>
                <div style={{ minWidth: 0, flex: 1 }}>
                  <div style={{ font: '700 14px/1.2 Helvetica, Arial, sans-serif', color: GH_FG, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{g.name}</div>
                  <Badge tone={pt}>{pl}</Badge>
                </div>
              </div>
              <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', borderTop: `1px solid ${GH_BORDER}`, paddingTop: 8 }}>
                <div>
                  <div style={{ font: '700 9px/1 Helvetica, Arial, sans-serif', textTransform: 'uppercase', letterSpacing: '0.08em', color: GH_FG_MUTED }}>{kpi?.label || 'Animals'}</div>
                  <div style={{ font: '700 18px/1 Helvetica, Arial, sans-serif', color: GH_FG, marginTop: 4 }}>{kpi?.value || `${g.count} head`}</div>
                </div>
                <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{g.count} head</div>
              </div>
            </button>);

        })}
      </div>
    </div>);

};

window.AnimalsList = AnimalsList;