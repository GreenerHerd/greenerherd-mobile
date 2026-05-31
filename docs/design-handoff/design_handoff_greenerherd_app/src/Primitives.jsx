// GreenerHerd — UI primitives. Adapted from design system.
const GH_GREEN = '#3B5A2A';
const GH_GREEN_HOVER = '#2F4822';
const GH_GREEN_LIGHT = '#ABCF98';
const GH_BORDER = '#E6E6E6';
const GH_GREY_BG = '#E8EFDD'; /* soft sage page tint — was #F6F6F6 */
const GH_FG = '#111111';
const GH_FG_MUTED = '#525252';
const GH_FG_FAINT = '#A3A3A3';
const GH_WARN = '#D97706';
const GH_WARN_LIGHT = '#FDE68A';
const GH_ERR = '#DC2626';
const GH_ERR_LIGHT = '#FECACA';
const GH_OK_LIGHT = '#BBF7D0';
const GH_OK = '#16A34A';

// --- Icon (Lucide-style outline 2px) ----------------------------
const Icon = ({ name, size = 20, color = 'currentColor', style }) => {
  const paths = {
    home: <><path d="M3 12 12 3l9 9" /><path d="M5 10v10h14V10" /></>,
    search: <><circle cx="11" cy="11" r="7" /><path d="m20 20-3-3" /></>,
    plus: <><path d="M12 5v14M5 12h14" /></>,
    back: <><path d="m15 18-6-6 6-6" /></>,
    chevR: <><path d="m9 6 6 6-6 6" /></>,
    chevD: <><path d="m6 9 6 6 6-6" /></>,
    bell: <><path d="M6 8a6 6 0 1 1 12 0c0 7 3 8 3 8H3s3-1 3-8z" /><path d="M10 21a2 2 0 0 0 4 0" /></>,
    calendar: <><rect x="3" y="5" width="18" height="16" rx="2" /><path d="M3 9h18M8 3v4M16 3v4" /></>,
    settings: <><circle cx="12" cy="12" r="3" /><path d="M19.4 15a8 8 0 0 0 0-6m-1.7 9.7a8 8 0 0 0-13.4 0M19.4 9a8 8 0 0 0-1.7-2.7M4.6 9a8 8 0 0 1 1.7-2.7" /></>,
    chart: <><path d="M3 3v18h18" /><path d="M7 14l4-4 3 3 5-6" /></>,
    user: <><circle cx="12" cy="8" r="4" /><path d="M4 21c1-4 5-6 8-6s7 2 8 6" /></>,
    users: <><circle cx="9" cy="8" r="3.5" /><path d="M2 21c1-3.5 4-5 7-5s6 1.5 7 5" /><circle cx="17" cy="8" r="3" /><path d="M16 21c.5-2 2-3.5 4-3.5" /></>,
    list: <><path d="M3 7h18M3 12h18M3 17h18" /></>,
    menu: <><path d="M4 6h16M4 12h16M4 18h16" /></>,
    help: <><circle cx="12" cy="12" r="9" /><path d="M9.5 9a2.5 2.5 0 1 1 3.5 2.3c-.8.4-1 .9-1 1.7M12 17h.01" /></>,
    box: <><path d="M3 7l9-4 9 4-9 4-9-4z" /><path d="M3 7v10l9 4 9-4V7" /><path d="M12 11v10" /></>,
    paperclip: <><path d="M21 11l-9 9a5 5 0 0 1-7-7l9-9a3.5 3.5 0 0 1 5 5l-9 9a2 2 0 0 1-3-3l8-8" /></>,
    trash: <><path d="M3 6h18M8 6V4h8v2M6 6l1 14a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-14" /><path d="M10 11v6M14 11v6" /></>,
    check: <><circle cx="12" cy="12" r="9" /><path d="m9 12 2 2 4-4" /></>,
    checkPlain: <><path d="M5 12l5 5L20 7" /></>,
    edit: <><path d="M12 20h9" /><path d="M16.5 3.5a2.1 2.1 0 1 1 3 3L7 19l-4 1 1-4z" /></>,
    drop: <><path d="M12 3s7 8 7 13a7 7 0 0 1-14 0c0-5 7-13 7-13z" /></>,
    heart: <><path d="M12 21s-7-4.5-9-10a5 5 0 0 1 9-3 5 5 0 0 1 9 3c-2 5.5-9 10-9 10z" /></>,
    weight: <><rect x="3" y="6" width="18" height="14" rx="2" /><path d="M7 6V4h10v2M9 12h6" /></>,
    wallet: <><rect x="3" y="6" width="18" height="13" rx="2" /><path d="M3 10h18M16 14h2" /></>,
    leaf: <><path d="M5 21c0-9 6-15 15-15 0 9-6 15-15 15z" /><path d="M5 21l9-9" /></>,
    syringe: <><path d="m18 2 4 4M16 4l4 4-12 12-4-4z" /><path d="M3 21l4-4M9 11l4 4" /></>,
    milk: <><path d="M9 3h6v3l2 4v9a2 2 0 0 1-2 2H9a2 2 0 0 1-2-2v-9l2-4z" /></>,
    baby: <><circle cx="12" cy="12" r="9" /><path d="M9 12h.01M15 12h.01M9 16c.7.7 4.3.7 5 0" /></>,
    arrow: <><path d="M5 12h14M12 5l7 7-7 7" /></>,
    mic: <><rect x="9" y="3" width="6" height="11" rx="3" /><path d="M5 11a7 7 0 0 0 14 0M12 18v3" /></>,
    camera: <><rect x="3" y="6" width="18" height="14" rx="2" /><circle cx="12" cy="13" r="4" /><path d="M8 6l2-3h4l2 3" /></>,
    overdue: <><circle cx="12" cy="12" r="9" /><path d="M12 7v6l4 2" /></>,
    filter: <><path d="M3 5h18l-7 8v6l-4 2v-8z" /></>,
    download: <><path d="M12 4v12m0 0-5-5m5 5 5-5M4 20h16" /></>,
    dots: <><circle cx="5" cy="12" r="1.5" /><circle cx="12" cy="12" r="1.5" /><circle cx="19" cy="12" r="1.5" /></>,
    close: <><path d="M6 6l12 12M18 6 6 18" /></>,
    tag: <><path d="M3 12V4h8l10 10-8 8-10-10z" /><circle cx="7.5" cy="7.5" r="1.5" /></>,
    play: <><path d="M6 4l14 8-14 8z" /></>,
    pause: <><rect x="6" y="4" width="4" height="16" /><rect x="14" y="4" width="4" height="16" /></>,
    pdf: <><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" /><path d="M14 2v6h6" /></>,
    grid: <><rect x="3" y="3" width="7" height="7" rx="1" /><rect x="14" y="3" width="7" height="7" rx="1" /><rect x="3" y="14" width="7" height="7" rx="1" /><rect x="14" y="14" width="7" height="7" rx="1" /></>,
    info: <><circle cx="12" cy="12" r="9" /><path d="M12 8h.01M11 12h1v5h1" /></>,
    location: <><path d="M12 21s-7-7-7-12a7 7 0 0 1 14 0c0 5-7 12-7 12z" /><circle cx="12" cy="9" r="2.5" /></>,
    flame: <><path d="M12 21c-4 0-7-3-7-7 0-3 2-4 3-6 1 2 2 2 3 0 0 0 2-3 1-6 4 2 7 6 7 12 0 4-3 7-7 7z" /></>
  };
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color}
    strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={style}>
      {paths[name] || null}
    </svg>);

};

// --- Illustrated icon (raster, brand set) -----------------------
// Use for tiles/avatars at 28px+ where personality matters. Falls back to
// rendering nothing if the name isn't in the set.
const ILLUSTRATED_ICONS = {
  'calf-feeding':        'assets/icons/calf-feeding.png',
  'inventory':           'assets/icons/inventory.png',
  'welfare':             'assets/icons/welfare.png',
  'breeding-confirmed':  'assets/icons/breeding-confirmed.png',
  'records':             'assets/icons/records.png',
  'tag-id':              'assets/icons/tag.png',
  'sheep-happy':         'assets/icons/sheep-happy.png',
  'sheep-sick':          'assets/icons/sheep-sick.png',
  'medication':          'assets/icons/medication.png',
  'bottle':              'assets/icons/bottle.png',
  'sale':                'assets/icons/sale.png',
  'rip':                 'assets/icons/rip.png',
};
const II = ({ name, size = 32, style, alt }) => {
  const src = ILLUSTRATED_ICONS[name];
  if (!src) return null;
  return <img src={src} width={size} height={size} alt={alt || name} style={{ display: 'block', objectFit: 'contain', ...style }} />;
};

// --- Button -----------------------------------------------------
const Button = ({ children, variant = 'primary', size = 'md', onClick, icon, disabled, full, style }) => {
  const sty = {
    base: {
      font: '700 15px/1 Helvetica, Arial, sans-serif',
      padding: size === 'sm' ? '8px 14px' : '14px 22px',
      borderRadius: 8, border: 'none', cursor: disabled ? 'not-allowed' : 'pointer',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      width: full ? '100%' : 'auto',
      transition: 'background 120ms', minHeight: size === 'sm' ? 36 : 48,
      opacity: disabled ? 0.6 : 1, whiteSpace: 'nowrap'
    },
    primary: { background: GH_GREEN, color: '#fff' },
    outline: { background: 'transparent', color: GH_GREEN, boxShadow: `inset 0 0 0 1.5px ${GH_GREEN}` },
    secondary: { background: '#877BEE', color: '#fff' },
    danger: { background: GH_ERR, color: '#fff' },
    ghost: { background: 'transparent', color: GH_GREEN, minHeight: 'auto', padding: '8px 12px' }
  };
  return (
    <button style={{ ...sty.base, ...sty[variant], ...style }} onClick={onClick} disabled={disabled}>
      {icon && <Icon name={icon} size={16} />}
      {children}
    </button>);

};

// --- Badge ------------------------------------------------------
const Badge = ({ children, tone = 'neutral', dot }) => {
  const tones = {
    success: { bg: GH_OK_LIGHT, fg: GH_OK },
    warning: { bg: GH_WARN_LIGHT, fg: GH_WARN },
    error: { bg: GH_ERR_LIGHT, fg: GH_ERR },
    primary: { bg: GH_GREEN_LIGHT, fg: GH_GREEN },
    neutral: { bg: GH_BORDER, fg: GH_FG_MUTED },
    info: { bg: '#E0E7FF', fg: '#1A107A' }
  };
  const t = tones[tone];
  return (
    <span style={{
      font: '700 11px/1 Helvetica, Arial, sans-serif',
      background: t.bg, color: t.fg,
      padding: '5px 10px', borderRadius: 99, letterSpacing: '0.02em', whiteSpace: 'nowrap',
      display: 'inline-flex', alignItems: 'center', gap: 5
    }}>
      {dot && <span style={{ width: 6, height: 6, borderRadius: 99, background: t.fg }} />}
      {children}
    </span>);

};

// --- Card -------------------------------------------------------
const Card = ({ children, padding = 16, style, onClick }) =>
<div onClick={onClick} style={{
  background: '#fff', border: `1px solid ${GH_BORDER}`, borderRadius: 12,
  boxShadow: '0 2px 8px rgba(0,0,0,0.06)', padding,
  cursor: onClick ? 'pointer' : 'default', ...style
}}>{children}</div>;


// --- Section header --------------------------------------------
const SectionHeader = ({ title, action, onAction }) =>
<div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 4px', marginBottom: 10 }}>
    <h2 style={{ font: '700 18px/1.2 Helvetica, Arial, sans-serif', color: GH_FG, margin: 0 }}>{title}</h2>
    {action && <button onClick={onAction} style={{
    background: 'none', border: 'none', font: '700 13px/1 Helvetica, Arial, sans-serif',
    color: GH_GREEN, cursor: 'pointer', padding: 4
  }}>{action}</button>}
  </div>;


// --- App bar ---------------------------------------------------
const AppBar = ({ title, leftIcon, rightIcon, onLeft, onRight, subtitle, rightLabel, onRightLabel }) =>
<div style={{
  minHeight: 56, padding: '8px 8px 8px 4px', background: '#fff',
  borderBottom: `1px solid ${GH_BORDER}`, display: 'flex',
  alignItems: 'center', gap: 4, position: 'sticky', top: 0, zIndex: 5
}}>
    {leftIcon ?
  <button onClick={onLeft} style={{
    background: 'none', border: 'none', padding: 12, cursor: 'pointer', color: GH_FG,
    display: 'flex', alignItems: 'center', justifyContent: 'center'
  }}>
        <Icon name={leftIcon} size={22} />
      </button> :
  <div style={{ width: 12 }} />}
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ font: '700 16px/1.2 Helvetica, Arial, sans-serif', color: GH_FG, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</div>
      {subtitle && <div style={{ font: '400 12px/1.2 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{subtitle}</div>}
    </div>
    {rightLabel &&
  <button onClick={onRightLabel} style={{
    background: 'none', border: 'none', padding: '8px 12px', cursor: 'pointer',
    font: '700 14px/1 Helvetica, Arial, sans-serif', color: GH_GREEN
  }}>{rightLabel}</button>
  }
    {rightIcon &&
  <button onClick={onRight} style={{
    background: 'none', border: 'none', padding: 12, cursor: 'pointer', color: GH_FG,
    display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative'
  }}>
        <Icon name={rightIcon} size={22} />
        {rightIcon === 'bell' &&
    <span style={{ position: 'absolute', top: 9, right: 9, width: 8, height: 8, borderRadius: 99, background: GH_ERR, border: '2px solid #fff' }} />
    }
      </button>
  }
  </div>;


// --- Bottom tab bar ---------------------------------------------
const TabBar = ({ active, onChange }) => {
  const tabs = [
  { id: 'home', label: 'Home', icon: 'home' },
  { id: 'animals', label: 'Animals', icon: 'list' },
  { id: 'tasks', label: 'Tasks', icon: 'check' },
  { id: 'finance', label: 'Finance', icon: 'wallet' },
  { id: 'reports', label: 'Reports', icon: 'chart' }];

  return (
    <div style={{
      position: 'absolute', left: 12, right: 12, bottom: 14, zIndex: 30,
      display: 'grid', gridTemplateColumns: 'repeat(5,1fr)',
      background: 'rgba(255,255,255,0.96)',
      backdropFilter: 'saturate(140%) blur(14px)',
      WebkitBackdropFilter: 'saturate(140%) blur(14px)',
      borderRadius: 22, border: `1px solid ${GH_BORDER}`,
      boxShadow: '0 12px 30px rgba(0,0,0,0.14), 0 2px 6px rgba(0,0,0,0.08)',
      padding: '6px 4px',
    }}>
      {tabs.map((t) =>
      <button key={t.id} onClick={() => onChange(t.id)} style={{
        background: active === t.id ? GH_GREEN_LIGHT : 'none',
        border: 'none', padding: '8px 0', cursor: 'pointer', borderRadius: 14,
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
        color: active === t.id ? GH_GREEN : GH_FG_FAINT,
        font: '700 10px/1 Helvetica, Arial, sans-serif',
        transition: 'background 160ms',
      }}>
          <Icon name={t.icon} size={20} />
          {t.label}
        </button>
      )}
    </div>);

};

// --- Progress bar (nutrition deviation) ------------------------
const Progress = ({ value, target, label, unit = '' }) => {
  const pct = Math.min(150, value / target * 100);
  const dev = Math.abs(value - target) / target;
  const color = dev <= 0.10 ? GH_GREEN : dev <= 0.30 ? GH_WARN : GH_ERR;
  return (
    <div style={{ display: 'grid', gridTemplateColumns: '110px 1fr 110px', gap: 12, alignItems: 'center' }}>
      <div style={{ font: '700 13px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>{label}</div>
      <div style={{ height: 8, background: GH_BORDER, borderRadius: 99, overflow: 'hidden' }}>
        <div style={{ height: '100%', width: `${Math.min(100, pct)}%`, background: color, borderRadius: 99 }} />
      </div>
      <div style={{ font: '700 12px/1 Roboto, Helvetica, sans-serif', color: GH_FG_MUTED, textAlign: 'right' }}>
        {value} / {target} {unit}
      </div>
    </div>);

};

// --- Stat block -------------------------------------------------
const Stat = ({ label, value, sub, tone, icon, illustrated, onClick }) => {
  const colorMap = { warn: GH_WARN, err: GH_ERR, ok: GH_GREEN };
  const valueColor = tone ? colorMap[tone] : GH_FG;
  return (
    <Card padding={14} onClick={onClick} style={{ display: 'flex', flexDirection: 'column', gap: 4, position: 'relative' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        {icon && !illustrated && <Icon name={icon} size={14} color={GH_FG_MUTED} />}
        <div style={{ font: '700 10px/1 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, textTransform: 'uppercase', letterSpacing: '0.08em' }}>{label}</div>
      </div>
      <div style={{ font: '700 24px/1 Helvetica, Arial, sans-serif', color: valueColor }}>{value}</div>
      {sub && <div style={{ font: '400 11px/1.3 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{sub}</div>}
      {illustrated && (
        <div style={{ position: 'absolute', top: 10, right: 10, opacity: 0.95 }}>
          <II name={illustrated} size={32} />
        </div>
      )}
    </Card>);

};

// --- Field ------------------------------------------------------
const Field = ({ label, value, onChange, placeholder, type = 'text', error, hint, suffix, readOnly }) =>
<label style={{ display: 'block' }}>
    {label && <div style={{ font: '700 10px/1.4 Helvetica, Arial, sans-serif', textTransform: 'uppercase', letterSpacing: '0.08em', color: GH_FG_MUTED, marginBottom: 6 }}>{label}</div>}
    <div style={{ position: 'relative' }}>
      <input
      type={type} value={value || ''} readOnly={readOnly}
      onChange={(e) => onChange && onChange(e.target.value)} placeholder={placeholder}
      style={{
        width: '100%', boxSizing: 'border-box',
        border: `1.5px solid ${error ? GH_ERR : GH_BORDER}`, borderRadius: 8,
        padding: '12px 14px', paddingRight: suffix ? 50 : 14,
        font: '700 16px/1.2 Helvetica, Arial, sans-serif',
        color: GH_FG, background: '#fff', outline: 'none'
      }} />
    
      {suffix && <div style={{ position: 'absolute', right: 14, top: '50%', transform: 'translateY(-50%)', font: '700 13px/1 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{suffix}</div>}
    </div>
    {hint && !error && <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 4 }}>{hint}</div>}
    {error && <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_ERR, marginTop: 4 }}>{error}</div>}
  </label>;


// --- Select (mock dropdown) -------------------------------------
const Select = ({ label, value, onChange, options }) =>
<label style={{ display: 'block' }}>
    {label && <div style={{ font: '700 10px/1.4 Helvetica, Arial, sans-serif', textTransform: 'uppercase', letterSpacing: '0.08em', color: GH_FG_MUTED, marginBottom: 6 }}>{label}</div>}
    <div style={{ position: 'relative' }}>
      <select value={value || ''} onChange={(e) => onChange && onChange(e.target.value)}
    style={{
      width: '100%', boxSizing: 'border-box', appearance: 'none',
      border: `1.5px solid ${GH_BORDER}`, borderRadius: 8,
      padding: '12px 38px 12px 14px',
      font: '700 16px/1.2 Helvetica, Arial, sans-serif',
      color: GH_FG, background: '#fff', outline: 'none'
    }}>
        {options.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
      </select>
      <div style={{ position: 'absolute', right: 12, top: '50%', transform: 'translateY(-50%)', pointerEvents: 'none', color: GH_FG_MUTED }}>
        <Icon name="chevD" size={18} />
      </div>
    </div>
  </label>;


// --- Species avatar ---------------------------------------------
const SPECIES_SRC = {
  cattle: 'assets/species/cattle.svg',
  goat: 'assets/species/goat.svg',
  sheep: 'assets/species/sheep.svg'
};
const SpeciesAvatar = ({ species = 'cattle', size = 48, light }) =>
<div style={{
  width: size, height: size, borderRadius: 8,
  background: light ? '#F0F7EB' : GH_GREEN_LIGHT,
  display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0
}}>
    <img src={SPECIES_SRC[species] || `assets/species/${species}.svg`} width={size - 10} height={size - 10} alt={species} style={{ objectFit: 'contain' }} />
  </div>;


// --- Tag pill (plain selection chip) ---------------------------
const Chip = ({ children, active, onClick }) =>
<button onClick={onClick} style={{
  border: 'none', borderRadius: 99, padding: '8px 14px', cursor: 'pointer',
  background: active ? GH_GREEN : '#fff',
  color: active ? '#fff' : GH_FG,
  font: '700 13px/1 Helvetica, Arial, sans-serif',
  boxShadow: active ? 'none' : `inset 0 0 0 1px ${GH_BORDER}`,
  whiteSpace: 'nowrap', textTransform: 'capitalize'
}}>{children}</button>;


// --- Status mapping ----------------------------------------
const TAG_LOOKUP = {
  PREGNANT: { label: 'Pregnant', tone: 'primary' },
  LACTATING: { label: 'Lactating', tone: 'primary' },
  READY_TO_BREED: { label: 'Ready to breed', tone: 'primary' },
  WEANING: { label: 'Weaning', tone: 'info' },
  CULL: { label: 'Cull flagged', tone: 'warning' },
  SOLD: { label: 'Sold', tone: 'neutral' },
  MISCARRIAGE: { label: 'Miscarriage', tone: 'warning' },
  STILLBORN: { label: 'Stillbirth', tone: 'warning' },
  SICK: { label: 'Sick', tone: 'error' },
  FATTENING: { label: 'Fattening', tone: 'info' }
};
const StatusTag = ({ tag }) => {
  const t = TAG_LOOKUP[tag];
  if (!t) return null;
  return <Badge tone={t.tone}>{t.label}</Badge>;
};

// --- Bottom sheet ----------------------------------------------
const Sheet = ({ open, onClose, title, children, footer }) => {
  if (!open) return null;
  return (
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.40)',
      zIndex: 50, display: 'flex', alignItems: 'flex-end', animation: 'gh-fade 200ms ease'
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        background: '#fff', width: '100%', maxHeight: '88%',
        borderRadius: '20px 20px 0 0', overflow: 'hidden',
        display: 'flex', flexDirection: 'column',
        animation: 'gh-slide 220ms cubic-bezier(0.2,0,0,1)'
      }}>
        <div style={{ padding: '8px 0 0', display: 'flex', justifyContent: 'center' }}>
          <div style={{ width: 40, height: 4, borderRadius: 99, background: GH_BORDER }} />
        </div>
        <div style={{ padding: '12px 16px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ font: '700 18px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>{title}</div>
          <button onClick={onClose} style={{ background: 'none', border: 'none', padding: 8, cursor: 'pointer', color: GH_FG_MUTED }}>
            <Icon name="close" size={22} />
          </button>
        </div>
        <div style={{ flex: 1, overflowY: 'auto', padding: '4px 16px 16px' }}>{children}</div>
        {footer && <div style={{ padding: '12px 16px 24px', borderTop: `1px solid ${GH_BORDER}`, background: '#fff' }}>{footer}</div>}
      </div>
    </div>);

};

// --- Empty/info banner ----------------------------------------
const InfoBanner = ({ tone = 'primary', icon = 'info', title, body, action, onAction }) => {
  const tones = {
    primary: { bg: GH_GREEN_LIGHT, edge: GH_GREEN, fg: GH_GREEN, sub: '#1F3416' },
    warning: { bg: '#FFFBEB', edge: GH_WARN_LIGHT, fg: GH_WARN, sub: GH_FG_MUTED },
    error: { bg: '#FEF2F2', edge: GH_ERR_LIGHT, fg: GH_ERR, sub: GH_FG_MUTED }
  };
  const t = tones[tone];
  return (
    <Card padding={14} style={{ background: t.bg, borderColor: t.edge }}>
      <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
        <div style={{ width: 32, height: 32, borderRadius: 8, background: tone === 'primary' ? GH_GREEN : t.fg, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <Icon name={icon} size={18} />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ font: '700 14px/1.3 Helvetica, Arial, sans-serif', color: t.fg }}>{title}</div>
          {body && <div style={{ font: '400 13px/1.5 Helvetica, Arial, sans-serif', color: t.sub, marginTop: 4 }}>{body}</div>}
          {action && <div style={{ marginTop: 10 }}><Button variant={tone === 'primary' ? 'primary' : 'outline'} size="sm" onClick={onAction}>{action}</Button></div>}
        </div>
      </div>
    </Card>);

};

// --- Logo ----------------------------------------------------
const Logo = ({ size = 32 }) =>
<div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
    <img
    src="assets/logo-bull.png"
    width={size}
    height={size}
    alt="GreenerHerd"
    style={{ borderRadius: 6, display: 'block', objectFit: 'cover' }} />
    <div style={{ font: '700 16px/1 Helvetica, Arial, sans-serif', color: GH_GREEN, letterSpacing: '-0.01em' }}>Greener Herd</div>
  </div>;


Object.assign(window, {
  GH_GREEN, GH_GREEN_HOVER, GH_GREEN_LIGHT, GH_BORDER, GH_GREY_BG,
  GH_FG, GH_FG_MUTED, GH_FG_FAINT, GH_WARN, GH_WARN_LIGHT, GH_ERR, GH_ERR_LIGHT, GH_OK, GH_OK_LIGHT,
  Icon, II, ILLUSTRATED_ICONS,
  Button, Badge, Card, SectionHeader, AppBar, TabBar, Progress, Stat,
  Field, Select, SpeciesAvatar, Chip, StatusTag, TAG_LOOKUP, Sheet, InfoBanner, Logo
});