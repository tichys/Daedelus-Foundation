import { useBackend, useSharedState } from '../../backend';
import { Box, Button, Dropdown, Input, NoticeBox, Section, Flex, LabeledList, ColorBox, Icon, Table, Tabs } from '../../components';
import { Window } from '../../layouts';
import { CharacterPreview } from '../PreferencesMenu/CharacterPreview';
import { C, term, TermBox, TermHeader, TermLabel, TermValue, TermRow, TermDivider, TermButton, PriorityButtons } from './shared';

const TABS = [
  { key: 'overview', label: 'OVERVIEW' },
  { key: 'faction', label: 'FACTION' },
  { key: 'jobs', label: 'ASSIGNMENT' },
  { key: 'custom', label: 'PERSONNEL' },
  { key: 'species', label: 'SPECIES' },
  { key: 'quirks', label: 'PSYCHE' },
  { key: 'languages', label: 'LANG' },
  { key: 'loadout', label: 'EQUIP' },
  { key: 'augments', label: 'AUGMENT' },
  { key: 'mods', label: 'MODS' },
  { key: 'antags', label: 'SCP' },
  { key: 'keys', label: 'KEYS' },
  { key: 'game', label: 'SETTINGS' },
  { key: 'finalize', label: 'COMMIT' },
];

const inputStyle = { fontFamily: C.mono, fontSize: '14px', height: '32px', minHeight: '32px' };

// ── OVERVIEW PAGE ──────────────────────────────────────────────
const OverviewPage = ({ data }: any) => (
  <TermBox>
    <TermHeader>PERSONNEL SUMMARY</TermHeader>
    <TermRow><TermLabel>DESIGNATION</TermLabel><TermValue bold color={C.amber}>{data.name_to_use || 'UNASSIGNED'}</TermValue></TermRow>
    <TermRow><TermLabel>FACTION</TermLabel><TermValue>{data.faction || '—'}</TermValue></TermRow>
    <TermRow><TermLabel>CLASS</TermLabel><TermValue>{data.class || '—'}</TermValue></TermRow>
    <TermRow><TermLabel>SPECIES</TermLabel><TermValue>{data.species_names?.[data.species_id] || data.species_id || '—'}</TermValue></TermRow>
    <TermRow><TermLabel>GENDER</TermLabel><TermValue>{data.gender || '—'}</TermValue></TermRow>
    <TermRow><TermLabel>AGE</TermLabel><TermValue>{data.age || '—'}</TermValue></TermRow>
    <TermDivider />
    <TermRow><TermLabel>STATUS</TermLabel><TermValue color={data.faction_class_locked ? C.green : C.amber}>{data.faction_class_locked ? 'LOCKED' : 'UNLOCKED'}</TermValue></TermRow>
    <TermRow><TermLabel>RESET TOKENS</TermLabel><TermValue>{data.faction_class_reset_tokens || 0}</TermValue></TermRow>
  </TermBox>
);

// ── FACTION/CLASS PAGE ─────────────────────────────────────────
const FactionClassPage = () => {
  const { act, data }: any = useBackend();
  const factionToClasses: Record<string, string[]> = data.faction_to_classes || {};
  const factionLore: Record<string, string> = data.faction_lore || {};
  const classLore: Record<string, string> = data.class_lore || {};
  const factions = Object.keys(factionToClasses);
  const selectedFaction = data.faction || '';
  const classes = selectedFaction ? factionToClasses[selectedFaction] || [] : [];
  const selectedClass = data.class || '';
  const locked = !!data.faction_class_locked;
  const tokens = data.faction_class_reset_tokens || 0;
  const canAdmin = !!data.can_admin_override;
  const [confirmReset, setConfirmReset] = useSharedState('CS.confirmReset', false);
  const [confirmAdmin, setConfirmAdmin] = useSharedState('CS.confirmAdmin', false);

  return (
    <TermBox>
      <TermHeader>FACTION ASSIGNMENT</TermHeader>
      <TermRow>
        <TermLabel>FACTION</TermLabel>
        {locked ? <TermValue color={C.amber} bold>{selectedFaction || '—'}</TermValue> : (
          <Dropdown width="100%" options={factions} selected={selectedFaction} displayText={selectedFaction || 'SELECT...'} onSelected={(v: string) => act('set_faction', { value: v })} />
        )}
      </TermRow>
      <TermRow>
        <TermLabel>CLASS</TermLabel>
        {locked ? <TermValue color={C.amber} bold>{selectedClass || '—'}</TermValue> : (
          <Dropdown width="100%" options={classes} selected={selectedClass} displayText={selectedClass || 'SELECT...'} onSelected={(v: string) => act('set_class', { value: v })} />
        )}
      </TermRow>
      <TermDivider />
      <TermHeader>INTELLIGENCE BRIEFING</TermHeader>
      <TermBox style={{ marginBottom: '8px' }}>
        <TermRow><TermLabel>FACTION</TermLabel><TermValue>{selectedFaction || '—'}</TermValue></TermRow>
        <Box style={term({ color: C.textDim, fontSize: '11px', paddingLeft: '16px', fontStyle: 'italic' })}>
          {(selectedFaction && factionLore[selectedFaction]) || 'No intelligence available.'}
        </Box>
      </TermBox>
      <TermBox>
        <TermRow><TermLabel>CLASS</TermLabel><TermValue>{selectedClass || '—'}</TermValue></TermRow>
        <Box style={term({ color: C.textDim, fontSize: '11px', paddingLeft: '16px', fontStyle: 'italic' })}>
          {(selectedClass && classLore[selectedClass]) || 'No intelligence available.'}
        </Box>
      </TermBox>
      <TermDivider />
      <TermHeader>COMMITMENT</TermHeader>
      {locked ? (
        <Box>
          <TermRow><TermValue color={C.green}>FACTION/CLASS COMMITTED AND LOCKED</TermValue></TermRow>
          {tokens > 0 ? (confirmReset ? (
            <Box><NoticeBox>CONSUME ONE RESET TOKEN TO UNLOCK?</NoticeBox>
              <Box style={{ display: 'flex', gap: '4px' }}>
                <TermButton color="red" onClick={() => { setConfirmReset(false); act('request_reset_faction_class'); }}>CONFIRM</TermButton>
                <TermButton onClick={() => setConfirmReset(false)}>CANCEL</TermButton>
              </Box>
            </Box>
          ) : <TermButton color="red" onClick={() => setConfirmReset(true)}>USE RESET TOKEN ({tokens} LEFT)</TermButton>
          ) : <Box style={term({ color: C.textDim, fontSize: '11px' })}>NO RESET TOKENS AVAILABLE</Box>}
          {canAdmin && <Box style={{ marginTop: '8px' }}>{confirmAdmin ? (
            <Box style={{ display: 'flex', gap: '4px' }}>
              <TermButton color="red" onClick={() => { setConfirmAdmin(false); act('admin_override_unlock'); }}>CONFIRM ADMIN UNLOCK</TermButton>
              <TermButton onClick={() => setConfirmAdmin(false)}>CANCEL</TermButton>
            </Box>
          ) : <TermButton color="red" onClick={() => setConfirmAdmin(true)}>ADMIN OVERRIDE</TermButton>}</Box>}
        </Box>
      ) : <TermButton color="green" onClick={() => act('commit_faction_class')}>COMMIT AND LOCK</TermButton>}
    </TermBox>
  );
};

// ── JOBS PAGE ──────────────────────────────────────────────────
const JobsPage = () => {
  const { act, data }: any = useBackend();
  const available: { description: string; title: string }[] = data.available_jobs || [];
  const jobPrefs: Record<string, number> = data.job_preferences || {};
  if (!data.faction || !data.class) return <TermBox><NoticeBox>SELECT FACTION AND CLASS TO VIEW ASSIGNMENTS</NoticeBox></TermBox>;
  if (!available.length) return <TermBox><NoticeBox>NO ASSIGNMENTS AVAILABLE</NoticeBox></TermBox>;
  return (
    <TermBox>
      <TermHeader>ASSIGNMENT PREFERENCES — {data.faction?.toUpperCase()} / {data.class?.toUpperCase()}</TermHeader>
      {available.map((j) => (
        <Box key={j.title} style={{ marginBottom: '8px', borderBottom: `1px solid ${C.border}`, paddingBottom: '8px' }}>
          <Box style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <Box><TermValue bold>{j.title}</TermValue><Box style={term({ color: C.textDim, fontSize: '10px', marginTop: '2px' })}>{j.description}</Box></Box>
            <PriorityButtons job={j.title} prefs={jobPrefs[j.title]} act={act} />
          </Box>
        </Box>
      ))}
    </TermBox>
  );
};

// ── CUSTOMIZATION (PERSONNEL) PAGE ─────────────────────────────
const CustomizationPage = () => {
  const { act, data }: any = useBackend();
  const charPrefs: any = data.character_preferences || {};
  const clothing: Record<string, any> = charPrefs.clothing || {};
  const features: Record<string, any> = charPrefs.features || {};
  const secondaryFeatures: Record<string, any> = charPrefs.secondary_features || {};
  const supplementalFeatures: Record<string, any> = charPrefs.supplemental_features || {};
  const names: Record<string, any> = charPrefs.names || {};
  const nonContextual: Record<string, any> = charPrefs.non_contextual || {};
  const randomization: Record<string, any> = charPrefs.randomization || {};
  const speciesChoices: string[] = data.species_choices || [];
  const speciesNames: Record<string, string> = data.species_names || {};
  const currentSpeciesId: string = data.species_id || '';
  const genderChoices: string[] = data.gender_choices || ['male', 'female', 'plural'];
  const [nameDraft, setNameDraft] = useSharedState('CS.nameDraft', data.real_name || '');
  const [ageDraft, setAgeDraft] = useSharedState('CS.ageDraft', String(data.age ?? ''));
  const [eyeDraft, setEyeDraft] = useSharedState('CS.eyeDraft', data.eye_color || '');
  const [hairDraft, setHairDraft] = useSharedState('CS.hairDraft', data.hair_color || '');

  const renderPrefRow = (key: string, val: any) => {
    if (val === null || val === undefined) return null;
    if (typeof val === 'object' && val?.choices) {
      return (
        <TermRow key={key}>
          <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
          <Dropdown width="200px" options={val.choices} selected={val.selected} displayText={val.selected || 'SELECT...'} onSelected={(v: string) => act('set_preference', { preference: key, value: v })} />
        </TermRow>
      );
    }
    if (typeof val === 'boolean') {
      return (
        <TermRow key={key}>
          <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
          <TermButton selected={!!val} color={val ? 'green' : undefined} onClick={() => act('set_preference', { preference: key, value: !val })}>{val ? 'ON' : 'OFF'}</TermButton>
        </TermRow>
      );
    }
    if (typeof val === 'string' && val.startsWith('#')) {
      return (
        <TermRow key={key}>
          <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
          <Box style={{ display: 'flex', gap: '4px', alignItems: 'center' }}>
            <Box style={{ width: '20px', height: '20px', background: val, border: `1px solid ${C.border}` }} />
            <TermButton onClick={() => act('set_color_preference', { preference: key })}>CHANGE</TermButton>
          </Box>
        </TermRow>
      );
    }
    return <TermRow key={key}><TermLabel>{key.replace(/_/g, ' ')}</TermLabel><TermValue>{String(val)}</TermValue></TermRow>;
  };

  return (
    <TermBox>
      <TermHeader>PERSONNEL IDENTIFICATION</TermHeader>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>DESIGNATION</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', marginTop: '4px' }}>
          <Input fluid value={nameDraft} onChange={(_: any, v: string) => setNameDraft(v)} style={inputStyle} />
          <TermButton onClick={() => act('set_preference', { preference: 'real_name', value: nameDraft })}>SAVE</TermButton>
          <TermButton color="yellow" onClick={() => act('randomize_name', { preference: 'real_name' })}>RAND</TermButton>
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>AGE</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', marginTop: '4px' }}>
          <Input fluid value={ageDraft} onChange={(_: any, v: string) => setAgeDraft(v.replace(/[^0-9]/g, ''))} style={inputStyle} />
          <TermButton onClick={() => act('set_preference', { preference: 'age', value: Number(ageDraft) })}>SAVE</TermButton>
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>GENDER</TermLabel>
        <Box style={{ marginTop: '4px' }}>
          <Dropdown width="100%" options={genderChoices} selected={data.gender || ''} displayText={data.gender || 'SELECT...'} onSelected={(v: string) => act('set_preference', { preference: 'gender', value: v })} />
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>SPECIES</TermLabel>
        <Box style={{ marginTop: '4px' }}>
          <Dropdown width="100%" options={speciesChoices.map((id: string) => ({ value: id, displayText: speciesNames[id] || id }))} selected={currentSpeciesId} displayText={speciesNames[currentSpeciesId] || currentSpeciesId || 'SELECT...'} onSelected={(v: string) => act('set_preference', { preference: 'species', value: v })} />
        </Box>
      </Box>

      <TermDivider />
      <TermHeader>BIOMETRIC DATA</TermHeader>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>EYE COLOR</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', alignItems: 'center', marginTop: '4px' }}>
          <Input fluid value={eyeDraft} onChange={(_: any, v: string) => setEyeDraft(v.replace(/[^0-9A-Fa-f]/g, '').slice(0, 6))} style={inputStyle} />
          <Box style={{ width: '32px', height: '32px', background: eyeDraft ? `#${eyeDraft}` : 'transparent', border: `1px solid ${C.border}`, flexShrink: 0 }} />
          <TermButton onClick={() => act('set_preference', { preference: 'eye_color', value: eyeDraft })}>SAVE</TermButton>
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>HAIR COLOR</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', alignItems: 'center', marginTop: '4px' }}>
          <Input fluid value={hairDraft} onChange={(_: any, v: string) => setHairDraft(v.replace(/[^0-9A-Fa-f]/g, '').slice(0, 6))} style={inputStyle} />
          <Box style={{ width: '32px', height: '32px', background: hairDraft ? `#${hairDraft}` : 'transparent', border: `1px solid ${C.border}`, flexShrink: 0 }} />
          <TermButton onClick={() => act('set_preference', { preference: 'hair_color', value: hairDraft })}>SAVE</TermButton>
        </Box>
      </Box>

      <TermDivider />
      <TermHeader>CLOTHING & FEATURES</TermHeader>
      <Box style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '4px' }}>
        {Object.entries(clothing).map(([key, val]: [string, any]) => renderPrefRow(key, val))}
      </Box>

      {Object.keys(secondaryFeatures).length > 0 && (
        <>
          <TermDivider />
          <TermHeader>SPECIES FEATURES</TermHeader>
          <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {Object.entries(secondaryFeatures).map(([key, val]: [string, any]) => renderPrefRow(key, val))}
          </Box>
        </>
      )}

      {Object.keys(supplementalFeatures).length > 0 && (
        <>
          <TermDivider />
          <TermHeader>SUPPLEMENTAL</TermHeader>
          <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {Object.entries(supplementalFeatures).map(([key, val]: [string, any]) => renderPrefRow(key, val))}
          </Box>
        </>
      )}

      {Object.keys(features).length > 0 && (
        <>
          <TermDivider />
          <TermHeader>BODY FEATURES</TermHeader>
          <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {Object.entries(features).map(([key, val]: [string, any]) => renderPrefRow(key, val))}
          </Box>
        </>
      )}

      {Object.keys(names).filter((k) => k !== 'real_name').length > 0 && (
        <>
          <TermDivider />
          <TermHeader>ALTERNATE NAMES</TermHeader>
          {Object.entries(names).filter(([k]) => k !== 'real_name').map(([key, val]: [string, any]) => renderPrefRow(key, val))}
        </>
      )}

      <TermDivider />
      <Box style={{ display: 'flex', gap: '6px' }}>
        <TermButton color="yellow" onClick={() => act('randomize_character')}>RANDOMIZE ALL</TermButton>
      </Box>
    </TermBox>
  );
};

// ── SPECIES PAGE ───────────────────────────────────────────────
const SpeciesPage = () => {
  const { act, data }: any = useBackend();
  const speciesChoices: string[] = data.species_choices || [];
  const speciesNames: Record<string, string> = data.species_names || {};
  const currentSpeciesId: string = data.species_id || '';

  return (
    <TermBox>
      <TermHeader>SPECIES SELECTION</TermHeader>
      <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px', marginBottom: '12px' }}>
        {speciesChoices.map((id: string) => (
          <TermButton key={id} selected={id === currentSpeciesId} color={id === currentSpeciesId ? 'green' : undefined} onClick={() => act('set_preference', { preference: 'species', value: id })}>
            {speciesNames[id] || id}
          </TermButton>
        ))}
      </Box>
      <TermDivider />
      <Box style={term({ color: C.textDim, fontSize: '11px', fontStyle: 'italic' })}>
        Select a species to view details. Species features are available on the PERSONNEL tab after selection.
      </Box>
    </TermBox>
  );
};

// ── QUIRKS PAGE ────────────────────────────────────────────────
const QuirksPage = () => {
  const { act, data }: any = useBackend();
  const userQuirks: string[] = data.quirks || [];
  const allQuirks: string[] = data.all_quirks || [];
  const quirkInfo: Record<string, { description: string }> = data.quirk_info || {};
  const list = allQuirks.length ? allQuirks : userQuirks;
  if (!list.length) return <TermBox><NoticeBox>NO PSYCHOLOGICAL DATA ON FILE</NoticeBox></TermBox>;

  return (
    <TermBox>
      <TermHeader>PSYCHOLOGICAL EVALUATION</TermHeader>
      <Box style={term({ color: C.textDim, fontSize: '11px', marginBottom: '10px' })}>
        ACTIVE: {userQuirks.length} trait{userQuirks.length !== 1 ? 's' : ''} selected
      </Box>
      <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
        {list.map((q: string) => (
          <TermButton key={q} selected={userQuirks.includes(q)} color={userQuirks.includes(q) ? 'green' : undefined} onClick={() => act('quirk_toggle', { quirk: q })} tooltip={quirkInfo[q]?.description}>
            {q}
          </TermButton>
        ))}
      </Box>
    </TermBox>
  );
};

// ── LANGUAGES PAGE ─────────────────────────────────────────────
const LanguagesPage = () => {
  const { act, data }: any = useBackend();
  const langs: Record<string, number> = data.languages || {};
  const catalog: Record<string, string> = data.languages_catalog || {};
  const paths = Object.keys(catalog);
  if (!paths.length) return <TermBox><NoticeBox>NO LANGUAGE DATA</NoticeBox></TermBox>;
  return (
    <TermBox>
      <TermHeader>LANGUAGE PROFICIENCY</TermHeader>
      {paths.map((path) => {
        const flags = langs[path] || 0;
        const name = catalog[path] || path;
        return (
          <TermRow key={path}>
            <TermLabel style={{ flex: 1 }}>{name}</TermLabel>
            <TermButton selected={Boolean(flags & 1)} onClick={() => act('language_toggle_understand', { language: path })}>R</TermButton>
            <TermButton selected={Boolean(flags & 2)} onClick={() => act('language_toggle_speak', { language: path })}>W</TermButton>
          </TermRow>
        );
      })}
    </TermBox>
  );
};

// ── LOADOUT PAGE ───────────────────────────────────────────────
const LoadoutPage = () => {
  const { act, data }: any = useBackend();
  const loadout: { desc: string; name: string; path: string }[] = data.loadout_entries || [];
  return (
    <TermBox>
      <TermHeader>EQUIPMENT LOADOUT</TermHeader>
      {loadout.length > 0 ? loadout.map((entry) => (
        <Box key={entry.path} style={{ marginBottom: '6px', borderBottom: `1px solid ${C.border}`, paddingBottom: '6px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box><TermValue bold>{entry.name}</TermValue><Box style={term({ color: C.textDim, fontSize: '10px' })}>{entry.desc}</Box></Box>
          <TermButton onClick={() => act('loadout_toggle', { item: entry.path, change_loadout: 1 })}>TOGGLE</TermButton>
        </Box>
      )) : <Box style={term({ color: C.textDim, fontStyle: 'italic', marginBottom: '8px' })}>NO EQUIPMENT ASSIGNED</Box>}
      <TermButton onClick={() => act('open_loadout')}>OPEN EQUIPMENT INTERFACE</TermButton>
    </TermBox>
  );
};

// ── AUGMENTS PAGE ──────────────────────────────────────────────
const AugmentsPage = () => {
  const { act, data }: any = useBackend();
  const augs: Record<string, any> = data.augments || {};
  const entries = Object.entries(augs);
  return (
    <TermBox>
      <TermHeader>AUGMENTATIONS</TermHeader>
      {entries.length > 0 ? entries.map(([slot, path]: [string, any]) => (
        <TermRow key={slot} style={{ borderBottom: `1px solid ${C.border}`, paddingBottom: '6px' }}>
          <TermLabel>{slot}</TermLabel><TermValue style={{ flex: 1 }}>{String(path)}</TermValue>
          <TermButton onClick={() => act('augments_act', { switch_augment: slot })}>SWAP</TermButton>
          <TermButton color="red" onClick={() => act('augments_act', { remove_augment: slot })}>RM</TermButton>
        </TermRow>
      )) : <Box style={term({ color: C.textDim, fontStyle: 'italic', marginBottom: '8px' })}>NO AUGMENTATIONS INSTALLED</Box>}
      <TermButton onClick={() => act('augments_act', { add_augment: 'General' })}>INSTALL AUGMENTATION</TermButton>
    </TermBox>
  );
};

// ── APPEARANCE MODS PAGE ───────────────────────────────────────
const AppearanceModsPage = () => {
  const { act, data }: any = useBackend();
  const mods: Record<string, any> = data.appearance_mods || {};
  const entries = Object.keys(mods);
  return (
    <TermBox>
      <TermHeader>APPEARANCE MODIFICATIONS</TermHeader>
      {entries.length > 0 ? entries.map((type: string) => (
        <TermRow key={type} style={{ borderBottom: `1px solid ${C.border}`, paddingBottom: '6px' }}>
          <TermValue style={{ flex: 1 }}>{type}</TermValue>
          <TermButton onClick={() => act('appearance_mods_act', { modify: 1, mod_name: type })}>EDIT</TermButton>
          <TermButton color="red" onClick={() => act('appearance_mods_act', { remove: 1, mod_name: type })}>RM</TermButton>
        </TermRow>
      )) : <Box style={term({ color: C.textDim, fontStyle: 'italic', marginBottom: '8px' })}>NO MODIFICATIONS ON FILE</Box>}
      <TermButton onClick={() => act('appearance_mods_act', { add: 1 })}>ADD MODIFICATION</TermButton>
    </TermBox>
  );
};

// ── ANTAGONISTS PAGE ───────────────────────────────────────────
const AntagonistsPage = () => {
  const { act, data }: any = useBackend();
  const antags: Record<string, boolean> = data.antagonists || {};
  const entries = Object.entries(antags);
  if (!entries.length) return <TermBox><NoticeBox>NO CLASSIFIED ROLES</NoticeBox></TermBox>;
  return (
    <TermBox>
      <TermHeader>CLASSIFIED ROLE PREFERENCES</TermHeader>
      <Box style={{ display: 'flex', gap: '4px', marginBottom: '10px' }}>
        <TermButton onClick={() => act('antag_select_all')}>ALL</TermButton>
        <TermButton onClick={() => act('antag_select_all_available')}>AVAILABLE</TermButton>
        <TermButton color="red" onClick={() => act('antag_deselect_all')}>NONE</TermButton>
      </Box>
      <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
        {entries.map(([role, enabled]: [string, boolean]) => (
          <TermButton key={role} selected={!!enabled} color={enabled ? 'red' : undefined} onClick={() => act('antag_toggle', { role })}>{role}</TermButton>
        ))}
      </Box>
    </TermBox>
  );
};

// ── GAME PREFERENCES PAGE ──────────────────────────────────────
const GamePage = () => {
  const { act, data }: any = useBackend();
  const charPrefs: any = data.character_preferences || {};
  const gamePrefs: Record<string, any> = charPrefs.game_preferences || {};
  const categories: string[] = Object.keys(gamePrefs).sort();

  if (!categories.length) return <TermBox><NoticeBox>NO GAME PREFERENCES LOADED</NoticeBox></TermBox>;

  return (
    <TermBox>
      <TermHeader>SYSTEM CONFIGURATION</TermHeader>
      {categories.map((cat) => (
        <Box key={cat} style={{ marginBottom: '12px' }}>
          <TermHeader style={{ fontSize: '9px', marginBottom: '4px' }}>{cat.replace(/_/g, ' ')}</TermHeader>
          <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
            {Object.entries(gamePrefs[cat]).map(([key, val]: [string, any]) => {
              if (typeof val === 'boolean') {
                return <TermButton key={key} selected={!!val} color={val ? 'green' : undefined} onClick={() => act('set_preference', { preference: key, value: !val })}>{key.replace(/_/g, ' ')}</TermButton>;
              }
              if (typeof val === 'object' && val?.choices) {
                return (
                  <TermRow key={key}>
                    <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
                    <Dropdown width="150px" options={val.choices} selected={val.selected} displayText={val.selected || 'SELECT...'} onSelected={(v: string) => act('set_preference', { preference: key, value: v })} />
                  </TermRow>
                );
              }
              if (typeof val === 'number') {
                return <TermRow key={key}><TermLabel>{key.replace(/_/g, ' ')}</TermLabel><TermValue>{String(val)}</TermValue></TermRow>;
              }
              return null;
            })}
          </Box>
        </Box>
      ))}
    </TermBox>
  );
};

// ── KEYBINDINGS PAGE ───────────────────────────────────────────
const KeybindingsPage = () => {
  const { act, data }: any = useBackend();
  const keybindings: Record<string, string[]> = data.keybindings || {};
  const entries = Object.entries(keybindings);
  const [filter, setFilter] = useSharedState('CS.keyFilter', '');

  const filtered = filter
    ? entries.filter(([name]) => name.toLowerCase().includes(filter.toLowerCase()))
    : entries;

  return (
    <TermBox>
      <TermHeader>KEYBINDING CONFIGURATION</TermHeader>
      <Box style={{ display: 'flex', gap: '6px', marginBottom: '10px', alignItems: 'center' }}>
        <TermLabel>FILTER</TermLabel>
        <Input fluid value={filter} onChange={(_: any, v: string) => setFilter(v)} style={inputStyle} placeholder="Search bindings..." />
      </Box>
      <Box style={{ display: 'flex', gap: '6px', marginBottom: '10px' }}>
        <TermButton color="yellow" onClick={() => act('reset_all_keybinds')}>RESET ALL</TermButton>
        <TermButton onClick={() => act('reset_keybinds_to_defaults', { keybind_name: 'ALL' })}>DEFAULTS</TermButton>
      </Box>
      {filtered.length === 0 ? (
        <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>NO KEYBINDINGS FOUND</Box>
      ) : filtered.map(([name, keys]: [string, any]) => (
        <TermRow key={name}>
          <TermLabel style={{ flex: 1, fontSize: '10px' }}>{name.replace(/_/g, ' ')}</TermLabel>
          <TermValue style={{ flex: 1, fontSize: '10px' }}>{Array.isArray(keys) ? keys.join(', ') || '—' : String(keys)}</TermValue>
          <TermButton color="red" onClick={() => act('reset_keybinds_to_defaults', { keybind_name: name })}>RST</TermButton>
        </TermRow>
      ))}
    </TermBox>
  );
};

// ── FINALIZE PAGE ──────────────────────────────────────────────
const FinalizePage = ({ data, act }: any) => (
  <TermBox>
    <TermHeader>COMMIT PERSONNEL RECORD</TermHeader>
    <Box style={term({ color: C.amber, fontSize: '11px', marginBottom: '12px', borderLeft: `2px solid ${C.amber}`, paddingLeft: '8px' })}>
      WARNING: This action will persist all configuration data to the Foundation database and synchronize your personnel record. This cannot be undone.
    </Box>
    <OverviewPage data={data} />
    <TermDivider />
    <TermButton color="green" onClick={() => act('finalize')}>COMMIT TO DATABASE</TermButton>
  </TermBox>
);

// ── CHARACTER SLOT SELECTOR ────────────────────────────────────
const CharacterSlots = (props: { profiles: (string | null)[]; activeSlot: number }) => {
  const { act } = useBackend<any>();
  const { profiles, activeSlot } = props;
  return (
    <Flex justify="center" style={{ marginBottom: '4px' }}>
      <Flex.Item width="30%">
        <Dropdown width="100%" displayText={profiles[activeSlot] || `SLOT ${activeSlot + 1}`} options={profiles.map((p, i) => ({ value: i, displayText: p || `SLOT ${i + 1}` }))} onSelected={(slot: number) => act('change_slot', { slot: slot + 1 })} />
      </Flex.Item>
    </Flex>
  );
};

// ── MAIN EXPORT ────────────────────────────────────────────────
export const CharacterSetup = () => {
  const { act, data }: any = useBackend();
  const { character_preview_view, character_profiles, active_slot, content_unlocked } = data;
  const [active, setActive] = useSharedState('CS.activeTab', 'overview');

  const profiles = character_profiles || [];

  return (
    <Window title="SCP PERSONNEL CONFIGURATION TERMINAL v5.0" width={1300} height={850} theme="scp_terminal">
      <Window.Content scrollable>
        <Box style={{ background: C.bg, border: `1px solid ${C.borderRed}`, padding: 0, fontFamily: C.mono, fontSize: '12px', color: C.text, minHeight: '100%' }}>
          {/* HEADER */}
          <Box style={{ borderBottom: `2px solid ${C.borderRed}`, padding: '10px 14px 8px', background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)' }}>
            <Box style={{ fontSize: '15px', fontWeight: 'bold', color: C.amber, letterSpacing: '0.18em' }}>SCP FOUNDATION — PERSONNEL CONFIGURATION</Box>
            <Box style={{ fontSize: '9px', color: C.textDim, letterSpacing: '0.12em', marginTop: '2px' }}>TERMINAL v5.0 | CLEARANCE LEVEL 2 | CLASSIFIED | ENCRYPTION: AES-512</Box>
          </Box>

          {/* SLOT SELECTOR */}
          <Box style={{ padding: '6px 14px', borderBottom: `1px solid ${C.border}`, background: C.panel }}>
            <CharacterSlots profiles={profiles} activeSlot={(active_slot || 1) - 1} />
            {!content_unlocked && <Box style={term({ color: C.textDim, fontSize: '9px', textAlign: 'center' })}>[ CLEARANCE UPGRADE REQUIRED FOR ADDITIONAL PERSONNEL SLOTS ]</Box>}
          </Box>

          {/* TAB BAR */}
          <Box style={{ display: 'flex', borderBottom: `1px solid ${C.borderRed}`, overflowX: 'auto', background: C.panel }}>
            {TABS.map((t) => {
              const isActive = active === t.key;
              return (
                <Box key={t.key} style={{ padding: '6px 10px', cursor: 'pointer', background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent', borderRight: `1px solid ${C.border}`, borderBottom: isActive ? `2px solid ${C.amber}` : `2px solid transparent`, color: isActive ? C.textBright : C.textDim, fontSize: '9px', letterSpacing: '0.12em', textTransform: 'uppercase', fontFamily: C.mono, whiteSpace: 'nowrap', transition: 'background 0.1s' }} onClick={() => setActive(t.key)}>
                  {isActive && '▸ '}{t.label}
                </Box>
              );
            })}
          </Box>

          {/* MAIN CONTENT AREA */}
          <Box style={{ display: 'flex' }}>
            <Box style={{ flex: 1, padding: '16px', minHeight: '480px' }}>
              {active === 'overview' && <OverviewPage data={data} />}
              {active === 'faction' && <FactionClassPage />}
              {active === 'jobs' && <JobsPage />}
              {active === 'custom' && <CustomizationPage />}
              {active === 'species' && <SpeciesPage />}
              {active === 'quirks' && <QuirksPage />}
              {active === 'languages' && <LanguagesPage />}
              {active === 'loadout' && <LoadoutPage />}
              {active === 'augments' && <AugmentsPage />}
              {active === 'mods' && <AppearanceModsPage />}
              {active === 'antags' && <AntagonistsPage />}
              {active === 'keys' && <KeybindingsPage />}
              {active === 'game' && <GamePage />}
              {active === 'finalize' && <FinalizePage data={data} act={act} />}
            </Box>

            {/* RIGHT: Preview + Status */}
            <Box style={{ width: '300px', borderLeft: `1px solid ${C.border}`, background: C.panel, padding: '10px', flexShrink: 0 }}>
              <TermHeader>VISUAL RECORD</TermHeader>
              <Box style={{ height: '260px', marginBottom: '10px' }}>
                {character_preview_view ? <CharacterPreview height="100%" id={character_preview_view} /> : <Box style={term({ color: C.textDim, textAlign: 'center', paddingTop: '100px' })}>NO SIGNAL</Box>}
              </Box>
              <TermButton fluid onClick={() => act('rotate')}>ROTATE</TermButton>
              <TermDivider />
              <TermHeader>PREVIEW MODE</TermHeader>
              <Box style={{ display: 'flex', gap: '2px', marginBottom: '8px' }}>
                {(data.preview_options || []).map((opt: string) => (
                  <TermButton key={opt} selected={data.preview_selection === opt} color={data.preview_selection === opt ? 'green' : undefined} onClick={() => act('set_preview_pref', { value: opt })}>{opt.toUpperCase()}</TermButton>
                ))}
              </Box>
              <TermDivider />
              <TermHeader>SYSTEM</TermHeader>
              <Box style={term({ color: C.textDim, fontSize: '9px', lineHeight: '1.6' })}>
                <Box>LINK: NOMINAL</Box>
                <Box>NET: SECURE</Box>
                <Box>CRYPTO: AES-512</Box>
                <Box>STATUS: <Box as="span" style={{ color: C.green }}>ONLINE</Box></Box>
              </Box>
            </Box>
          </Box>

          {/* FOOTER */}
          <Box style={{ borderTop: `1px solid ${C.border}`, padding: '4px 14px', background: C.panel }}>
            <Box style={term({ color: C.textDim, fontSize: '9px', letterSpacing: '0.1em' })}>SCP FOUNDATION | SECURE CONTAIN PROTECT | ALL ACTIVITY LOGGED | UNAUTHORIZED ACCESS IS A CLASS-B INFRACTION</Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
