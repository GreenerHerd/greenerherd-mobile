// GreenerHerd — Finance + Reports + Settings
const DEFAULT_PRICES = {
  milk: { cattle: 4.50, goat: 6.00, sheep: 5.20 },
  meat: { cattle: 38,   goat: 52,   sheep: 46 },
};
const PRICES_KEY = 'gh_prices_v1';
const loadPrices = () => {
  try { return { ...DEFAULT_PRICES, ...JSON.parse(localStorage.getItem(PRICES_KEY) || '{}') }; }
  catch { return DEFAULT_PRICES; }
};

const FinanceScreen = ({ nav }) => {
  const { FINANCE, FARM } = window.GH;
  const [prices, setPrices] = React.useState(loadPrices);
  React.useEffect(() => {
    const onChange = () => setPrices(loadPrices());
    window.addEventListener('gh-prices-changed', onChange);
    return () => window.removeEventListener('gh-prices-changed', onChange);
  }, []);
  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title="Finance" subtitle={FARM.name} rightLabel="+ Entry" onRightLabel={() => nav.openSheet('addFinance')} />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>

        <Card padding={16}>
          <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: '0 0 10px' }}>3-month rolling</h3>
          <div style={{ display: 'flex', gap: 16, alignItems: 'flex-end', height: 130 }}>
            {FINANCE.monthly.map((mo) => {
              const max = Math.max(...FINANCE.monthly.map((m) => Math.max(m.inc, m.exp)));
              return (
                <div key={mo.m} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
                  <div style={{ display: 'flex', gap: 6, alignItems: 'flex-end', height: 100 }}>
                    <div style={{ width: 22, background: GH_GREEN, height: `${mo.inc / max * 100}%`, borderRadius: '4px 4px 0 0' }} />
                    <div style={{ width: 22, background: '#80A5F9', height: `${mo.exp / max * 100}%`, borderRadius: '4px 4px 0 0' }} />
                  </div>
                  <div style={{ font: '700 11px Roboto, Helvetica, sans-serif', color: GH_FG_MUTED }}>{mo.m}</div>
                </div>);

            })}
          </div>
          <div style={{ display: 'flex', gap: 16, marginTop: 14, font: '400 11px Helvetica, Arial, sans-serif' }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: 6, color: GH_FG_MUTED }}><Sw c={GH_GREEN} /> Income</span>
            <span style={{ display: 'flex', alignItems: 'center', gap: 6, color: GH_FG_MUTED }}><Sw c="#80A5F9" /> Expense</span>
          </div>
        </Card>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Stat label="Income (3mo)" value={`SAR ${FINANCE.income3mo.toLocaleString()}`} tone="ok" />
          <Stat label="Expense (3mo)" value={`SAR ${FINANCE.expense3mo.toLocaleString()}`} />
          <Stat label="Net" value={`SAR ${FINANCE.net3mo.toLocaleString()}`} tone="ok" />
          <Stat label="Livestock value" value={`SAR ${FINANCE.livestockValue.toLocaleString()}`} />
        </div>

        <Card padding={0}>
          <KVHead title="Recent entries" />
          {FINANCE.recent.map((f, i, arr) =>
          <div key={f.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderBottom: i === arr.length - 1 ? 'none' : `1px solid ${GH_BORDER}` }}>
              <div style={{ width: 36, height: 36, borderRadius: 8, background: f.type === 'INCOME' ? GH_GREEN_LIGHT : GH_BORDER, color: f.type === 'INCOME' ? GH_GREEN : GH_FG_MUTED, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name={f.type === 'INCOME' ? 'wallet' : 'arrow'} size={16} />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{f.cat}</div>
                <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{f.desc} · {f.date}</div>
              </div>
              <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: f.type === 'INCOME' ? GH_GREEN : GH_FG }}>
                {f.type === 'INCOME' ? '+' : '−'} {f.amount.toLocaleString()}
              </div>
            </div>
          )}
        </Card>

        <Card padding={16}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <II name="bottle" size={24} />
              <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Milk price · per litre</h3>
            </div>
            <Button variant="ghost" size="sm" icon="edit" onClick={() => nav.openSheet('editPrices', { focus: 'milk' })}>Edit</Button>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <PriceRow species="cattle" price={`SAR ${prices.milk.cattle.toFixed(2)}`} trend="+0.10" />
            <PriceRow species="goat"   price={`SAR ${prices.milk.goat.toFixed(2)}`}   trend="−0.20" down />
            <PriceRow species="sheep"  price={`SAR ${prices.milk.sheep.toFixed(2)}`}  trend="+0.00" />
          </div>
        </Card>

        <Card padding={16}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <II name="sale" size={24} />
              <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Meat price · per kg</h3>
            </div>
            <Button variant="ghost" size="sm" icon="edit" onClick={() => nav.openSheet('editPrices', { focus: 'meat' })}>Edit</Button>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <PriceRow species="cattle" price={`SAR ${prices.meat.cattle.toFixed(2)}`} trend="+1.10" />
            <PriceRow species="goat"   price={`SAR ${prices.meat.goat.toFixed(2)}`}   trend="−0.40" down />
            <PriceRow species="sheep"  price={`SAR ${prices.meat.sheep.toFixed(2)}`}  trend="+0.60" />
          </div>
        </Card>
      </div>
    </div>);

};

const PriceRow = ({ species, price, trend, down }) =>
<div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
    <SpeciesAvatar species={species} size={32} light />
    <div style={{ flex: 1, font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG, textTransform: 'capitalize' }}>{species}</div>
    <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{price}</div>
    <Badge tone={down ? 'error' : 'success'}>{trend}</Badge>
  </div>;


const Sw = ({ c }) => <span style={{ width: 12, height: 12, borderRadius: 3, background: c, display: 'inline-block' }} />;

const ReportsScreen = ({ nav }) => {
  const { REPORTS } = window.GH;
  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title="Reports" subtitle="PDF · downloadable" />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>

        <Card padding={16} style={{ background: '#fff' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
            <h3 style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>Date range</h3>
            <Badge tone="primary">Last 90 days</Badge>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Field label="From" value="07 Feb 2026" readOnly />
            <Field label="To" value="08 May 2026" readOnly />
          </div>
        </Card>

        <SectionHeader title="Available reports" />
        <Card padding={0}>
          {REPORTS.map((r, i, arr) =>
          <div key={r.id} onClick={() => nav.go('report', { id: r.id })} style={{ padding: '14px 16px', borderBottom: i === arr.length - 1 ? 'none' : `1px solid ${GH_BORDER}`, display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer' }}>
              <div style={{ width: 36, height: 36, borderRadius: 8, background: GH_GREEN_LIGHT, color: GH_GREEN, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name={r.icon} size={18} />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{r.name}</div>
                <div style={{ font: '400 12px/1.3 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{r.desc}</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ font: '700 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{r.count}</div>
                <Icon name="chevR" size={16} color={GH_FG_FAINT} />
              </div>
            </div>
          )}
        </Card>
      </div>
    </div>);

};

const ReportDetailScreen = ({ nav, params }) => {
  const { REPORTS } = window.GH;
  const r = REPORTS.find(x => x.id === params?.id) || REPORTS[0];
  const tone = { wallet: GH_GREEN, milk: GH_GREEN, syringe: GH_ERR, baby: GH_GREEN, list: GH_FG_MUTED, leaf: GH_GREEN, chart: GH_GREEN, weight: GH_GREEN }[r.icon] || GH_GREEN;
  // Mocked summary rows so the report has substance to review before download
  const summary = [
    { k: 'Records included',  v: r.count, sub: 'In the selected range' },
    { k: 'Window',             v: 'Last 90 days', sub: 'Feb 07 – May 08' },
    { k: 'Species covered',    v: 'Cattle · Goat · Sheep' },
    { k: 'Generated',          v: 'Today, 09:14' },
  ];
  const sections = [
    { t: 'Headline',         items: [`${r.count} records summarised`, 'Trends across 30 / 60 / 90 days', 'Outliers highlighted'] },
    { t: 'Per-group',         items: ['Breakdown by group · species · purpose', 'Compared to farm-wide average'] },
    { t: 'Auditable detail', items: ['Source record IDs', 'Recorded-by attribution per row'] },
  ];
  return (
    <div style={{ background: GH_GREY_BG, minHeight: '100%' }}>
      <AppBar title={r.name} subtitle="Report preview" leftIcon="back" onLeft={() => nav.back()} />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>
        <Card padding={16}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
            <div style={{ width: 44, height: 44, borderRadius: 10, background: GH_GREEN_LIGHT, color: tone, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <Icon name={r.icon} size={22} />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ font: '700 16px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>{r.name}</div>
              <div style={{ font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{r.desc}</div>
            </div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            {summary.map(s => (
              <div key={s.k} style={{ padding: 12, background: GH_GREY_BG, borderRadius: 10 }}>
                <div style={{ font: '700 10px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, textTransform: 'uppercase', letterSpacing: '0.08em' }}>{s.k}</div>
                <div style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_FG, marginTop: 6 }}>{s.v}</div>
                {s.sub && <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 4 }}>{s.sub}</div>}
              </div>
            ))}
          </div>
        </Card>

        {sections.map(sec => (
          <Card key={sec.t} padding={16}>
            <h3 style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG, margin: '0 0 10px' }}>{sec.t}</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {sec.items.map(it => (
                <div key={it} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <span style={{ width: 6, height: 6, borderRadius: 99, background: GH_GREEN, flexShrink: 0 }} />
                  <span style={{ font: '400 13px/1.4 Helvetica, Arial, sans-serif', color: GH_FG }}>{it}</span>
                </div>
              ))}
            </div>
          </Card>
        ))}

        <Card padding={16}>
          <h3 style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG, margin: '0 0 10px' }}>Export</h3>
          <div style={{ display: 'flex', gap: 8 }}>
            <Button variant="outline" icon="download">CSV</Button>
            <Button full icon="pdf">Download PDF</Button>
          </div>
          <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 10, textAlign: 'center' }}>
            Includes signature line for veterinary / auditor handoff.
          </div>
        </Card>
      </div>
    </div>
  );
};

window.FinanceScreen = FinanceScreen;
window.ReportsScreen = ReportsScreen;
window.ReportDetailScreen = ReportDetailScreen;