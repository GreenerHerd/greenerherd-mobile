// GreenerHerd — Feed recommendations (drill-down from "Fix the gap")
const FeedRecommendations = ({ nav, params }) => {
  const { GROUPS } = window.GH;
  const g = GROUPS.find(x => x.id === params?.id) || GROUPS[0];
  const [source, setSource] = React.useState('inventory');
  const [picked, setPicked] = React.useState({ inv1: 14 });

  // Mocked recommendation pool — Greener Herd's suggestion engine output
  const RECS = {
    inventory: [
      { id: 'inv1', name: 'Barley grain',         tag: 'In inventory · 240 kg available',   cost: '0.42 SAR/kg', need: 14, energy: '+38%', protein: '+6%',  primary: true },
      { id: 'inv2', name: 'Alfalfa hay (premium)', tag: 'In inventory · 180 bales',           cost: '8.4 SAR/bale', need: 4,  energy: '+11%', protein: '+18%', primary: false },
      { id: 'inv3', name: 'Wheat bran',            tag: 'In inventory · 60 kg',               cost: '0.31 SAR/kg', need: 6,  energy: '+9%',  protein: '+4%',  primary: false },
    ],
    standard: [
      { id: 'std1', name: 'GH Energy Concentrate 16%', tag: 'Greener Herd standard mix',   cost: '1.85 SAR/kg', need: 11, energy: '+42%', protein: '+12%', primary: true },
      { id: 'std2', name: 'Lactating cow ration A',     tag: 'Pre-formulated · cattle',     cost: '2.10 SAR/kg', need: 9,  energy: '+39%', protein: '+15%', primary: false },
      { id: 'std3', name: 'Mineral block · cattle',     tag: 'Refresh every 14 days',       cost: '34 SAR/block', need: 1, energy: '—',    protein: '—',    primary: false },
    ],
    market: [
      { id: 'mkt1', name: 'Barley grain — bulk 1t',     tag: 'Al-Wafi Feed Co · Riyadh · 1 day delivery', cost: '0.36 SAR/kg', need: 14, energy: '+38%', protein: '+6%',  primary: true },
      { id: 'mkt2', name: 'Soybean meal 44%',           tag: 'GreenAg · Dammam · 2 day delivery',          cost: '2.95 SAR/kg', need: 4,  energy: '+8%',  protein: '+22%', primary: false },
      { id: 'mkt3', name: 'Alfalfa pellets',            tag: 'FarmDirect · 3 day delivery',                cost: '1.40 SAR/kg', need: 8,  energy: '+12%', protein: '+14%', primary: false },
    ],
  };
  const recs = RECS[source];

  const totalCost = recs.filter(r => picked[r.id]).reduce((sum, r) => {
    const num = parseFloat(r.cost);
    return sum + num * (picked[r.id] || 0);
  }, 0);

  const sourceTabs = [
    { k: 'inventory', label: 'Inventory', sub: 'Use what you have' },
    { k: 'standard',  label: 'Standard',  sub: 'Pre-formulated mixes' },
    { k: 'market',    label: 'Marketplace', sub: 'Suppliers near you' },
  ];

  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title="Fix the gap" subtitle={g.name} leftIcon="back" onLeft={() => nav.back()} />

      {/* Gap summary card */}
      <div style={{ padding: 16, paddingBottom: 0 }}>
        <Card padding={16}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 12 }}>
            <div>
              <LabelXS>Energy gap detected</LabelXS>
              <div style={{ font: '700 22px/1.1 Helvetica, Arial, sans-serif', color: GH_FG, marginTop: 4 }}>−41%<span style={{ font: '400 13px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginLeft: 8 }}>below target</span></div>
            </div>
            <Badge tone="warning" dot>Today</Badge>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            <Progress label="Energy"     value={1500} target={2552} unit="MJ" />
            <Progress label="Dry matter" value={194}  target={202}  unit="kg" />
            <Progress label="Protein"    value={31}   target={34}   unit="kg" />
          </div>
        </Card>
      </div>

      {/* Source tabs */}
      <div style={{ padding: '14px 16px 0' }}>
        <div style={{ display: 'flex', gap: 6, background: '#fff', border: `1px solid ${GH_BORDER}`, borderRadius: 12, padding: 4 }}>
          {sourceTabs.map(s => (
            <button key={s.k} onClick={() => setSource(s.k)} style={{
              flex: 1, background: source === s.k ? GH_GREEN : 'transparent', border: 'none',
              borderRadius: 8, padding: '8px 6px', cursor: 'pointer',
              color: source === s.k ? '#fff' : GH_FG,
              font: '700 13px/1.2 Helvetica, Arial, sans-serif',
            }}>
              {s.label}
              <div style={{ font: '400 10px Helvetica, Arial, sans-serif', color: source === s.k ? 'rgba(255,255,255,0.85)' : GH_FG_MUTED, marginTop: 2 }}>{s.sub}</div>
            </button>
          ))}
        </div>
      </div>

      {/* Recommendations list */}
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 10 }}>
        {recs.map(r => {
          const isPicked = !!picked[r.id];
          return (
            <Card key={r.id} padding={14} style={r.primary ? { border: `1.5px solid ${GH_GREEN}` } : {}}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
                <div style={{ width: 40, height: 40, borderRadius: 8, background: r.primary ? GH_GREEN : GH_GREEN_LIGHT, color: r.primary ? '#fff' : GH_GREEN, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <Icon name="leaf" size={18} />
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{r.name}</div>
                    {r.primary && <Badge tone="primary">Top pick</Badge>}
                  </div>
                  <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{r.tag}</div>
                  <div style={{ display: 'flex', gap: 14, marginTop: 10, font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, flexWrap: 'wrap' }}>
                    <span><b style={{ color: GH_FG }}>{r.cost}</b></span>
                    <span>Energy <b style={{ color: GH_GREEN }}>{r.energy}</b></span>
                    <span>Protein <b style={{ color: GH_GREEN }}>{r.protein}</b></span>
                  </div>
                </div>
                <button onClick={() => setPicked(p => {
                  const next = { ...p };
                  if (isPicked) delete next[r.id]; else next[r.id] = r.need;
                  return next;
                })} style={{
                  background: isPicked ? GH_GREEN : '#fff',
                  color: isPicked ? '#fff' : GH_FG,
                  border: `1.5px solid ${isPicked ? GH_GREEN : GH_BORDER}`, borderRadius: 8,
                  font: '700 12px Helvetica, Arial, sans-serif', padding: '8px 12px', cursor: 'pointer', flexShrink: 0,
                }}>{isPicked ? '✓ Added' : '+ Add'}</button>
              </div>
              {isPicked && (
                <div style={{ marginTop: 12, padding: 10, background: GH_GREY_BG, borderRadius: 8, display: 'flex', alignItems: 'center', gap: 10 }}>
                  <LabelXS>Quantity</LabelXS>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginLeft: 'auto' }}>
                    <button onClick={() => setPicked(p => ({ ...p, [r.id]: Math.max(1, (p[r.id] || 0) - 1) }))} style={iconBtn}>−</button>
                    <div style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, minWidth: 56, textAlign: 'center' }}>{picked[r.id]} <span style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>kg/day</span></div>
                    <button onClick={() => setPicked(p => ({ ...p, [r.id]: (p[r.id] || 0) + 1 }))} style={iconBtn}>+</button>
                  </div>
                </div>
              )}
            </Card>
          );
        })}
      </div>

      {/* Cost + apply CTA */}
      <div style={{ padding: '0 16px 100px' }}>
        <Card padding={14}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
            <LabelXS>Projected daily cost</LabelXS>
            <div style={{ font: '700 18px Helvetica, Arial, sans-serif', color: GH_FG }}>{totalCost.toFixed(2)} SAR</div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            {source === 'market' ? (
              <Button variant="outline" icon="plus" onClick={() => nav.go('inventory')}>Add to inventory</Button>
            ) : (
              <Button variant="outline" onClick={() => nav.back()}>Save plan</Button>
            )}
            <Button full onClick={() => nav.go('group', { id: g.id, tab: 'nutrition' })}>Apply to morning mix</Button>
          </div>
          <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 10, textAlign: 'center' }}>
            Greener Herd will recompute the gap after the next feeding is logged.
          </div>
        </Card>
      </div>
    </div>
  );
};

const iconBtn = {
  width: 28, height: 28, borderRadius: 99, border: `1px solid ${GH_BORDER}`,
  background: '#fff', cursor: 'pointer',
  font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG,
};

window.FeedRecommendations = FeedRecommendations;
