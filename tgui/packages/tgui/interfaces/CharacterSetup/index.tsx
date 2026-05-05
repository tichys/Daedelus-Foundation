import { useBackend, useSharedState } from '../../backend';
import { Box, Button, Dropdown, Input, NoticeBox } from '../../components';
import { Window } from '../../layouts';
import { CharacterPreview } from '../PreferencesMenu/CharacterPreview';

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  accent: '#c2960e',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenDim: '#0d4a0d',
  text: '#b0b0b0',
  textBright: '#e0e0e0',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const term = (overrides = {}) => ({
  fontFamily: C.mono,
  fontSize: '12px',
  color: C.text,
  ...overrides,
});

const TermBox = (props) => (
  <Box style={term({ ...props.style })}>{props.children}</Box>
);

const TermHeader = (props) => (
  <Box style={term({
    fontSize: '10px',
    color: C.textDim,
    letterSpacing: '0.18em',
    textTransform: 'uppercase',
    borderBottom: `1px solid ${C.border}`,
    paddingBottom: '4px',
    marginBottom: '8px',
    ...props.style,
  })}>
    {props.children}
  </Box>
);

const TermLabel = (props) => (
  <Box
    as="span"
    style={term({
      color: C.textDim,
      fontSize: '10px',
      letterSpacing: '0.12em',
      textTransform: 'uppercase',
      marginRight: '8px',
    })}
  >
    {props.children}
  </Box>
);

const TermValue = (props) => (
  <Box
    as="span"
    style={term({
      color: props.color || C.textBright,
      fontWeight: props.bold ? 'bold' : undefined,
    })}
  >
    {props.children}
  </Box>
);

const TermRow = (props) => (
  <Box style={{ marginBottom: '6px', display: 'flex', alignItems: 'center' }}>
    {props.children}
  </Box>
);

const TermDivider = () => (
  <Box style={{
    color: C.borderRed,
    fontSize: '10px',
    letterSpacing: '0.3em',
    margin: '10px 0',
    userSelect: 'none',
    overflow: 'hidden',
    whiteSpace: 'nowrap',
  }}>
    {'─'.repeat(80)}
  </Box>
);

const TermButton = (props) => {
  const selected = props.selected;
  const color = props.color;
  const bg = selected
    ? (color === 'red' ? 'rgba(139,0,0,0.35)' : color === 'green' ? 'rgba(26,122,26,0.35)' : color === 'yellow' ? 'rgba(180,160,20,0.25)' : 'rgba(255,255,255,0.08)')
    : 'transparent';
  const borderColor = selected
    ? (color === 'red' ? C.red : color === 'green' ? C.green : color === 'yellow' ? '#b0a020' : C.border)
    : C.border;

  return (
    <Button
      {...props}
      style={{
        fontFamily: C.mono,
        fontSize: '10px',
        letterSpacing: '0.1em',
        textTransform: 'uppercase',
        background: bg,
        border: `1px solid ${borderColor}`,
        borderRadius: 0,
        color: selected ? C.textBright : C.textDim,
        padding: '3px 8px',
        minWidth: props.fluid ? undefined : undefined,
        boxShadow: selected ? `0 0 6px ${borderColor}44` : 'none',
      }}
    >
      {props.children}
    </Button>
  );
};

const PriorityButtons = ({ job, prefs, act }) => (
  <Box style={{ display: 'flex', gap: '2px' }}>
    <TermButton selected={!prefs} onClick={() => act('set_job_priority', { job, level: null })}>OFF</TermButton>
    <TermButton color="red" selected={prefs === 1} onClick={() => act('set_job_priority', { job, level: 1 })}>LOW</TermButton>
    <TermButton color="yellow" selected={prefs === 2} onClick={() => act('set_job_priority', { job, level: 2 })}>MED</TermButton>
    <TermButton color="green" selected={prefs === 3} onClick={() => act('set_job_priority', { job, level: 3 })}>HIGH</TermButton>
  </Box>
);

const OverviewPage = ({ data }) => (
  <TermBox>
    <TermHeader>PERSONNEL SUMMARY</TermHeader>
    <TermRow><TermLabel>DESIGNATION</TermLabel><TermValue bold color={C.amber}>{data.name_to_use || 'UNASSIGNED'}</TermValue></TermRow>
    <TermRow><TermLabel>FACTION</TermLabel><TermValue>{data.faction || '—'}</TermValue></TermRow>
    <TermRow><TermLabel>CLASS</TermLabel><TermValue>{data.class || '—'}</TermValue></TermRow>
    <TermRow><TermLabel>STATUS</TermLabel><TermValue color={data.faction_class_locked ? C.green : C.amber}>{data.faction_class_locked ? 'LOCKED' : 'UNLOCKED'}</TermValue></TermRow>
    <TermRow><TermLabel>RESET TOKENS</TermLabel><TermValue>{data.faction_class_reset_tokens || 0}</TermValue></TermRow>
  </TermBox>
);

const FactionClassPage = () => {
  const { act, data } = useBackend<any>();
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
  const [confirmReset, setConfirmReset] = useSharedState('CharacterSetup.confirmReset', false);
  const [confirmAdmin, setConfirmAdmin] = useSharedState('CharacterSetup.confirmAdmin', false);

  return (
    <TermBox>
      <TermHeader>FACTION ASSIGNMENT</TermHeader>
      <TermRow>
        <TermLabel>FACTION</TermLabel>
        {locked ? (
          <TermValue color={C.amber} bold>{selectedFaction || '—'}</TermValue>
        ) : (
          <Dropdown
            width="100%"
            options={factions}
            selected={selectedFaction}
            displayText={selectedFaction || 'SELECT...'}
            onSelected={(value) => act('set_faction', { value })}
          />
        )}
      </TermRow>
      <TermRow>
        <TermLabel>CLASS</TermLabel>
        {locked ? (
          <TermValue color={C.amber} bold>{selectedClass || '—'}</TermValue>
        ) : (
          <Dropdown
            width="100%"
            options={classes}
            selected={selectedClass}
            displayText={selectedClass || 'SELECT...'}
            onSelected={(value) => act('set_class', { value })}
          />
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
          {tokens > 0 ? (
            confirmReset ? (
              <Box>
                <NoticeBox>CONSUME ONE RESET TOKEN TO UNLOCK?</NoticeBox>
                <Box style={{ display: 'flex', gap: '4px' }}>
                  <TermButton color="red" onClick={() => { setConfirmReset(false); act('request_reset_faction_class'); }}>CONFIRM</TermButton>
                  <TermButton onClick={() => setConfirmReset(false)}>CANCEL</TermButton>
                </Box>
              </Box>
            ) : (
              <TermButton color="red" onClick={() => setConfirmReset(true)}>USE RESET TOKEN ({tokens} LEFT)</TermButton>
            )
          ) : (
            <Box style={term({ color: C.textDim, fontSize: '11px' })}>NO RESET TOKENS AVAILABLE</Box>
          )}
          {canAdmin && (
            <Box style={{ marginTop: '8px' }}>
              {confirmAdmin ? (
                <Box style={{ display: 'flex', gap: '4px' }}>
                  <TermButton color="red" onClick={() => { setConfirmAdmin(false); act('admin_override_unlock'); }}>CONFIRM ADMIN UNLOCK</TermButton>
                  <TermButton onClick={() => setConfirmAdmin(false)}>CANCEL</TermButton>
                </Box>
              ) : (
                <TermButton color="red" onClick={() => setConfirmAdmin(true)}>ADMIN OVERRIDE</TermButton>
              )}
            </Box>
          )}
        </Box>
      ) : (
        <TermButton color="green" onClick={() => act('commit_faction_class')}>COMMIT AND LOCK</TermButton>
      )}
    </TermBox>
  );
};

const JobsPage = () => {
  const { act, data } = useBackend<any>();
  const available: { description: string; title: string }[] = data.available_jobs || [];
  const jobPrefs: Record<string, number> = data.job_preferences || {};

  if (!data.faction || !data.class) {
    return <TermBox><NoticeBox>SELECT FACTION AND CLASS TO VIEW ASSIGNMENTS</NoticeBox></TermBox>;
  }
  if (available.length === 0) {
    return <TermBox><NoticeBox>NO ASSIGNMENTS AVAILABLE</NoticeBox></TermBox>;
  }

  return (
    <TermBox>
      <TermHeader>ASSIGNMENT PREFERENCES — {data.faction?.toUpperCase()} / {data.class?.toUpperCase()}</TermHeader>
      {available.map((j) => (
        <Box key={j.title} style={{ marginBottom: '8px', borderBottom: `1px solid ${C.border}`, paddingBottom: '8px' }}>
          <Box style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <Box>
              <TermValue bold>{j.title}</TermValue>
              <Box style={term({ color: C.textDim, fontSize: '10px', marginTop: '2px' })}>{j.description}</Box>
            </Box>
            <PriorityButtons job={j.title} prefs={jobPrefs[j.title]} act={act} />
          </Box>
        </Box>
      ))}
    </TermBox>
  );
};

const inputStyle = {
  fontFamily: C.mono,
  fontSize: '14px',
  height: '32px',
  minHeight: '32px',
};

const CustomizationPage = () => {
  const { act, data } = useBackend<any>();
  const speciesChoices: string[] = data.species_choices || [];
  const speciesNames: Record<string, string> = data.species_names || {};
  const currentSpeciesId: string = data.species_id || '';
  const genderChoices: string[] = data.gender_choices || ['male', 'female', 'plural'];
  const [nameDraft, setNameDraft] = useSharedState('CharacterSetup.nameDraft', data.real_name || '');
  const [ageDraft, setAgeDraft] = useSharedState('CharacterSetup.ageDraft', String(data.age ?? ''));
  const [eyeDraft, setEyeDraft] = useSharedState('CharacterSetup.eyeDraft', data.eye_color || '');
  const [hairDraft, setHairDraft] = useSharedState('CharacterSetup.hairDraft', data.hair_color || '');

  return (
    <TermBox>
      <TermHeader>PERSONNEL IDENTIFICATION</TermHeader>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>DESIGNATION</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', marginTop: '4px' }}>
          <Input fluid value={nameDraft} onChange={(_, v) => setNameDraft(v)} style={inputStyle} />
          <TermButton onClick={() => act('set_preference', { preference: 'real_name', value: nameDraft })}>SAVE</TermButton>
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>AGE</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', marginTop: '4px' }}>
          <Input fluid value={ageDraft} onChange={(_, v) => setAgeDraft(v.replace(/[^0-9]/g, ''))} style={inputStyle} />
          <TermButton onClick={() => act('set_preference', { preference: 'age', value: Number(ageDraft) })}>SAVE</TermButton>
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>GENDER</TermLabel>
        <Box style={{ marginTop: '4px' }}>
          <Dropdown
            width="100%"
            options={genderChoices}
            selected={data.gender || ''}
            displayText={data.gender || 'SELECT...'}
            onSelected={(value) => act('set_preference', { preference: 'gender', value })}
          />
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>SPECIES</TermLabel>
        <Box style={{ marginTop: '4px' }}>
          <Dropdown
            width="100%"
            options={speciesChoices.map((id) => ({ value: id, displayText: speciesNames[id] || id }))}
            selected={currentSpeciesId}
            displayText={speciesNames[currentSpeciesId] || currentSpeciesId || 'SELECT...'}
            onSelected={(value) => act('set_preference', { preference: 'species', value })}
          />
        </Box>
      </Box>

      <TermDivider />

      <TermHeader>BIOMETRIC DATA</TermHeader>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>EYE COLOR (HEX)</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', alignItems: 'center', marginTop: '4px' }}>
          <Input fluid value={eyeDraft} onChange={(_, v) => setEyeDraft(v.replace(/[^0-9A-Fa-f]/g, '').slice(0, 6))} style={inputStyle} />
          <Box style={{
            width: '32px', height: '32px',
            background: eyeDraft ? `#${eyeDraft}` : 'transparent',
            border: `1px solid ${C.border}`,
            flexShrink: 0,
          }} />
          <TermButton onClick={() => act('set_preference', { preference: 'eye_color', value: eyeDraft })}>SAVE</TermButton>
        </Box>
      </Box>
      <Box style={{ marginBottom: '14px' }}>
        <TermLabel>HAIR COLOR (HEX)</TermLabel>
        <Box style={{ display: 'flex', gap: '6px', alignItems: 'center', marginTop: '4px' }}>
          <Input fluid value={hairDraft} onChange={(_, v) => setHairDraft(v.replace(/[^0-9A-Fa-f]/g, '').slice(0, 6))} style={inputStyle} />
          <Box style={{
            width: '32px', height: '32px',
            background: hairDraft ? `#${hairDraft}` : 'transparent',
            border: `1px solid ${C.border}`,
            flexShrink: 0,
          }} />
          <TermButton onClick={() => act('set_preference', { preference: 'hair_color', value: hairDraft })}>SAVE</TermButton>
        </Box>
      </Box>

      <TermDivider />

      <TermButton onClick={() => act('open_preferences')}>OPEN LEGACY PREFERENCES</TermButton>
    </TermBox>
  );
};

const QuirksPage = () => {
  const { act, data } = useBackend<any>();
  const userQuirks: string[] = data.quirks || [];
  const allQuirks: string[] = data.all_quirks || [];
  const quirkInfo: Record<string, { description: string }> = data.quirk_info || {};
  const list = allQuirks.length ? allQuirks : userQuirks;
  if (!list.length) return <TermBox><NoticeBox>NO PSYCHOLOGICAL DATA ON FILE</NoticeBox></TermBox>;

  return (
    <TermBox>
      <TermHeader>PSYCHOLOGICAL EVALUATION</TermHeader>
      <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
        {list.map((q) => (
          <TermButton
            key={q}
            selected={userQuirks.includes(q)}
            color={userQuirks.includes(q) ? 'green' : undefined}
            onClick={() => act('quirk_toggle', { quirk: q })}
            tooltip={quirkInfo[q]?.description}
          >
            {q}
          </TermButton>
        ))}
      </Box>
    </TermBox>
  );
};

const LanguagesPage = () => {
  const { act, data } = useBackend<any>();
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

const LoadoutPage = () => {
  const { act, data } = useBackend<any>();
  const loadout: { desc: string; name: string; path: string }[] = data.loadout_entries || [];

  return (
    <TermBox>
      <TermHeader>EQUIPMENT LOADOUT</TermHeader>
      {loadout.length > 0 ? loadout.map((entry) => (
        <Box key={entry.path} style={{ marginBottom: '6px', borderBottom: `1px solid ${C.border}`, paddingBottom: '6px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box>
            <TermValue bold>{entry.name}</TermValue>
            <Box style={term({ color: C.textDim, fontSize: '10px' })}>{entry.desc}</Box>
          </Box>
          <TermButton onClick={() => act('loadout_toggle', { item: entry.path, change_loadout: 1 })}>TOGGLE</TermButton>
        </Box>
      )) : (
        <Box style={term({ color: C.textDim, fontStyle: 'italic', marginBottom: '8px' })}>NO EQUIPMENT ASSIGNED</Box>
      )}
      <TermButton onClick={() => act('open_loadout')}>OPEN EQUIPMENT INTERFACE</TermButton>
    </TermBox>
  );
};

const AugmentsPage = () => {
  const { act, data } = useBackend<any>();
  const augs: Record<string, any> = data.augments || {};
  const entries = Object.entries(augs);

  return (
    <TermBox>
      <TermHeader>AUGMENTATIONS</TermHeader>
      {entries.length > 0 ? entries.map(([slot, path]) => (
        <TermRow key={slot} style={{ borderBottom: `1px solid ${C.border}`, paddingBottom: '6px' }}>
          <TermLabel>{slot}</TermLabel>
          <TermValue style={{ flex: 1 }}>{String(path)}</TermValue>
          <TermButton onClick={() => act('augments_act', { switch_augment: slot })}>SWAP</TermButton>
          <TermButton color="red" onClick={() => act('augments_act', { remove_augment: slot })}>RM</TermButton>
        </TermRow>
      )) : (
        <Box style={term({ color: C.textDim, fontStyle: 'italic', marginBottom: '8px' })}>NO AUGMENTATIONS INSTALLED</Box>
      )}
      <TermButton onClick={() => act('augments_act', { add_augment: 'General' })}>INSTALL AUGMENTATION</TermButton>
    </TermBox>
  );
};

const AppearanceModsPage = () => {
  const { act, data } = useBackend<any>();
  const mods: Record<string, any> = data.appearance_mods || {};
  const entries = Object.keys(mods);

  return (
    <TermBox>
      <TermHeader>APPEARANCE MODIFICATIONS</TermHeader>
      {entries.length > 0 ? entries.map((type) => (
        <TermRow key={type} style={{ borderBottom: `1px solid ${C.border}`, paddingBottom: '6px' }}>
          <TermValue style={{ flex: 1 }}>{type}</TermValue>
          <TermButton onClick={() => act('appearance_mods_act', { modify: 1, mod_name: type })}>EDIT</TermButton>
          <TermButton color="red" onClick={() => act('appearance_mods_act', { remove: 1, mod_name: type })}>RM</TermButton>
        </TermRow>
      )) : (
        <Box style={term({ color: C.textDim, fontStyle: 'italic', marginBottom: '8px' })}>NO MODIFICATIONS ON FILE</Box>
      )}
      <TermButton onClick={() => act('appearance_mods_act', { add: 1 })}>ADD MODIFICATION</TermButton>
    </TermBox>
  );
};

const AntagonistsPage = () => {
  const { act, data } = useBackend<any>();
  const antags: Record<string, boolean> = data.antagonists || {};
  const entries = Object.entries(antags);
  if (entries.length === 0) return <TermBox><NoticeBox>NO CLASSIFIED ROLES</NoticeBox></TermBox>;

  return (
    <TermBox>
      <TermHeader>CLASSIFIED ROLE PREFERENCES</TermHeader>
      <Box style={{ display: 'flex', gap: '4px', marginBottom: '10px' }}>
        <TermButton onClick={() => act('antag_select_all')}>ALL</TermButton>
        <TermButton onClick={() => act('antag_select_all_available')}>AVAILABLE</TermButton>
        <TermButton color="red" onClick={() => act('antag_deselect_all')}>NONE</TermButton>
      </Box>
      <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
        {entries.map(([role, enabled]) => (
          <TermButton
            key={role}
            selected={!!enabled}
            color={enabled ? 'red' : undefined}
            onClick={() => act('antag_toggle', { role })}
          >
            {role}
          </TermButton>
        ))}
      </Box>
    </TermBox>
  );
};

const FinalizePage = ({ data, act }) => (
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

const TABS = [
  { key: 'overview', label: 'OVERVIEW' },
  { key: 'faction', label: 'FACTION' },
  { key: 'jobs', label: 'ASSIGNMENT' },
  { key: 'custom', label: 'PERSONNEL' },
  { key: 'quirks', label: 'PSYCHE' },
  { key: 'languages', label: 'LANG' },
  { key: 'loadout', label: 'EQUIP' },
  { key: 'augments', label: 'AUGMENT' },
  { key: 'mods', label: 'MODS' },
  { key: 'antags', label: 'SCP' },
  { key: 'finalize', label: 'COMMIT' },
];

export const CharacterSetup = () => {
  const { act, data } = useBackend<any>();
  const { character_preview_view } = data;
  const [active, setActive] = useSharedState('CharacterSetup.activeTab', 'overview');

  return (
      <Window title="SCP PERSONNEL CONFIGURATION TERMINAL v4.7.2" width={1300} height={850} theme="scp_terminal">
      <Window.Content scrollable>
        <Box style={{
          background: C.bg,
          border: `1px solid ${C.borderRed}`,
          padding: '0',
          fontFamily: C.mono,
          fontSize: '12px',
          color: C.text,
          minHeight: '100%',
        }}>
          {/* HEADER */}
          <Box style={{
            borderBottom: `2px solid ${C.borderRed}`,
            padding: '10px 14px 8px',
            background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
          }}>
            <Box style={{ fontSize: '15px', fontWeight: 'bold', color: C.amber, letterSpacing: '0.18em' }}>
              SCP FOUNDATION — PERSONNEL CONFIGURATION
            </Box>
            <Box style={{ fontSize: '9px', color: C.textDim, letterSpacing: '0.12em', marginTop: '2px' }}>
              TERMINAL v4.7.2 | CLEARANCE LEVEL 2 | CLASSIFIED | ENCRYPTION: AES-512
            </Box>
          </Box>

          {/* TAB BAR */}
          <Box style={{
            display: 'flex',
            borderBottom: `1px solid ${C.borderRed}`,
            overflowX: 'auto',
            background: C.panel,
          }}>
            {TABS.map((t) => {
              const isActive = active === t.key;
              return (
                <Box
                  key={t.key}
                  style={{
                    padding: '6px 12px',
                    cursor: 'pointer',
                    background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent',
                    borderRight: `1px solid ${C.border}`,
                    borderBottom: isActive ? `2px solid ${C.amber}` : `2px solid transparent`,
                    color: isActive ? C.textBright : C.textDim,
                    fontSize: '10px',
                    letterSpacing: '0.12em',
                    textTransform: 'uppercase',
                    fontFamily: C.mono,
                    whiteSpace: 'nowrap',
                    transition: 'background 0.1s',
                  }}
                  onClick={() => setActive(t.key)}
                >
                  {isActive && '▸ '}{t.label}
                </Box>
              );
            })}
          </Box>

          {/* MAIN CONTENT AREA */}
          <Box style={{ display: 'flex' }}>
            {/* LEFT: Content */}
            <Box style={{ flex: 1, padding: '16px', minHeight: '480px' }}>
              {active === 'overview' && <OverviewPage data={data} />}
              {active === 'faction' && <FactionClassPage />}
              {active === 'jobs' && <JobsPage />}
              {active === 'custom' && <CustomizationPage />}
              {active === 'quirks' && <QuirksPage />}
              {active === 'languages' && <LanguagesPage />}
              {active === 'loadout' && <LoadoutPage />}
              {active === 'augments' && <AugmentsPage />}
              {active === 'mods' && <AppearanceModsPage />}
              {active === 'antags' && <AntagonistsPage />}
              {active === 'finalize' && <FinalizePage data={data} act={act} />}
            </Box>

            {/* RIGHT: Preview + Status */}
            <Box style={{
              width: '300px',
              borderLeft: `1px solid ${C.border}`,
              background: C.panel,
              padding: '10px',
              flexShrink: 0,
            }}>
              <TermHeader>VISUAL RECORD</TermHeader>
              <Box style={{ height: '260px', marginBottom: '10px' }}>
                {character_preview_view ? (
                  <CharacterPreview height="100%" id={character_preview_view} />
                ) : (
                  <Box style={term({ color: C.textDim, textAlign: 'center', paddingTop: '100px' })}>NO SIGNAL</Box>
                )}
              </Box>
              <TermButton fluid onClick={() => act('rotate')}>ROTATE</TermButton>

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
          <Box style={{
            borderTop: `1px solid ${C.border}`,
            padding: '4px 14px',
            background: C.panel,
          }}>
            <Box style={term({ color: C.textDim, fontSize: '9px', letterSpacing: '0.1em' })}>
              SCP FOUNDATION | SECURE CONTAIN PROTECT | ALL ACTIVITY LOGGED | UNAUTHORIZED ACCESS IS A CLASS-B INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
