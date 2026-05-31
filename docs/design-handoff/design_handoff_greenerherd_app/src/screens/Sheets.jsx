// GreenerHerd — Sheets / modals
const NewTaskSheet = ({ open, onClose, params }) => {
  const animal = params?.animal;
  const [title, setTitle] = React.useState('');
  const [assignee, setAssignee] = React.useState('u3');
  const [date, setDate] = React.useState('Tomorrow');
  const [recur, setRecur] = React.useState('NONE');
  React.useEffect(() => {
    if (open) setTitle(animal ? `Check ${animal.name !== '—' ? animal.name : `#${animal.tag}`}` : '');
  }, [open, animal?.id]);
  return (
    <Sheet open={open} onClose={onClose} title={animal ? `New task · #${animal.tag}` : 'New task'}
    footer={<Button full onClick={onClose}>Create task</Button>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14, paddingTop: 8 }}>
        {animal &&
        <Card padding={10} style={{ background: GH_GREEN_LIGHT, borderColor: GH_GREEN }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <SpeciesAvatar species={animal.species} size={32} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: '700 13px Helvetica, Arial, sans-serif', color: GH_GREEN }}>For #{animal.tag}{animal.name !== '—' ? ` · ${animal.name}` : ''}</div>
                <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_GREEN }}>{animal.breed} · {animal.age}</div>
              </div>
            </div>
          </Card>
        }
        <Field label="Title" value={title} onChange={setTitle} placeholder="e.g. Refill mineral block" />
        <Field label="Description" value="" onChange={() => {}} placeholder="Optional notes" />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Select label="Assigned to" value={assignee} onChange={setAssignee} options={[
          { value: 'u1', label: 'Yusuf · Owner' },
          { value: 'u2', label: 'Khaled · Manager' },
          { value: 'u3', label: 'Ahmad · Farm hand' },
          { value: 'u4', label: 'Dr. Rashed · Vet' }]
          } />
          <Field label="Due date" value={date} onChange={setDate} />
        </div>
        <Select label="Recurrence" value={recur} onChange={setRecur} options={[
        { value: 'NONE', label: 'No recurrence' },
        { value: 'DAILY', label: 'Daily' },
        { value: 'WEEKLY', label: 'Weekly' },
        { value: 'MONTHLY', label: 'Monthly' }]
        } />
        <Select label="Reminder" value="1_DAY" onChange={() => {}} options={[
        { value: 'SAME_DAY', label: 'Same day' },
        { value: '1_DAY', label: '1 day before' },
        { value: '3_DAYS', label: '3 days before' },
        { value: '7_DAYS', label: '7 days before' }]
        } />
      </div>
    </Sheet>);

};

const VoiceTaskSheet = ({ open, onClose }) => {
  const [recording, setRecording] = React.useState(false);
  const [phase, setPhase] = React.useState('idle'); // idle / recording / transcribed
  const [transcript, setTranscript] = React.useState('');
  React.useEffect(() => {
    if (!open) {setPhase('idle');setTranscript('');}
  }, [open]);
  const startRec = () => {
    setPhase('recording');
    setTimeout(() => {
      setPhase('transcribed');
      setTranscript('Move sick sheep Najma S009 to the isolation pen tomorrow morning, and ask Dr Rashed to check her tomorrow afternoon.');
    }, 1800);
  };
  return (
    <Sheet open={open} onClose={onClose} title="Voice add"
    footer={phase === 'transcribed' && <Button full onClick={onClose}>Create 2 tasks</Button>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14, paddingTop: 12, alignItems: 'center' }}>
        <div style={{ position: 'relative', width: 96, height: 96, borderRadius: 99, background: phase === 'recording' ? GH_ERR_LIGHT : GH_GREEN_LIGHT, color: phase === 'recording' ? GH_ERR : GH_GREEN, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          {phase === 'recording' &&
          <div style={{ position: 'absolute', inset: -8, borderRadius: 99, border: `3px solid ${GH_ERR}`, opacity: 0.4, animation: 'gh-pulse 1.4s ease-out infinite' }} />
          }
          <Icon name="mic" size={36} />
        </div>
        <div style={{ font: '700 16px Helvetica, Arial, sans-serif', color: GH_FG }}>
          {phase === 'idle' && 'Tap to record'}
          {phase === 'recording' && 'Listening… speak in any language'}
          {phase === 'transcribed' && 'Transcribed'}
        </div>
        <div style={{ font: '400 13px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, textAlign: 'center', maxWidth: 280 }}>
          {phase === 'idle' && 'Speak in EN, AR, UR or FR. Greener Herd will create tasks from what you say.'}
          {phase === 'recording' && '0:02 / 0:30'}
          {phase === 'transcribed' && 'Review and confirm — edit before saving.'}
        </div>
        {phase === 'idle' && <Button onClick={startRec} icon="mic">Start recording</Button>}
        {phase === 'recording' && <Button variant="danger" onClick={() => {setPhase('transcribed');setTranscript('Move sick sheep Najma S009 to the isolation pen tomorrow morning, and ask Dr Rashed to check her tomorrow afternoon.');}}>Stop</Button>}
        {phase === 'transcribed' &&
        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 12 }}>
            <Card padding={12} style={{ background: GH_GREY_BG, border: 'none', boxShadow: 'none' }}>
              <LabelXS>Transcript</LabelXS>
              <div style={{ font: '400 14px/1.5 Helvetica, Arial, sans-serif', color: GH_FG, marginTop: 6 }}>"{transcript}"</div>
            </Card>
            <LabelXS>Detected tasks</LabelXS>
            <Card padding={12}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
                <Icon name="arrow" size={16} color={GH_GREEN} style={{ marginTop: 2 }} />
                <div>
                  <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>Move Najma #S009 to isolation pen</div>
                  <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>Tomorrow morning · assigned to Ahmad</div>
                </div>
              </div>
            </Card>
            <Card padding={12}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
                <Icon name="syringe" size={16} color={GH_GREEN} style={{ marginTop: 2 }} />
                <div>
                  <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>Vet check · Najma #S009</div>
                  <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>Tomorrow afternoon · assigned to Dr. Rashed</div>
                </div>
              </div>
            </Card>
          </div>
        }
      </div>
    </Sheet>);

};

const RecordMilkSheet = ({ open, onClose, params }) => {
  const { ANIMALS } = window.GH;
  const animals = (params?.group ? ANIMALS.filter((a) => a.group === params.group.id) : []).filter((a) => a.sex === 'F');
  const [vals, setVals] = React.useState({});
  const total = Object.values(vals).reduce((s, v) => s + (parseFloat(v) || 0), 0);
  return (
    <Sheet open={open} onClose={onClose} title={`Record milk · ${params?.group?.name || ''}`}
    footer={
    <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
          <div style={{ flex: 1 }}>
            <LabelXS>Total</LabelXS>
            <div style={{ font: '700 18px Helvetica, Arial, sans-serif', color: GH_GREEN }}>{total.toFixed(1)} L</div>
          </div>
          <Button onClick={onClose}>Save · 8 May</Button>
        </div>}>
      <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
        <Chip active>Morning</Chip>
        <Chip>Evening</Chip>
        <Chip>Both</Chip>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 100px', font: '700 10px Helvetica, Arial, sans-serif', textTransform: 'uppercase', color: GH_FG_MUTED, letterSpacing: '0.08em', padding: '0 4px 6px', borderBottom: `1px solid ${GH_BORDER}` }}>
          <div>Animal</div><div style={{ textAlign: 'right' }}>Litres</div>
        </div>
        {animals.length === 0 &&
        ['Bessie #0421', 'Mona #0438', 'Sara #0444', 'Hala #0451', 'Khulud #0470'].map((label) =>
        <MilkInputRow key={label} label={label} val={vals[label] || ''} onChange={(v) => setVals((s) => ({ ...s, [label]: v }))} />
        )
        }
        {animals.map((a) =>
        <MilkInputRow key={a.id} label={`${a.name !== '—' ? a.name : ''} #${a.tag}`} sub={a.withdrawal ? `Withdrawal · ${a.withdrawal} d` : null} val={vals[a.id] || ''} onChange={(v) => setVals((s) => ({ ...s, [a.id]: v }))} />
        )}
      </div>
    </Sheet>);

};

const MilkInputRow = ({ label, val, onChange, sub }) =>
<div style={{ display: 'grid', gridTemplateColumns: '1fr 100px', alignItems: 'center', gap: 8, padding: '8px 4px', borderBottom: `1px solid ${GH_BORDER}` }}>
    <div>
      <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{label}</div>
      {sub && <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_WARN, marginTop: 2 }}>{sub}</div>}
    </div>
    <input type="number" inputMode="decimal" value={val} onChange={(e) => onChange(e.target.value)} placeholder="0.0"
  style={{ border: `1.5px solid ${GH_BORDER}`, borderRadius: 8, padding: '8px 12px', font: '700 16px Helvetica, Arial, sans-serif', textAlign: 'right', color: GH_FG, outline: 'none', width: '100%', boxSizing: 'border-box' }} />
  </div>;


const RecordFeedingSheet = ({ open, onClose, params }) => {
  return (
    <Sheet open={open} onClose={onClose} title={`Record feeding · ${params?.group?.name || ''}`}
    footer={<Button full onClick={onClose}>Save feeding</Button>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <Select label="Meal type" value="Morning Mix" onChange={() => {}} options={[
        { value: 'Morning Mix', label: 'Morning Mix · alfalfa + barley' },
        { value: 'Afternoon', label: 'Afternoon · corn silage' },
        { value: 'custom', label: '+ Create new meal type' }]
        } />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Field label="Total weight" value="148" onChange={() => {}} suffix="kg" />
          <Field label="Per head" value="6.7" readOnly suffix="kg" hint="Computed · 22 head" />
        </div>
        <Field label="Date" value="8 May 2026" readOnly />
        <Field label="Notes" value="" onChange={() => {}} placeholder="Optional" />
        <Card padding={12} style={{ background: GH_GREY_BG, border: 'none', boxShadow: 'none' }}>
          <LabelXS>Composition · 1 batch</LabelXS>
          <div style={{ marginTop: 8, font: '400 13px/1.6 Helvetica, Arial, sans-serif', color: GH_FG }}>
            Alfalfa hay 90 kg · Barley 38 kg · Wheat bran 16 kg · Mineral mix 4 kg
          </div>
        </Card>
      </div>
    </Sheet>);

};

const RecordVaccinationSheet = ({ open, onClose, params }) => {
  const [booster, setBooster] = React.useState('Yes');
  return (
    <Sheet open={open} onClose={onClose} title={`Vaccination · ${params?.group?.name || ''}`}
    footer={<Button full onClick={onClose}>Save · auto-create booster task</Button>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <Select label="Vaccine" value="FMD" onChange={() => {}} options={[
        { value: 'FMD', label: 'FMD (Foot and Mouth Disease)' },
        { value: 'Brucellosis', label: 'Brucellosis' },
        { value: 'Lumpy Skin', label: 'Lumpy Skin Disease' },
        { value: 'Other', label: 'Other / custom' }]
        } />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Field label="Date" value="8 May 2026" readOnly />
          <Field label="Batch #" value="" onChange={() => {}} placeholder="optional" />
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Field label="Milk withdrawal" value="3" suffix="d" onChange={() => {}} />
          <Field label="Meat withdrawal" value="14" suffix="d" onChange={() => {}} />
        </div>
        <div>
          <LabelXS>Requires booster?</LabelXS>
          <div style={{ display: 'flex', gap: 8, marginTop: 6 }}>
            {['Yes', 'No'].map((v) => <Chip key={v} active={booster === v} onClick={() => setBooster(v)}>{v}</Chip>)}
          </div>
        </div>
        {booster === 'Yes' &&
        <Select label="Booster interval" value="4" onChange={() => {}} options={[
        { value: '4', label: '4 weeks' }, { value: '6', label: '6 weeks' },
        { value: '8', label: '8 weeks' }, { value: '10', label: '10 weeks' }, { value: '12', label: '12 weeks' }]
        } />
        }
        <InfoBanner tone="primary" icon="info"
        title="Auto-task will be created"
        body="Booster: FMD due 5 Jun 2026 · 7-day reminder · assigned to Ahmad." />
      </div>
    </Sheet>);

};

const RecordHealthSheet = ({ open, onClose, params }) =>
<Sheet open={open} onClose={onClose} title={`Treatment · ${params?.animal ? '#' + params.animal.tag : ''}`}
footer={<Button full onClick={onClose}>Save treatment</Button>}>
    <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      <Field label="Illness / condition" value="" onChange={() => {}} placeholder="e.g. Mastitis" />
      <Select label="Medicine" value="penicillin" onChange={() => {}} options={[
    { value: 'penicillin', label: 'Penicillin G · 6 vials in stock' },
    { value: 'oxytetra', label: 'Oxytetracycline · 4 vials in stock' },
    { value: 'new', label: '+ Add new medicine' }]
    } />
      <Field label="Dosage" value="5 ml IM" onChange={() => {}} />
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <Field label="Date applied" value="8 May 2026" readOnly />
        <Select label="Frequency" value="DAILY" onChange={() => {}} options={[
      { value: 'ONCE', label: 'Once' }, { value: 'DAILY', label: 'Daily' },
      { value: 'WEEKLY', label: 'Weekly' }, { value: 'MONTHLY', label: 'Monthly' }]
      } />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <Field label="Milk withdrawal" value="3" suffix="d" onChange={() => {}} hint="Auto-filled" />
        <Field label="Meat withdrawal" value="7" suffix="d" onChange={() => {}} hint="Auto-filled" />
      </div>
      <InfoBanner tone="warning" icon="info"
    title="Recurring treatment"
    body="Daily for 5 days · we'll create reminder tasks at 06:00." />
    </div>
  </Sheet>;


const AddAnimalSheet = ({ open, onClose }) => {
  const { BREEDS } = window.GH;
  const [step, setStep] = React.useState(1);
  const [data, setData] = React.useState({
    species: 'cattle', sex: 'F', breed: 'Holstein',
    origin: 'BORN', purchaseDate: '', supplier: '', purchasePrice: '',
    dob: '', size: 'Medium', vigour: 'Average', assistance: 'None', twin: false,
    weight: '', height: '', tag: '', name: '', group: 'g4', sire: '', dam: '', notes: ''
  });
  React.useEffect(() => {
    if (!open) {
      setStep(1);
      setData({
        species: 'cattle', sex: 'F', breed: 'Holstein',
        origin: 'BORN', purchaseDate: '', supplier: '', purchasePrice: '',
        dob: '', size: 'Medium', vigour: 'Average', assistance: 'None', twin: false,
        weight: '', height: '', tag: '', name: '', group: 'g4', sire: '', dam: '', notes: ''
      });
    }
  }, [open]);

  // When species changes, reset breed to first available
  const onSpecies = (s) => setData((d) => ({ ...d, species: s, breed: (BREEDS[s] || ['Other'])[0] }));

  const breedOptions = (BREEDS[data.species] || []).map((b) => ({ value: b, label: b }));

  return (
    <Sheet open={open} onClose={onClose} title="Add animal"
    footer={
    step === 1 ? <Button full onClick={() => setStep(2)}>Continue</Button> :
    step === 2 ? <div style={{ display: 'flex', gap: 8 }}>
            <Button variant="outline" onClick={() => setStep(1)}>Back</Button>
            <Button full onClick={() => setStep(3)}>Continue</Button>
          </div> :
    <div style={{ display: 'flex', gap: 8 }}>
            <Button variant="outline" onClick={() => setStep(2)}>Back</Button>
            <Button full onClick={onClose}>Save animal</Button>
          </div>
    }>
      <div style={{ display: 'flex', gap: 6, marginBottom: 14 }}>
        {[1, 2, 3].map((s) =>
        <div key={s} style={{ flex: 1, height: 4, borderRadius: 99, background: s <= step ? GH_GREEN : GH_BORDER }} />
        )}
      </div>

      {/* STEP 1 — Species, origin, tag/name */}
      {step === 1 &&
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <div>
            <LabelXS>Species</LabelXS>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8, marginTop: 6 }}>
              {['cattle', 'goat', 'sheep'].map((s) =>
            <button key={s} onClick={() => onSpecies(s)} style={{
              border: `1.5px solid ${data.species === s ? GH_GREEN : GH_BORDER}`, borderRadius: 12,
              background: data.species === s ? '#F0F7EB' : '#fff', padding: 14, cursor: 'pointer',
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6
            }}>
                  <SpeciesAvatar species={s} size={40} light />
                  <div style={{ font: '700 13px Helvetica, Arial, sans-serif', color: GH_FG, textTransform: 'capitalize' }}>{s === 'cattle' ? 'Cattle' : s === 'goat' ? 'Goat' : 'Sheep'}</div>
                </button>
            )}
            </div>
          </div>
          <div>
            <LabelXS>Origin</LabelXS>
            <div style={{ display: 'flex', gap: 8, marginTop: 6 }}>
              {[['BORN', 'Born on farm'], ['PURCHASED', 'Purchased']].map(([k, l]) =>
            <Chip key={k} active={data.origin === k} onClick={() => setData({ ...data, origin: k })}>{l}</Chip>
            )}
            </div>
          </div>
          <Field label="Ear tag" value={data.tag} onChange={(v) => setData({ ...data, tag: v })} placeholder="e.g. 0473" />
          <Field label="Name (optional)" value={data.name} onChange={(v) => setData({ ...data, name: v })} placeholder="e.g. Salwa" hint="You can add this later." />
        </div>
      }

      {/* STEP 2 — branching: Born-on-farm vs Purchased details */}
      {step === 2 &&
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <div>
            <LabelXS>Sex</LabelXS>
            <div style={{ display: 'flex', gap: 8, marginTop: 6 }}>
              {[['F', 'Female'], ['M', 'Male']].map(([k, l]) =>
            <Chip key={k} active={data.sex === k} onClick={() => setData({ ...data, sex: k })}>{l}</Chip>
            )}
            </div>
          </div>

          <Select label={`Breed (${data.species})`} value={data.breed} onChange={(v) => setData({ ...data, breed: v })} options={breedOptions} />

          {data.origin === 'BORN' ?
        <>
              <Field label="Date of birth" value={data.dob} onChange={(v) => setData({ ...data, dob: v })} type="date" />
              <Card padding={12} style={{ background: '#F0F7EB', border: `1px solid ${GH_GREEN_LIGHT}`, boxShadow: 'none' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
                  <Icon name="baby" size={18} color={GH_GREEN} />
                  <div style={{ font: '700 13px Helvetica, Arial, sans-serif', color: GH_GREEN }}>Newborn details</div>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                  <Select label="Size at birth" value={data.size} onChange={(v) => setData({ ...data, size: v })} options={[
              { value: 'Small', label: 'Small' },
              { value: 'Medium', label: 'Medium' },
              { value: 'Large', label: 'Large' }]
              } />
                  <Select label="Vigour" value={data.vigour} onChange={(v) => setData({ ...data, vigour: v })} options={[
              { value: 'Weak', label: 'Weak' },
              { value: 'Average', label: 'Average' },
              { value: 'Strong', label: 'Strong' }]
              } />
                </div>
                <div style={{ marginTop: 10 }}>
                  <Select label="Birthing assistance" value={data.assistance} onChange={(v) => setData({ ...data, assistance: v })} options={[
              { value: 'None', label: 'None — natural birth' },
              { value: 'Easy pull', label: 'Easy pull (1 person)' },
              { value: 'Hard pull', label: 'Hard pull (2+ people)' },
              { value: 'Vet assisted', label: 'Vet assisted' },
              { value: 'C-section', label: 'C-section' }]
              } />
                </div>
                <label style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 10, cursor: 'pointer' }}>
                  <input type="checkbox" checked={data.twin} onChange={(e) => setData({ ...data, twin: e.target.checked })} />
                  <span style={{ font: '400 13px Helvetica, Arial, sans-serif', color: GH_FG }}>This animal is a twin</span>
                </label>
              </Card>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <Field label="Weight" value={data.weight} onChange={(v) => setData({ ...data, weight: v })} suffix="kg" hint="Birth weight" />
                <Field label="Height" value={data.height} onChange={(v) => setData({ ...data, height: v })} suffix="cm" />
              </div>
            </> :

        <>
              <Field label="Purchase date" value={data.purchaseDate} onChange={(v) => setData({ ...data, purchaseDate: v })} type="date" />
              <Field label="Date of birth (if known)" value={data.dob} onChange={(v) => setData({ ...data, dob: v })} type="date" hint="Or pick an age range below." />
              <Select label="Age range (if DOB unknown)" value="" onChange={() => {}} options={[
          { value: '', label: 'Pick a range…' },
          { value: '0_3M', label: '0–3 months' }, { value: '3_6M', label: '3–6 months' },
          { value: '6_12M', label: '6–12 months' }, { value: '1_2Y', label: '1–2 years' },
          { value: '2_3Y', label: '2–3 years' }, { value: '3_5Y', label: '3–5 years' },
          { value: '5PLUS_Y', label: '5+ years' }]
          } />
              <Field label="Supplier / source" value={data.supplier} onChange={(v) => setData({ ...data, supplier: v })} placeholder="e.g. Al-Wafi Genetics, market, neighbour…" />
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <Field label="Purchase price" value={data.purchasePrice} onChange={(v) => setData({ ...data, purchasePrice: v })} suffix="SAR" />
                <Field label="Weight" value={data.weight} onChange={(v) => setData({ ...data, weight: v })} suffix="kg" />
              </div>
            </>
        }
        </div>
      }

      {/* STEP 3 — group + parents + notes */}
      {step === 3 &&
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Select label="Group" value={data.group} onChange={(v) => setData({ ...data, group: v })} options={[
        { value: 'g4', label: 'Calves · cattle' }, { value: 'g1', label: 'Milking A · cattle' },
        { value: 'g2', label: 'Breeding · cattle' }, { value: 'g5', label: 'Maintenance B · goat' },
        { value: 'g8', label: 'Najdi flock · sheep' },
        { value: '', label: '+ Create new group' }]
        } />
          <Field label="Sire (optional)" value={data.sire} onChange={(v) => setData({ ...data, sire: v })} placeholder="Search or enter" />
          <Field label="Dam (optional)" value={data.dam} onChange={(v) => setData({ ...data, dam: v })} placeholder="Search or enter" />
          <Field label="Notes" value={data.notes} onChange={(v) => setData({ ...data, notes: v })} placeholder="Anything else worth recording" />
          <Card padding={12} style={{ background: GH_GREY_BG, border: 'none', boxShadow: 'none' }}>
            <div style={{ font: '700 13px Helvetica, Arial, sans-serif', color: GH_FG }}>You're adding</div>
            <div style={{ font: '400 13px/1.5 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 4 }}>
              1 {data.species} · {data.sex === 'F' ? 'Female' : 'Male'} · {data.breed}<br />
              Origin: {data.origin === 'BORN' ? 'Born on farm' : `Purchased${data.supplier ? ' from ' + data.supplier : ''}`}
              {data.tag && <> · #{data.tag}</>}
            </div>
          </Card>
        </div>
      }
    </Sheet>);

};

// --- Edit existing animal ---------------------------------------
const EditAnimalSheet = ({ open, onClose, params }) => {
  const { BREEDS, GROUPS } = window.GH;
  const a = params?.animal;
  const [data, setData] = React.useState(null);
  React.useEffect(() => {
    if (open && a) {
      setData({
        tag: a.tag, name: a.name === '—' ? '' : a.name,
        species: a.species, sex: a.sex, breed: a.breed,
        dob: a.dob || '', wt: a.wt || '', bcs: a.bcs || '',
        group: a.group, sire: a.sire || '', dam: a.dam || ''
      });
    }
  }, [open, a?.id]);
  if (!data) return null;

  const breedOptions = (BREEDS[data.species] || []).map((b) => ({ value: b, label: b }));
  const groupOptions = GROUPS.filter((g) => g.species === data.species).map((g) => ({ value: g.id, label: `${g.name} · ${g.species}` }));

  const onSave = () => {
    // Persist back into the live data — prototype-grade
    if (a) {
      a.tag = data.tag;a.name = data.name || '—';
      a.sex = data.sex;a.breed = data.breed;
      a.dob = data.dob;a.wt = parseInt(data.wt) || a.wt;
      if (data.bcs) a.bcs = parseFloat(data.bcs);
      a.group = data.group;a.sire = data.sire;a.dam = data.dam;
    }
    onClose();
  };

  return (
    <Sheet open={open} onClose={onClose} title={`Edit · #${a?.tag || ''}`}
    footer={<div style={{ display: 'flex', gap: 8 }}>
        <Button variant="outline" onClick={onClose}>Cancel</Button>
        <Button full onClick={onSave}>Save changes</Button>
      </div>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Field label="Ear tag" value={data.tag} onChange={(v) => setData({ ...data, tag: v })} />
          <Field label="Name" value={data.name} onChange={(v) => setData({ ...data, name: v })} placeholder="optional" />
        </div>
        <div>
          <LabelXS>Sex</LabelXS>
          <div style={{ display: 'flex', gap: 8, marginTop: 6 }}>
            {[['F', 'Female'], ['M', 'Male']].map(([k, l]) =>
            <Chip key={k} active={data.sex === k} onClick={() => setData({ ...data, sex: k })}>{l}</Chip>
            )}
          </div>
        </div>
        <Select label="Breed" value={data.breed} onChange={(v) => setData({ ...data, breed: v })} options={breedOptions} />
        <Field label="Date of birth" value={data.dob} onChange={(v) => setData({ ...data, dob: v })} type="date" />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Field label="Weight" value={data.wt} onChange={(v) => setData({ ...data, wt: v })} suffix="kg" />
          <Field label="BCS" value={data.bcs} onChange={(v) => setData({ ...data, bcs: v })} suffix="/ 5" />
        </div>
        <Select label="Group" value={data.group} onChange={(v) => setData({ ...data, group: v })} options={groupOptions.length ? groupOptions : [{ value: data.group, label: 'No groups for species' }]} />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Field label="Sire" value={data.sire} onChange={(v) => setData({ ...data, sire: v })} placeholder="optional" />
          <Field label="Dam" value={data.dam} onChange={(v) => setData({ ...data, dam: v })} placeholder="optional" />
        </div>
      </div>
    </Sheet>);

};

window.NewTaskSheet = NewTaskSheet;
window.VoiceTaskSheet = VoiceTaskSheet;
window.RecordMilkSheet = RecordMilkSheet;
window.RecordFeedingSheet = RecordFeedingSheet;
window.RecordVaccinationSheet = RecordVaccinationSheet;
window.RecordHealthSheet = RecordHealthSheet;
window.AddAnimalSheet = AddAnimalSheet;
window.EditAnimalSheet = EditAnimalSheet;

// --- Add group sheet ---------------------------------------------
const AddGroupSheet = ({ open, onClose }) => {
  const { ANIMALS } = window.GH;
  const [name, setName] = React.useState('');
  const [species, setSpecies] = React.useState('cattle');
  const [purpose, setPurpose] = React.useState('MILK');
  const [manager, setManager] = React.useState('u2');
  const [desc, setDesc] = React.useState('');
  const [selected, setSelected] = React.useState({});
  const [origin, setOrigin] = React.useState('existing'); // existing | born | purchased

  const eligible = ANIMALS.filter((a) => a.species === species);
  const selectedCount = Object.values(selected).filter(Boolean).length;
  React.useEffect(() => {setSelected({});}, [species, origin]);

  return (
    <Sheet open={open} onClose={onClose} title="New group"
    footer={
    <Button full onClick={onClose}>
        Create group{selectedCount > 0 ? ` · ${selectedCount} animal${selectedCount === 1 ? '' : 's'}` : ''}
      </Button>
    }>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14, paddingTop: 8 }}>
        <Field label="Group name" value={name} onChange={setName} placeholder="e.g. Milking B" />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Select label="Species" value={species} onChange={setSpecies} options={[
          { value: 'cattle', label: 'Cattle' },
          { value: 'goat', label: 'Goats' },
          { value: 'sheep', label: 'Sheep' }]
          } />
          <Select label="Purpose" value={purpose} onChange={setPurpose} options={window.GH.PURPOSES} />
        </div>
        <Select label="Manager" value={manager} onChange={setManager} options={[
        { value: 'u1', label: 'Yusuf · Owner' },
        { value: 'u2', label: 'Khaled · Manager' },
        { value: 'u3', label: 'Ahmad · Farm hand' },
        { value: 'u4', label: 'Dr. Rashed · Vet' }]
        } />
        <Field label="Description" value={desc} onChange={setDesc} placeholder="Housing, feeding cadence, notes" />

        {/* Animal source selector */}
        <div>
          <LabelXS>Group of livestock</LabelXS>
          <div style={{ display: 'flex', gap: 6, marginTop: 8, background: GH_GREY_BG, borderRadius: 10, padding: 4 }}>
            {[
            { k: 'existing', l: 'Existing' },
            { k: 'born', l: 'New (born)' },
            { k: 'purchased', l: 'New (purchased)' }].
            map((o) =>
            <button key={o.k} onClick={() => setOrigin(o.k)} style={{
              flex: 1, border: 'none', cursor: 'pointer', borderRadius: 8, padding: '8px 6px',
              background: origin === o.k ? '#fff' : 'transparent',
              color: origin === o.k ? GH_GREEN : GH_FG_MUTED,
              font: '700 12px Helvetica, Arial, sans-serif',
              boxShadow: origin === o.k ? '0 1px 3px rgba(0,0,0,0.08)' : 'none'
            }}>{o.l}</button>
            )}
          </div>
        </div>

        {origin === 'existing' ?
        <Card padding={0}>
            <div style={{ padding: '10px 14px', borderBottom: `1px solid ${GH_BORDER}`, font: '700 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, textTransform: 'uppercase', letterSpacing: '0.06em' }}>
              {eligible.length} {species} available
            </div>
            <div style={{ maxHeight: 220, overflowY: 'auto' }}>
              {eligible.map((a, i) => {
              const on = !!selected[a.id];
              return (
                <div key={a.id} onClick={() => setSelected((s) => ({ ...s, [a.id]: !on }))} style={{
                  display: 'flex', alignItems: 'center', gap: 12, padding: '10px 14px',
                  borderBottom: i === eligible.length - 1 ? 'none' : `1px solid ${GH_BORDER}`,
                  cursor: 'pointer', background: on ? GH_GREEN_LIGHT : '#fff'
                }}>
                    <SpeciesAvatar species={a.species} size={32} />
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ font: '700 13px Helvetica, Arial, sans-serif', color: GH_FG }}>{a.name !== '—' ? a.name : ''} #{a.tag}</div>
                      <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{a.breed} · {a.wt} kg</div>
                    </div>
                    <div style={{
                    width: 22, height: 22, borderRadius: 6, flexShrink: 0,
                    border: `1.5px solid ${on ? GH_GREEN : GH_BORDER}`,
                    background: on ? GH_GREEN : '#fff', color: '#fff',
                    display: 'flex', alignItems: 'center', justifyContent: 'center'
                  }}>{on && <Icon name="checkPlain" size={14} />}</div>
                  </div>);

            })}
              {eligible.length === 0 &&
            <div style={{ padding: 16, textAlign: 'center', font: '400 13px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>
                  No {species} on the farm yet.
                </div>
            }
            </div>
          </Card> :

        <NewLivestockList origin={origin} species={species} />
        }
      </div>
    </Sheet>);

};
window.AddGroupSheet = AddGroupSheet;

// --- Inline "new livestock" list (born / purchased) -----------------
const NewLivestockList = ({ origin, species }) => {
  const [items, setItems] = React.useState([]);
  const add = () => setItems(it => [...it, { id: `nl${Date.now()}_${Math.random().toString(36).slice(2,5)}`, tag: '', sex: 'F', breed: '', dob: '', wt: '', dam: '', sire: '', supplier: '', price: '' }]);
  const update = (id, patch) => setItems(it => it.map(x => x.id === id ? { ...x, ...patch } : x));
  const remove = (id) => setItems(it => it.filter(x => x.id !== id));
  const label = origin === 'born' ? 'newborn' : 'purchased';
  return (
    <Card padding={0}>
      <div style={{ padding: '10px 14px', borderBottom: `1px solid ${GH_BORDER}`, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ font: '700 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, textTransform: 'uppercase', letterSpacing: '0.06em' }}>
          {items.length} {label} animal{items.length === 1 ? '' : 's'}
        </div>
        <button onClick={add} style={{
          background: GH_GREEN, color: '#fff', border: 'none', borderRadius: 8,
          font: '700 12px Helvetica, Arial, sans-serif', padding: '6px 10px', cursor: 'pointer',
          display: 'inline-flex', alignItems: 'center', gap: 4,
        }}><Icon name="plus" size={14} /> Add {label}</button>
      </div>
      {items.length === 0 && (
        <div style={{ padding: 18, textAlign: 'center', font: '400 13px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>
          Tap <strong style={{ color: GH_FG }}>Add {label}</strong> to register one or more {species} now.
        </div>
      )}
      {items.map((it, idx) => (
        <div key={it.id} style={{ padding: 14, borderTop: idx === 0 ? 'none' : `1px solid ${GH_BORDER}`, display: 'flex', flexDirection: 'column', gap: 10 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ font: '700 13px Helvetica, Arial, sans-serif', color: GH_FG }}>
              {label.charAt(0).toUpperCase() + label.slice(1)} #{idx + 1}
            </div>
            <button onClick={() => remove(it.id)} style={{
              background: 'none', border: 'none', cursor: 'pointer', color: GH_FG_FAINT, padding: 4,
              display: 'inline-flex', alignItems: 'center', gap: 4,
            }}><Icon name="close" size={14} /> Remove</button>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Field label="Tag" value={it.tag} onChange={v => update(it.id, { tag: v })} placeholder="e.g. 0532" />
            <Select label="Sex" value={it.sex} onChange={v => update(it.id, { sex: v })} options={[
              { value: 'F', label: 'Female' },
              { value: 'M', label: 'Male' },
            ]} />
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Field label="Breed" value={it.breed} onChange={v => update(it.id, { breed: v })} placeholder={species === 'cattle' ? 'Holstein' : species === 'goat' ? 'Aardi' : 'Najdi'} />
            <Field label="Weight (kg)" value={it.wt} onChange={v => update(it.id, { wt: v })} type="number" placeholder="0" />
          </div>
          {origin === 'born' ? (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <Field label="Dam" value={it.dam} onChange={v => update(it.id, { dam: v })} placeholder="Search tag/name" />
              <Field label="Sire (optional)" value={it.sire} onChange={v => update(it.id, { sire: v })} placeholder="—" />
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <Field label="Supplier" value={it.supplier} onChange={v => update(it.id, { supplier: v })} placeholder="e.g. Al-Wafi farms" />
              <Field label="Price (SAR)" value={it.price} onChange={v => update(it.id, { price: v })} type="number" placeholder="0" />
            </div>
          )}
        </div>
      ))}
      {items.length > 0 && (
        <div style={{ padding: '12px 14px', borderTop: `1px solid ${GH_BORDER}`, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>Adding {items.length} to the group on save</div>
          <button onClick={add} style={{
            background: 'none', color: GH_GREEN, border: 'none', cursor: 'pointer',
            font: '700 13px Helvetica, Arial, sans-serif', padding: 4,
            display: 'inline-flex', alignItems: 'center', gap: 4,
          }}><Icon name="plus" size={14} /> Add another</button>
        </div>
      )}
    </Card>
  );
};
window.NewLivestockList = NewLivestockList;

// --- Edit task sheet (with media + voice notes) ------------------
const EditTaskSheet = ({ open, onClose, params }) => {
  const t = params?.task || { title: '', sub: '', when: '', recur: 'NONE', overdue: false };
  const [title, setTitle] = React.useState(t.title);
  const [desc, setDesc] = React.useState(t.sub || '');
  const [assignee, setAssignee] = React.useState(t.assignee || 'u3');
  const [date, setDate] = React.useState(t.when || 'Today');
  const [recur, setRecur] = React.useState(t.recur || 'NONE');
  const [photos, setPhotos] = React.useState(t.photos || []);
  const [voiceNotes, setVoiceNotes] = React.useState(t.voiceNotes || []);
  const [recording, setRecording] = React.useState(false);
  const [recordSec, setRecordSec] = React.useState(0);
  const fileRef = React.useRef(null);
  const recIntRef = React.useRef(null);

  // Reset state when sheet (re)opens with new task
  React.useEffect(() => {
    if (open) {
      setTitle(t.title);
      setDesc(t.sub || '');
      setAssignee(t.assignee || 'u3');
      setDate(t.when || 'Today');
      setRecur(t.recur || 'NONE');
      setPhotos(t.photos || []);
      setVoiceNotes(t.voiceNotes || []);
      setRecording(false);
      setRecordSec(0);
    }
    // eslint-disable-next-line
  }, [open, params?.task?.id]);

  const onPickPhotos = (e) => {
    const files = Array.from(e.target.files || []);
    const readers = files.map((f) => new Promise((res) => {
      const r = new FileReader();
      r.onload = () => res({ id: `p${Date.now()}_${Math.random().toString(36).slice(2, 6)}`, url: r.result, name: f.name });
      r.readAsDataURL(f);
    }));
    Promise.all(readers).then((items) => setPhotos((p) => [...p, ...items]));
    e.target.value = '';
  };

  const startRec = () => {
    setRecording(true);
    setRecordSec(0);
    recIntRef.current = setInterval(() => setRecordSec((s) => s + 1), 1000);
  };
  const stopRec = () => {
    clearInterval(recIntRef.current);
    setRecording(false);
    const dur = recordSec;
    if (dur > 0) {
      setVoiceNotes((v) => [...v, { id: `v${Date.now()}`, duration: dur, at: 'just now' }]);
    }
    setRecordSec(0);
  };
  React.useEffect(() => () => clearInterval(recIntRef.current), []);

  const fmt = (s) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;

  return (
    <Sheet open={open} onClose={onClose} title="Edit task"
    footer={
    <div style={{ display: 'flex', gap: 10 }}>
          <Button variant="outline" onClick={onClose} style={{ flex: 1 }}>Cancel</Button>
          <Button onClick={onClose} style={{ flex: 2 }}>Save changes</Button>
        </div>
    }>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14, paddingTop: 8 }}>
        <Field label="Title" value={title} onChange={setTitle} placeholder="Task title" />
        <Field label="Description" value={desc} onChange={setDesc} placeholder="Optional notes" />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Select label="Assigned to" value={assignee} onChange={setAssignee} options={[
          { value: 'u1', label: 'Yusuf · Owner' },
          { value: 'u2', label: 'Khaled · Manager' },
          { value: 'u3', label: 'Ahmad · Farm hand' },
          { value: 'u4', label: 'Dr. Rashed · Vet' }]
          } />
          <Field label="Due date" value={date} onChange={setDate} />
        </div>
        <Select label="Recurrence" value={recur} onChange={setRecur} options={[
        { value: 'NONE', label: 'No recurrence' },
        { value: 'DAILY', label: 'Daily' },
        { value: 'WEEKLY', label: 'Weekly' },
        { value: 'MONTHLY', label: 'Monthly' }]
        } />

        {/* Photos */}
        <div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
            <div style={{ font: '700 10px/1.4 Helvetica, Arial, sans-serif', textTransform: 'uppercase', letterSpacing: '0.08em', color: GH_FG_MUTED }}>Photos · {photos.length}</div>
            <button onClick={() => fileRef.current && fileRef.current.click()} style={{
              background: 'none', border: 'none', cursor: 'pointer', color: GH_GREEN,
              font: '700 13px/1 Helvetica, Arial, sans-serif', padding: 4,
              display: 'inline-flex', alignItems: 'center', gap: 6
            }}>
              <Icon name="camera" size={16} /> Add photos
            </button>
            <input ref={fileRef} type="file" accept="image/*" multiple onChange={onPickPhotos} style={{ display: 'none' }} />
          </div>
          {photos.length === 0 ?
          <button onClick={() => fileRef.current && fileRef.current.click()} style={{
            width: '100%', padding: '18px 14px', border: `1.5px dashed ${GH_BORDER}`, borderRadius: 10,
            background: '#fff', cursor: 'pointer', color: GH_FG_MUTED,
            font: '400 13px/1.4 Helvetica, Arial, sans-serif',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6
          }}>
              <Icon name="camera" size={20} color={GH_GREEN} />
              Add photos of the animal, equipment, or scene
            </button> :

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8 }}>
              {photos.map((p) =>
            <div key={p.id} style={{ position: 'relative', aspectRatio: '1 / 1', borderRadius: 10, overflow: 'hidden', background: GH_GREY_BG }}>
                  <img src={p.url} alt={p.name} style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }} />
                  <button onClick={() => setPhotos((ph) => ph.filter((x) => x.id !== p.id))} style={{
                position: 'absolute', top: 4, right: 4, width: 22, height: 22, borderRadius: 99,
                background: 'rgba(0,0,0,0.55)', color: '#fff', border: 'none', cursor: 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center'
              }}><Icon name="close" size={14} /></button>
                </div>
            )}
            </div>
          }
        </div>

        {/* Voice notes */}
        <div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
            <div style={{ font: '700 10px/1.4 Helvetica, Arial, sans-serif', textTransform: 'uppercase', letterSpacing: '0.08em', color: GH_FG_MUTED }}>Voice notes · {voiceNotes.length}</div>
          </div>

          {/* Recorder */}
          <div style={{
            padding: 14, borderRadius: 12, border: `1.5px solid ${recording ? GH_ERR : GH_BORDER}`,
            background: recording ? '#FEF2F2' : '#fff',
            display: 'flex', alignItems: 'center', gap: 12
          }}>
            <button onClick={recording ? stopRec : startRec} style={{
              width: 44, height: 44, borderRadius: 99, border: 'none', cursor: 'pointer',
              background: recording ? GH_ERR : GH_GREEN, color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
              position: 'relative'
            }}>
              <Icon name={recording ? 'pause' : 'mic'} size={20} />
              {recording && <span style={{
                position: 'absolute', inset: -4, borderRadius: 99,
                border: `2px solid ${GH_ERR}`, animation: 'gh-pulse 1.2s ease-out infinite'
              }} />}
            </button>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ font: '700 14px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>
                {recording ? `Recording · ${fmt(recordSec)}` : 'Tap to record a note'}
              </div>
              <div style={{ font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>
                {recording ? 'Tap again to stop' : 'Up to 2 minutes · transcribed automatically'}
              </div>
            </div>
          </div>

          {/* Existing voice notes */}
          {voiceNotes.length > 0 &&
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: 10 }}>
              {voiceNotes.map((v, i) =>
            <div key={v.id} style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '10px 12px', borderRadius: 10, background: GH_GREY_BG
            }}>
                  <button style={{
                width: 32, height: 32, borderRadius: 99, border: 'none', cursor: 'pointer',
                background: GH_GREEN, color: '#fff',
                display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0
              }}>
                    <Icon name="play" size={14} />
                  </button>
                  {/* faux waveform */}
                  <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 2, height: 24 }}>
                    {Array.from({ length: 28 }).map((_, k) => {
                  const h = 4 + Math.abs(Math.sin((k + i * 3) * 0.7)) * 18;
                  return <div key={k} style={{ flex: 1, height: h, background: GH_GREEN, opacity: 0.55, borderRadius: 1 }} />;
                })}
                  </div>
                  <div style={{ font: '700 12px/1 Roboto, Helvetica, sans-serif', color: GH_FG_MUTED, minWidth: 36, textAlign: 'right' }}>{fmt(v.duration)}</div>
                  <button onClick={() => setVoiceNotes((vs) => vs.filter((x) => x.id !== v.id))} style={{
                background: 'none', border: 'none', cursor: 'pointer', color: GH_FG_FAINT, padding: 4
              }}><Icon name="trash" size={16} /></button>
                </div>
            )}
            </div>
          }
        </div>

        {/* Destructive */}
        <button onClick={onClose} style={{
          marginTop: 4, background: 'none', border: 'none', cursor: 'pointer',
          color: GH_ERR, font: '700 14px/1 Helvetica, Arial, sans-serif', padding: '12px 4px',
          display: 'inline-flex', alignItems: 'center', gap: 6, alignSelf: 'flex-start'
        }}>
          <Icon name="trash" size={16} /> Delete task
        </button>
      </div>
    </Sheet>);

};

window.EditTaskSheet = EditTaskSheet;

// --- Generic "Add new" chooser (animal vs group) -----------------
const AddChooserSheet = ({ open, onClose, onPickAnimal, onPickGroup }) => {
  const { ANIMALS, GROUPS } = window.GH;
  return (
    <Sheet open={open} onClose={onClose} title="Add new">
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, paddingTop: 4, paddingBottom: 12 }}>
        <button onClick={() => {onClose();setTimeout(() => onPickAnimal && onPickAnimal(), 0);}} style={chooserRowStyle}>
          <div style={chooserIconBox}><Icon name="plus" size={20} /></div>
          <div style={{ flex: 1, textAlign: 'left' }}>
            <div style={{ font: '700 15px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>New animal</div>
            <div style={{ font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>
              Tag, species, breed, weight · born or purchased
            </div>
          </div>
          <Icon name="chevR" size={16} color={GH_FG_FAINT} />
        </button>
        <button onClick={() => {onClose();setTimeout(() => onPickGroup && onPickGroup(), 0);}} style={chooserRowStyle}>
          <div style={chooserIconBox}><Icon name="users" size={20} /></div>
          <div style={{ flex: 1, textAlign: 'left' }}>
            <div style={{ font: '700 15px/1.2 Helvetica, Arial, sans-serif', color: GH_FG }}>New group</div>
            <div style={{ font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>
              Bundle existing or newly-added animals
            </div>
          </div>
          <Icon name="chevR" size={16} color={GH_FG_FAINT} />
        </button>
        <div style={{ font: '400 11px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_FAINT, textAlign: 'center', marginTop: 4 }}>
          {ANIMALS.length} animals · {GROUPS.length} groups on the farm
        </div>
      </div>
    </Sheet>);

};
const chooserRowStyle = {
  display: 'flex', alignItems: 'center', gap: 12,
  padding: '14px 14px', border: `1.5px solid ${GH_BORDER}`, borderRadius: 12,
  background: '#fff', cursor: 'pointer', width: '100%'
};
const chooserIconBox = {
  width: 40, height: 40, borderRadius: 10, background: GH_GREEN_LIGHT, color: GH_GREEN,
  display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0
};
window.AddChooserSheet = AddChooserSheet;

// --- Move animal between groups ----------------------------------
const MoveAnimalSheet = ({ open, onClose, params }) => {
  const animal = params?.animal;
  const onMoved = params?.onMoved;
  const { GROUPS } = window.GH;
  if (!animal) return null;
  const candidates = GROUPS.filter((g) => g.species === animal.species);
  return (
    <Sheet open={open} onClose={onClose} title={`Move #${animal.tag}`}>
      <div style={{ paddingTop: 4, paddingBottom: 12, display: 'flex', flexDirection: 'column', gap: 8 }}>
        <div style={{ font: '400 13px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginBottom: 6 }}>
          Currently in <strong style={{ color: GH_FG }}>{(GROUPS.find((g) => g.id === animal.group) || {}).name || '—'}</strong>. Pick a destination:
        </div>
        {candidates.map((g) => {
          const here = g.id === animal.group;
          return (
            <button key={g.id} disabled={here} onClick={() => {
              animal.group = g.id;
              onMoved && onMoved();
              onClose();
            }} style={{
              display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
              border: `1.5px solid ${here ? GH_GREEN : GH_BORDER}`, borderRadius: 12,
              background: here ? GH_GREEN_LIGHT : '#fff', cursor: here ? 'default' : 'pointer',
              textAlign: 'left', opacity: here ? 0.7 : 1
            }}>
              <SpeciesAvatar species={g.species} size={36} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{g.name}</div>
                <div style={{ font: '400 12px Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{g.purpose.toLowerCase()} · {g.count} head</div>
              </div>
              {here ? <Badge tone="primary">Current</Badge> : <Icon name="arrow" size={16} color={GH_GREEN} />}
            </button>);

        })}
      </div>
    </Sheet>);

};
window.MoveAnimalSheet = MoveAnimalSheet;

// --- Add finance entry (income / expense) ------------------------
const AddFinanceEntrySheet = ({ open, onClose }) => {
  const [type, setType] = React.useState('INCOME');
  const [amount, setAmount] = React.useState('');
  const [cat, setCat] = React.useState('Milk sale');
  const [date, setDate] = React.useState('Today');
  const [desc, setDesc] = React.useState('');
  const incomeCats = ['Milk sale', 'Animal sale', 'Manure', 'Subsidy', 'Other income'];
  const expenseCats = ['Feed', 'Veterinary', 'Labour', 'Utilities', 'Fuel', 'Equipment', 'Other expense'];
  const cats = type === 'INCOME' ? incomeCats : expenseCats;
  React.useEffect(() => {setCat(cats[0]);}, [type]);

  return (
    <Sheet open={open} onClose={onClose} title="New entry"
    footer={<Button full onClick={onClose}>Save entry</Button>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14, paddingTop: 8 }}>
        {/* Type toggle */}
        <div style={{ display: 'flex', gap: 6, background: GH_GREY_BG, borderRadius: 10, padding: 4 }}>
          {[
          { k: 'INCOME', l: 'Income', c: GH_GREEN },
          { k: 'EXPENSE', l: 'Expense', c: '#80A5F9' }].
          map((o) =>
          <button key={o.k} onClick={() => setType(o.k)} style={{
            flex: 1, border: 'none', cursor: 'pointer', borderRadius: 8, padding: '10px 6px',
            background: type === o.k ? '#fff' : 'transparent',
            color: type === o.k ? o.c : GH_FG_MUTED,
            font: '700 14px Helvetica, Arial, sans-serif',
            boxShadow: type === o.k ? '0 1px 3px rgba(0,0,0,0.08)' : 'none'
          }}>{o.l}</button>
          )}
        </div>
        <Field label="Amount (SAR)" value={amount} onChange={setAmount} placeholder="0" type="number" suffix="SAR" />
        <Select label="Category" value={cat} onChange={setCat} options={cats.map((c) => ({ value: c, label: c }))} />
        <Field label="Date" value={date} onChange={setDate} placeholder="Today" />
        <Field label="Description" value={desc} onChange={setDesc} placeholder="Optional notes" />
      </div>
    </Sheet>);

};
window.AddFinanceEntrySheet = AddFinanceEntrySheet;

// --- Status change sheet (cull / breeding / pregnancy outcomes) -----
const StatusChangeSheet = ({ open, onClose, params }) => {
  const animal = params?.animal;
  const onChanged = params?.onChanged;
  const [mode, setMode] = React.useState('menu'); // menu | confirmPregnant | calving
  const [gest, setGest] = React.useState('9');
  const [prolif, setProlif] = React.useState('1');
  const [calveOutcome, setCalveOutcome] = React.useState('born'); // born | stillborn | miscarriage

  React.useEffect(() => {if (open) {setMode('menu');setGest('9');setProlif('1');setCalveOutcome('born');}}, [open, animal?.id]);
  if (!animal) return null;

  const has = (t) => animal.tags.includes(t);
  const setTags = (newTags) => {animal.tags = newTags;onChanged && onChanged();};
  const removeTag = (t) => setTags(animal.tags.filter((x) => x !== t));
  const addTag = (t) => setTags(animal.tags.includes(t) ? animal.tags : [...animal.tags, t]);
  const replaceTag = (from, to) => setTags(animal.tags.filter((x) => x !== from).concat(to ? [to] : []));

  // Default per-species gestation suggestion (months)
  const defaultGest = { cattle: 9, goat: 5, sheep: 5 }[animal.species] || 9;
  React.useEffect(() => {if (open && mode === 'confirmPregnant') setGest(String(defaultGest));}, [mode, defaultGest, open]);

  const title = mode === 'menu' ? `Status · #${animal.tag}` :
  mode === 'confirmPregnant' ? 'Confirm pregnancy' :
  'Calving outcome';

  return (
    <Sheet open={open} onClose={onClose} title={title}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, paddingTop: 4, paddingBottom: 12 }}>
        {/* Current status summary */}
        <Card padding={10} style={{ background: GH_GREY_BG, border: 'none' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <SpeciesAvatar species={animal.species} size={32} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ font: '700 13px Helvetica, Arial, sans-serif', color: GH_FG }}>{animal.name !== '—' ? animal.name : ''} #{animal.tag}</div>
              <div style={{ display: 'flex', gap: 4, marginTop: 4, flexWrap: 'wrap' }}>
                {animal.tags.length > 0 ? animal.tags.map((t) => <StatusTag key={t} tag={t} />) : <span style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>No status</span>}
              </div>
            </div>
          </div>
        </Card>

        {mode === 'menu' &&
        <>
            {/* Cull workflow */}
            {has('CULL') ?
          <>
                <StatusOption icon="wallet" label="Mark as sold" sub="Records sale and retires animal" onClick={() => {replaceTag('CULL', 'SOLD');onClose();}} />
                <StatusOption illustrated="tag-id" label="Clear cull flag" sub="Animal stays in herd" onClick={() => {removeTag('CULL');onClose();}} />
              </> :
          has('SOLD') ?
          <StatusOption icon="back" label="Undo sale" sub="Restore to active herd" onClick={() => {removeTag('SOLD');onClose();}} /> :

          <StatusOption illustrated="tag-id" label="Flag for cull" sub="Add to review list" tone="warn" onClick={() => {addTag('CULL');onClose();}} />
          }

            {/* Breeding workflow */}
            {has('READY_TO_BREED') &&
          <StatusOption illustrated="breeding-confirmed" label="Mark pregnant" sub="Set gestation & prolificacy" onClick={() => setMode('confirmPregnant')} />
          }

            {/* Pregnancy outcomes */}
            {has('PREGNANT') &&
          <StatusOption illustrated="calf-feeding" label="Record calving outcome" sub="Born live · stillborn · miscarriage" onClick={() => setMode('calving')} />
          }

            {/* Generic */}
            {!has('READY_TO_BREED') && !has('PREGNANT') && !has('LACTATING') && animal.sex === 'F' &&
          <StatusOption icon="heart" label="Mark ready to breed" onClick={() => {addTag('READY_TO_BREED');onClose();}} />
          }
          </>
        }

        {mode === 'confirmPregnant' &&
        <>
            <div style={{ font: '400 13px/1.5 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>
              Confirming pregnancy will replace the <strong style={{ color: GH_FG }}>Ready to breed</strong> tag with <strong style={{ color: GH_FG }}>Pregnant</strong>.
            </div>
            <Field label="Gestation (months)" value={gest} onChange={setGest} type="number" hint={`Typical for ${animal.species}: ~${defaultGest} months`} />
            <Field label="Prolificacy (expected young)" value={prolif} onChange={setProlif} type="number" hint="1 = single, 2 = twins, etc." />
            <Field label="Conceived on" value="Today · 8 May" onChange={() => {}} />
            <Select label="Method" value="AI" onChange={() => {}} options={[
          { value: 'AI', label: 'Artificial insemination' },
          { value: 'NAT', label: 'Natural service' },
          { value: 'ET', label: 'Embryo transfer' }]
          } />
            <div style={{ display: 'flex', gap: 8 }}>
              <Button variant="outline" onClick={() => setMode('menu')}>Back</Button>
              <Button full onClick={() => {
              replaceTag('READY_TO_BREED', 'PREGNANT');
              animal.gestMonths = Number(gest) || defaultGest;
              animal.prolificacy = Number(prolif) || 1;
              onChanged && onChanged();
              onClose();
            }}>Confirm pregnancy</Button>
            </div>
          </>
        }

        {mode === 'calving' &&
        <>
            <div style={{ display: 'flex', gap: 8, background: GH_GREY_BG, borderRadius: 10, padding: 4 }}>
              {[
            { k: 'born', l: 'Born live', ill: 'calf-feeding' },
            { k: 'stillborn', l: 'Stillborn', ill: 'rip' },
            { k: 'miscarriage', l: 'Miscarriage', ill: 'sheep-sick' }].
            map((o) =>
            <button key={o.k} onClick={() => setCalveOutcome(o.k)} style={{
              flex: 1, border: 'none', cursor: 'pointer', borderRadius: 8, padding: '10px 6px',
              background: calveOutcome === o.k ? '#fff' : 'transparent',
              boxShadow: calveOutcome === o.k ? '0 1px 3px rgba(0,0,0,0.08)' : 'none',
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
              font: '700 11px Helvetica, Arial, sans-serif',
              color: calveOutcome === o.k ? GH_FG : GH_FG_MUTED
            }}>
                  <II name={o.ill} size={30} />
                  {o.l}
                </button>
            )}
            </div>
            {calveOutcome === 'born' &&
          <>
                <Field label="Number of young" value={String(animal.prolificacy || 1)} onChange={() => {}} type="number" />
                <Field label="Average birth weight (optional)" value="" onChange={() => {}} placeholder="e.g. 34" type="number" suffix="kg" />
                <Field label="Date" value="Today · 8 May" onChange={() => {}} />
                <div style={{ font: '400 12px/1.5 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>
                  Each calf will be created with its own tag. The dam will be tagged <strong style={{ color: GH_FG }}>Lactating</strong>.
                </div>
              </>
          }
            {calveOutcome === 'stillborn' &&
          <Field label="Date" value="Today · 8 May" onChange={() => {}} />
          }
            {calveOutcome === 'miscarriage' &&
          <>
                <Field label="Date" value="Today · 8 May" onChange={() => {}} />
                <Field label="Notes" value="" onChange={() => {}} placeholder="Cause if known" />
              </>
          }
            <div style={{ display: 'flex', gap: 8 }}>
              <Button variant="outline" onClick={() => setMode('menu')}>Back</Button>
              <Button full onClick={() => {
              if (calveOutcome === 'born') {
                // Pregnant → Lactating
                setTags(animal.tags.filter((t) => t !== 'PREGNANT').concat(animal.tags.includes('LACTATING') ? [] : ['LACTATING']));
              } else if (calveOutcome === 'stillborn') {
                setTags(animal.tags.filter((t) => t !== 'PREGNANT').concat(['STILLBORN']));
              } else {
                setTags(animal.tags.filter((t) => t !== 'PREGNANT').concat(['MISCARRIAGE']));
              }
              onClose();
            }}>Save outcome</Button>
            </div>
          </>
        }
      </div>
    </Sheet>);

};

const StatusOption = ({ icon, illustrated, label, sub, tone, onClick }) =>
<button onClick={onClick} style={{
  display: 'flex', alignItems: 'center', gap: 12,
  padding: '12px 14px', border: `1.5px solid ${GH_BORDER}`, borderRadius: 12,
  background: '#fff', cursor: 'pointer', width: '100%', textAlign: 'left'
}}>
    <div style={{
    width: 40, height: 40, borderRadius: 10,
    background: tone === 'warn' ? GH_WARN_LIGHT : GH_GREEN_LIGHT,
    color: tone === 'warn' ? GH_WARN : GH_GREEN,
    display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0
  }}>
      {illustrated ? <II name={illustrated} size={30} /> : <Icon name={icon} size={20} />}
    </div>
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{label}</div>
      {sub && <div style={{ font: '400 12px/1.4 Helvetica, Arial, sans-serif', color: GH_FG_MUTED, marginTop: 2 }}>{sub}</div>}
    </div>
    <Icon name="chevR" size={16} color={GH_FG_FAINT} />
  </button>;


window.StatusChangeSheet = StatusChangeSheet;

// --- Edit milk + meat prices ---------------------------------------
const EditPricesSheet = ({ open, onClose, params }) => {
  const focus = params?.focus; // 'milk' | 'meat' | undefined
  const initial = (() => {
    try { return JSON.parse(localStorage.getItem('gh_prices_v1') || '{}'); }
    catch { return {}; }
  })();
  const def = { milk: { cattle: 4.50, goat: 6.00, sheep: 5.20 }, meat: { cattle: 38, goat: 52, sheep: 46 } };
  const [prices, setPrices] = React.useState(() => ({
    milk: { ...def.milk, ...(initial.milk || {}) },
    meat: { ...def.meat, ...(initial.meat || {}) },
  }));
  React.useEffect(() => {
    if (open) setPrices({
      milk: { ...def.milk, ...(initial.milk || {}) },
      meat: { ...def.meat, ...(initial.meat || {}) },
    });
    // eslint-disable-next-line
  }, [open]);

  const set = (kind, species, v) => setPrices(p => ({ ...p, [kind]: { ...p[kind], [species]: v === '' ? '' : Number(v) } }));
  const save = () => {
    const clean = {
      milk: { cattle: +prices.milk.cattle || 0, goat: +prices.milk.goat || 0, sheep: +prices.milk.sheep || 0 },
      meat: { cattle: +prices.meat.cattle || 0, goat: +prices.meat.goat || 0, sheep: +prices.meat.sheep || 0 },
    };
    localStorage.setItem('gh_prices_v1', JSON.stringify(clean));
    window.dispatchEvent(new Event('gh-prices-changed'));
    onClose();
  };

  const Section = ({ title, unit, icon, kind }) => (
    <Card padding={14}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
        <II name={icon} size={24} />
        <div style={{ flex: 1, font: '700 14px Helvetica, Arial, sans-serif', color: GH_FG }}>{title}</div>
        <div style={{ font: '400 11px Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>{unit}</div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {['cattle','goat','sheep'].map(sp => (
          <div key={sp} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <SpeciesAvatar species={sp} size={32} light />
            <div style={{ flex: 1, font: '700 13px Helvetica, Arial, sans-serif', color: GH_FG, textTransform: 'capitalize' }}>{sp}</div>
            <div style={{ width: 130 }}>
              <Field value={String(prices[kind][sp] ?? '')} onChange={(v) => set(kind, sp, v)} type="number" suffix="SAR" />
            </div>
          </div>
        ))}
      </div>
    </Card>
  );

  return (
    <Sheet open={open} onClose={onClose} title="Sale prices"
      footer={
        <div style={{ display: 'flex', gap: 10 }}>
          <Button variant="outline" onClick={onClose} style={{ flex: 1 }}>Cancel</Button>
          <Button onClick={save} style={{ flex: 2 }}>Save prices</Button>
        </div>
      }>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14, paddingTop: 8 }}>
        <div style={{ font: '400 13px/1.5 Helvetica, Arial, sans-serif', color: GH_FG_MUTED }}>
          Update local market rates. These power revenue projections and report exports.
        </div>
        {(!focus || focus === 'milk') && <Section title="Milk · per litre" unit="SAR / L" icon="bottle" kind="milk" />}
        {(!focus || focus === 'meat') && <Section title="Meat · per kg"    unit="SAR / kg" icon="sale"   kind="meat" />}
      </div>
    </Sheet>
  );
};
window.EditPricesSheet = EditPricesSheet;