import { useBackend, useSharedState } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from '../../components';
import { Window } from '../../layouts';
import { CharacterPreview } from '../PreferencesMenu/CharacterPreview';

const PreviewPanel = ({ character_preview_view }) => (
  <Section title="Preview" fill>
    {character_preview_view ? (
      <iframe
        style={{ width: '100%', height: '100%', border: '0' }}
        src={`byond://${character_preview_view}`}
      />
    ) : (
      <Box>No preview available</Box>
    )}
  </Section>
);

const OverviewPage = ({ data }) => (
  <Section title="Overview">
    <LabeledList>
      <LabeledList.Item label="Name">
        {data.name_to_use || 'Unset'}
      </LabeledList.Item>
      <LabeledList.Item label="Faction">
        {data.faction || 'Unset'}
      </LabeledList.Item>
      <LabeledList.Item label="Class">{data.class || 'Unset'}</LabeledList.Item>
      <LabeledList.Item label="Locked">
        {data.faction_class_locked ? 'Yes' : 'No'} (Tokens:{' '}
        {data.faction_class_reset_tokens || 0})
      </LabeledList.Item>
    </LabeledList>
  </Section>
);

const FactionClassPage = () => {
  const { act, data } = useBackend<any>();
  const factionToClasses: Record<string, string[]> =
    data.faction_to_classes || {};
  const factionLore: Record<string, string> = data.faction_lore || {};
  const classLore: Record<string, string> = data.class_lore || {};

  const factions = Object.keys(factionToClasses);
  const selectedFaction = data.faction || '';
  const classes = selectedFaction
    ? factionToClasses[selectedFaction] || []
    : [];
  const selectedClass = data.class || '';

  const locked = !!data.faction_class_locked;
  const tokens = data.faction_class_reset_tokens || 0;
  const canAdmin = !!data.can_admin_override;

  const [confirmReset, setConfirmReset] = useSharedState(
    'CharacterSetup.confirmReset',
    false,
  );
  const [confirmAdmin, setConfirmAdmin] = useSharedState(
    'CharacterSetup.confirmAdmin',
    false,
  );

  return (
    <Stack>
      <Stack.Item grow>
        <Section title="Faction">
          {locked ? (
            <LabeledList>
              <LabeledList.Item label="Faction">
                {selectedFaction || 'Unset'}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Dropdown
              width="100%"
              options={factions}
              selected={selectedFaction}
              displayText={selectedFaction || 'Select Faction'}
              onSelected={(value) => act('set_faction', { value })}
            />
          )}
        </Section>
        <Section title="Class">
          {locked ? (
            <LabeledList>
              <LabeledList.Item label="Class">
                {selectedClass || 'Unset'}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Dropdown
              width="100%"
              options={classes}
              selected={selectedClass}
              displayText={selectedClass || 'Select Class'}
              onSelected={(value) => act('set_class', { value })}
            />
          )}
        </Section>
        <Section title="Commit">
          {locked ? (
            <Stack align="center" justify="space-between">
              <Stack.Item grow>
                {tokens > 0 ? (
                  confirmReset ? (
                    <Stack align="center" justify="start" wrap>
                      <Stack.Item>
                        <NoticeBox mt={0} mb={0}>
                          Use one reset token to unlock and clear faction/class?
                        </NoticeBox>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          color="orange"
                          icon="check"
                          onClick={() => {
                            setConfirmReset(false);
                            act('request_reset_faction_class');
                          }}
                        >
                          Confirm
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="times"
                          onClick={() => setConfirmReset(false)}
                        >
                          Cancel
                        </Button>
                      </Stack.Item>
                    </Stack>
                  ) : (
                    <Button
                      color="orange"
                      icon="undo"
                      onClick={() => setConfirmReset(true)}
                    >
                      Use Reset Token ({tokens} left)
                    </Button>
                  )
                ) : (
                  <NoticeBox>No reset tokens available.</NoticeBox>
                )}
              </Stack.Item>
              {canAdmin && (
                <Stack.Item>
                  {confirmAdmin ? (
                    <Stack align="center" justify="end">
                      <Stack.Item>
                        <Button
                          color="red"
                          icon="check"
                          onClick={() => {
                            setConfirmAdmin(false);
                            act('admin_override_unlock');
                          }}
                        >
                          Confirm Admin Unlock
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="times"
                          onClick={() => setConfirmAdmin(false)}
                        >
                          Cancel
                        </Button>
                      </Stack.Item>
                    </Stack>
                  ) : (
                    <Button
                      color="red"
                      icon="unlock"
                      onClick={() => setConfirmAdmin(true)}
                    >
                      Admin Unlock
                    </Button>
                  )}
                </Stack.Item>
              )}
            </Stack>
          ) : (
            <Button
              color="green"
              icon="lock"
              onClick={() => act('commit_faction_class')}
            >
              Commit and Lock
            </Button>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item basis={360}>
        <Section title="Lore">
          <Box mb={1}>
            <b>Faction:</b> {selectedFaction || '-'}
          </Box>
          <Box mb={2}>
            {(selectedFaction && factionLore[selectedFaction]) || '—'}
          </Box>
          <Box mb={1}>
            <b>Class:</b> {selectedClass || '-'}
          </Box>
          <Box>{(selectedClass && classLore[selectedClass]) || '—'}</Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const JobsPage = () => {
  const { act, data } = useBackend<any>();
  const available: { description: string; title: string }[] =
    data.available_jobs || [];
  const jobPrefs: Record<string, number> = data.job_preferences || {};

  if (!data.faction || !data.class) {
    return (
      <NoticeBox>Choose faction and class to view available jobs.</NoticeBox>
    );
  }
  if (available.length === 0) {
    return <NoticeBox>No jobs available for this combination.</NoticeBox>;
  }

  return (
    <Section title={`Jobs for ${data.faction} / ${data.class}`}>
      {available.map((j) => (
        <Stack key={j.title} align="center" mb={1}>
          <Stack.Item grow>
            <Box>
              <b>{j.title}</b>
              <br />
              <Box color="label" fontSize="0.9em">
                {j.description}
              </Box>
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <Button
                  selected={!jobPrefs[j.title]}
                  onClick={() =>
                    act('set_job_priority', { job: j.title, level: null })
                  }
                >
                  Off
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="red"
                  selected={jobPrefs[j.title] === 1}
                  onClick={() =>
                    act('set_job_priority', { job: j.title, level: 1 })
                  }
                >
                  Low
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="yellow"
                  selected={jobPrefs[j.title] === 2}
                  onClick={() =>
                    act('set_job_priority', { job: j.title, level: 2 })
                  }
                >
                  Medium
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="green"
                  selected={jobPrefs[j.title] === 3}
                  onClick={() =>
                    act('set_job_priority', { job: j.title, level: 3 })
                  }
                >
                  High
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};

const AntagonistsPage = () => {
  const { act, data } = useBackend<any>();
  const antags: Record<string, boolean> = data.antagonists || {};
  const entries = Object.entries(antags);
  if (entries.length === 0) {
    return <NoticeBox>No antagonist roles available.</NoticeBox>;
  }
  return (
    <Section title="Antagonist Preferences">
      <Stack mb={1} wrap>
        <Stack.Item>
          <Button icon="check-double" onClick={() => act('antag_select_all')}>
            Select All
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button icon="ban" onClick={() => act('antag_deselect_all')}>
            Deselect All
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="user-secret"
            onClick={() => act('antag_select_all_available')}
          >
            Select All Available
          </Button>
        </Stack.Item>
      </Stack>
      <Flex wrap style={{ gap: '8px' }}>
        {entries.map(([role, enabled]) => (
          <Flex.Item key={role}>
            <Button
              selected={!!enabled}
              onClick={() => act('antag_toggle', { role })}
              tooltip={role}
            >
              {role}
            </Button>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const CustomizationPage = () => {
  const { act, data } = useBackend<any>();
  const speciesChoices: string[] = data.species_choices || [];
  const speciesNames: Record<string, string> = data.species_names || {};
  const currentSpeciesId: string = data.species_id || '';
  const genderChoices: string[] = data.gender_choices || [
    'male',
    'female',
    'plural',
  ];
  const [nameDraft, setNameDraft] = useSharedState(
    'CharacterSetup.nameDraft',
    data.real_name || '',
  );
  const [ageDraft, setAgeDraft] = useSharedState(
    'CharacterSetup.ageDraft',
    String(data.age ?? ''),
  );
  const [eyeDraft, setEyeDraft] = useSharedState(
    'CharacterSetup.eyeDraft',
    data.eye_color || '',
  );
  const [hairDraft, setHairDraft] = useSharedState(
    'CharacterSetup.hairDraft',
    data.hair_color || '',
  );

  return (
    <Section title="Customization">
      <LabeledList>
        <LabeledList.Item label="Name">
          <Stack align="center" justify="space-between">
            <Stack.Item grow>
              <Input
                fluid
                value={nameDraft}
                onChange={(_, v) => setNameDraft(v)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="save"
                onClick={() =>
                  act('set_preference', {
                    preference: 'real_name',
                    value: nameDraft,
                  })
                }
              >
                Save
              </Button>
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Age">
          <Stack align="center" justify="space-between">
            <Stack.Item grow>
              <Input
                fluid
                value={ageDraft}
                onChange={(_, v) => setAgeDraft(v.replace(/[^0-9]/g, ''))}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="save"
                onClick={() =>
                  act('set_preference', {
                    preference: 'age',
                    value: Number(ageDraft),
                  })
                }
              >
                Save
              </Button>
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Gender">
          <Dropdown
            width="100%"
            options={genderChoices}
            selected={data.gender || ''}
            displayText={data.gender || 'Select Gender'}
            onSelected={(value) =>
              act('set_preference', { preference: 'gender', value })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Species">
          <Dropdown
            width="100%"
            options={speciesChoices.map((id) => ({
              value: id,
              displayText: speciesNames[id] || id,
            }))}
            selected={currentSpeciesId}
            displayText={
              speciesNames[currentSpeciesId] ||
              currentSpeciesId ||
              'Select Species'
            }
            onSelected={(value) =>
              act('set_preference', { preference: 'species', value })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Eye Color (hex)">
          <Stack align="center" justify="space-between">
            <Stack.Item grow>
              <Input
                fluid
                value={eyeDraft}
                onChange={(_, v) =>
                  setEyeDraft(v.replace(/[^0-9A-Fa-f]/g, '').slice(0, 6))
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="save"
                onClick={() =>
                  act('set_preference', {
                    preference: 'eye_color',
                    value: eyeDraft,
                  })
                }
              >
                Save
              </Button>
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Hair Color (hex)">
          <Stack align="center" justify="space-between">
            <Stack.Item grow>
              <Input
                fluid
                value={hairDraft}
                onChange={(_, v) =>
                  setHairDraft(v.replace(/[^0-9A-Fa-f]/g, '').slice(0, 6))
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="save"
                onClick={() =>
                  act('set_preference', {
                    preference: 'hair_color',
                    value: hairDraft,
                  })
                }
              >
                Save
              </Button>
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
      </LabeledList>
      <NoticeBox mt={1}>
        More appearance, quirks, languages, loadout, augments, and antagonist
        preferences will be added here.
      </NoticeBox>
      <Button icon="cog" onClick={() => act('open_preferences')}>
        Open Classic Preferences Temporarily
      </Button>
    </Section>
  );
};

const QuirksPage = () => {
  const { act, data } = useBackend<any>();
  const userQuirks: string[] = data.quirks || [];
  const allQuirks: string[] = data.all_quirks || [];
  const quirkInfo: Record<string, { description: string }> =
    data.quirk_info || {};
  const list = allQuirks.length ? allQuirks : userQuirks;
  if (!list.length) return <NoticeBox>No quirks available.</NoticeBox>;
  return (
    <Section title="Quirks">
      <Flex wrap style={{ gap: '8px' }}>
        {list.map((q) => (
          <Flex.Item key={q}>
            <Button
              selected={userQuirks.includes(q)}
              onClick={() => act('quirk_toggle', { quirk: q })}
              tooltip={quirkInfo[q]?.description}
            >
              {q}
            </Button>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const LanguagesPage = () => {
  const { act, data } = useBackend<any>();
  const langs: Record<string, number> = data.languages || {};
  const catalog: Record<string, string> = data.languages_catalog || {};
  const paths = Object.keys(catalog);
  if (!paths.length) return <NoticeBox>No languages available.</NoticeBox>;
  return (
    <Section title="Languages">
      {paths.map((path) => {
        const flags = langs[path] || 0;
        const name = catalog[path] || path;
        return (
          <Stack key={path} align="center" mb={0.5}>
            <Stack.Item grow>
              <Box>{name}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                selected={Boolean(flags & 1)}
                onClick={() =>
                  act('language_toggle_understand', { language: path })
                }
              >
                Understand
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                selected={Boolean(flags & 2)}
                onClick={() => act('language_toggle_speak', { language: path })}
              >
                Speak
              </Button>
            </Stack.Item>
          </Stack>
        );
      })}
    </Section>
  );
};

const LoadoutPage = () => {
  const { act, data } = useBackend<any>();
  const loadout: { desc: string; name: string; path: string }[] =
    data.loadout_entries || [];
  if (!loadout.length) {
    return (
      <Section title="Loadout">
        <NoticeBox>
          No loadout items selected. Open classic to add items.
        </NoticeBox>
        <Button icon="suitcase" onClick={() => act('open_loadout')}>
          Open Loadout
        </Button>
      </Section>
    );
  }
  return (
    <Section title="Loadout">
      {loadout.map((entry) => (
        <Stack key={entry.path} align="center" mb={0.5}>
          <Stack.Item grow>
            <Box>
              <b>{entry.name}</b>
              <Box color="label">{entry.desc}</Box>
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              onClick={() =>
                act('loadout_toggle', { item: entry.path, change_loadout: 1 })
              }
            >
              Toggle
            </Button>
          </Stack.Item>
        </Stack>
      ))}
      <Box mt={1}>
        <Button icon="suitcase" onClick={() => act('open_loadout')}>
          Open Classic Loadout
        </Button>
      </Box>
    </Section>
  );
};

const AugmentsPage = () => {
  const { act, data } = useBackend<any>();
  const augs: Record<string, any> = data.augments || {};
  const entries = Object.entries(augs);
  return (
    <Section title="Augments">
      {entries.length ? (
        entries.map(([slot, path]) => (
          <Stack key={slot} align="center" mb={0.5}>
            <Stack.Item grow>
              <Box>
                <b>{slot}</b>: {String(path)}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() => act('augments_act', { switch_augment: slot })}
              >
                Switch
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                color="red"
                onClick={() => act('augments_act', { remove_augment: slot })}
              >
                Remove
              </Button>
            </Stack.Item>
          </Stack>
        ))
      ) : (
        <NoticeBox>No augments selected.</NoticeBox>
      )}
      <Box mt={1}>
        <Button
          icon="plus"
          onClick={() => act('augments_act', { add_augment: 'General' })}
        >
          Add Augment
        </Button>
      </Box>
    </Section>
  );
};

const AppearanceModsPage = () => {
  const { act, data } = useBackend<any>();
  const mods: Record<string, any> = data.appearance_mods || {};
  const entries = Object.keys(mods);
  return (
    <Section title="Appearance Mods">
      {entries.length ? (
        entries.map((type) => (
          <Stack key={type} align="center" mb={0.5}>
            <Stack.Item grow>
              <Box>{type}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() =>
                  act('appearance_mods_act', { modify: 1, mod_name: type })
                }
              >
                Modify
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                color="red"
                onClick={() =>
                  act('appearance_mods_act', { remove: 1, mod_name: type })
                }
              >
                Remove
              </Button>
            </Stack.Item>
          </Stack>
        ))
      ) : (
        <NoticeBox>No appearance mods.</NoticeBox>
      )}
      <Box mt={1}>
        <Button
          icon="plus"
          onClick={() => act('appearance_mods_act', { add: 1 })}
        >
          Add Mod
        </Button>
      </Box>
    </Section>
  );
};

export const CharacterSetup = () => {
  const { act, data } = useBackend<any>();
  const { character_preview_view } = data;
  const [active, setActive] = useSharedState(
    'CharacterSetup.activeTab',
    'overview',
  );

  return (
    <Window title="Character Setup" width={1200} height={800}>
      <Window.Content>
        <Box
          style={{
            background: 'rgba(0,0,0,0.7)',
            border: '1px solid rgba(255,255,255,0.2)',
            borderRadius: '5px',
            padding: '16px',
            fontFamily: 'monospace',
            fontSize: '14px',
            color: '#ffffff',
            minHeight: '100%',
          }}
        >
          <Box style={{ marginBottom: '12px' }}>
            <Box style={{ fontSize: '22px', fontWeight: 'bold' }}>
              PERSONNEL SETUP
            </Box>
            <Box style={{ fontSize: '14px', opacity: '0.8' }}>
              CHARACTER CONFIGURATION
            </Box>
          </Box>
          <Box style={{ marginBottom: '12px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Flex>
            <Flex.Item grow>
              <Flex
                style={{
                  marginBottom: '12px',
                  borderBottom: '1px solid rgba(255,255,255,0.3)',
                  gap: '8px',
                  flexWrap: 'nowrap',
                  overflowX: 'auto',
                  whiteSpace: 'nowrap',
                }}
              >
                {[
                  { key: 'overview', label: 'Overview' },
                  { key: 'faction', label: 'Faction & Class' },
                  { key: 'jobs', label: 'Jobs' },
                  { key: 'custom', label: 'Customization' },
                  { key: 'languages', label: 'Languages' },
                  { key: 'quirks', label: 'Quirks' },
                  { key: 'loadout', label: 'Loadout' },
                  { key: 'augments', label: 'Augments' },
                  { key: 'mods', label: 'Appearance Mods' },
                  { key: 'antags', label: 'Antagonists' },
                  { key: 'summary', label: 'Summary' },
                ].map((t) => (
                  <Box
                    key={t.key}
                    style={{
                      padding: '8px 12px',
                      cursor: 'pointer',
                      background:
                        active === t.key
                          ? 'rgba(255,255,255,0.15)'
                          : 'rgba(255,255,255,0.05)',
                      border: '1px solid rgba(255,255,255,0.3)',
                      borderBottom:
                        active === t.key
                          ? '2px solid #ffffff'
                          : '1px solid rgba(255,255,255,0.1)',
                      borderRadius: '5px 5px 0 0',
                      transition: 'all 0.2s ease',
                      display: 'inline-block',
                      flex: '0 0 auto',
                    }}
                    onClick={() => setActive(t.key)}
                  >
                    {t.label}
                  </Box>
                ))}
              </Flex>

              {active === 'overview' && <OverviewPage data={data} />}
              {active === 'faction' && <FactionClassPage />}
              {active === 'jobs' && <JobsPage />}
              {active === 'custom' && <CustomizationPage />}
              {active === 'languages' && <LanguagesPage />}
              {active === 'quirks' && <QuirksPage />}
              {active === 'loadout' && <LoadoutPage />}
              {active === 'augments' && <AugmentsPage />}
              {active === 'mods' && <AppearanceModsPage />}
              {active === 'antags' && <AntagonistsPage />}
              {active === 'summary' && (
                <Section title="Summary">
                  <OverviewPage data={data} />
                  <Box mt={1}>
                    This will save your preferences and update your personnel
                    record.
                  </Box>
                  <Button
                    color="green"
                    icon="save"
                    onClick={() => act('finalize')}
                  >
                    Finalize & Save
                  </Button>
                </Section>
              )}

              <Section title="Actions">
                <Button icon="undo" onClick={() => act('rotate')}>
                  Rotate Preview
                </Button>
              </Section>
            </Flex.Item>
            <Flex.Item basis={320}>
              <Box style={{ height: '280px' }}>
                {character_preview_view ? (
                  <CharacterPreview height="100%" id={character_preview_view} />
                ) : (
                  <NoticeBox>No preview available</NoticeBox>
                )}
              </Box>
            </Flex.Item>
          </Flex>
        </Box>
      </Window.Content>
    </Window>
  );
};
