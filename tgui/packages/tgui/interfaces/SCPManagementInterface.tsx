import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Input,
  Modal,
  NumberInput,
} from '../components';
import { Window } from '../layouts';

interface SCPData {
  active_breaches: number;
  auto_containment_enabled: BooleanLike;
  containment_effectiveness: number;
  disabled_scps: string[];
  enabled_scps: string[];
  global_containment_stability: number;
  global_management_mode: string;
  management_override: BooleanLike;
  research_progress: number;
  rotation_interval: number;
  scp_instances: SCPInstance[];
  scp_rotation_enabled: BooleanLike;
}

interface SCPInstance {
  containment_health: number;
  containment_status: string;
  enabled: BooleanLike;
  id: string;
  interaction_count: number;
  last_interaction: string;
}

interface SCPTemplate {
  class: string;
  containment_level: string;
  containment_settings: {
    auto_containment: BooleanLike;
    backup_protocols: string[];
    breach_response_time: number;
    containment_effectiveness: number;
    containment_radius: number;
  };
  description: string;
  interaction_settings: {
    interaction_allowed: BooleanLike;
    interaction_clearance: number;
    interaction_logging: BooleanLike;
    interaction_restrictions: string[];
  };
  name: string;
  player_access: {
    allowed_roles: string[];
    clearance_level: number;
    max_players: number;
    min_rank: number;
    requires_clearance: BooleanLike;
    restricted_roles: string[];
    training_required: string[];
  };
  research_settings: {
    research_allowed: BooleanLike;
    research_clearance: number;
    research_goals: string[];
    research_restrictions: string[];
  };
  spawn_conditions: {
    allowed_jobs: string[];
    max_instances: number;
    min_players: number;
    min_time: number;
    restricted_jobs: string[];
    spawn_locations: string[];
    spawn_probability: number;
    time_restrictions: {
      allowed_days: number[];
      end_hour: number;
      start_hour: number;
    };
  };
}

interface PlayerData {
  clearance: number;
  job: string;
  key: string;
  name: string;
  online: BooleanLike;
  rank: number;
}

interface SpawnSchedule {
  created_by: string;
  created_time: number;
  enabled: BooleanLike;
  max_players: number;
  min_players: number;
  scp_id: string;
  spawn_probability: number;
}

interface ContainmentProtocol {
  description: string;
  effectiveness: number;
  name: string;
  requirements: string[];
  response_time: number;
}

interface Data {
  containment_protocols: Record<string, ContainmentProtocol>;
  player_data: PlayerData[];
  scp_data: SCPData;
  scp_templates: Record<string, SCPTemplate>;
  spawn_schedules: Record<string, SpawnSchedule>;
}

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

const TermHeader = (props) => (
  <Box
    style={term({
      fontSize: '10px',
      color: C.textDim,
      letterSpacing: '0.18em',
      textTransform: 'uppercase',
      borderBottom: `1px solid ${C.border}`,
      paddingBottom: '4px',
      marginBottom: '8px',
      ...props.style,
    })}
  >
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
  <Box
    style={{
      color: C.borderRed,
      fontSize: '10px',
      letterSpacing: '0.3em',
      margin: '10px 0',
      userSelect: 'none',
      overflow: 'hidden',
      whiteSpace: 'nowrap',
    }}
  >
    {'─'.repeat(80)}
  </Box>
);

const TermButton = (props) => {
  const selected = props.selected;
  const color = props.color;
  const bg = selected
    ? color === 'red'
      ? 'rgba(139,0,0,0.35)'
      : color === 'green'
        ? 'rgba(26,122,26,0.35)'
        : color === 'yellow'
          ? 'rgba(180,160,20,0.25)'
          : 'rgba(255,255,255,0.08)'
    : 'transparent';
  const borderColor = selected
    ? color === 'red'
      ? C.red
      : color === 'green'
        ? C.green
        : color === 'yellow'
          ? '#b0a020'
          : C.border
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
        boxShadow: selected ? `0 0 6px ${borderColor}44` : 'none',
      }}
    >
      {props.children}
    </Button>
  );
};

const TermProgressBar = (props) => (
  <Box style={{ marginBottom: '6px' }}>
    <Box
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        marginBottom: '2px',
      }}
    >
      <TermLabel>{props.label}</TermLabel>
      <TermValue color={props.color || C.amber}>
        {props.value}
        {props.suffix || ''}
      </TermValue>
    </Box>
    <Box
      style={{
        height: '6px',
        background: C.panel,
        border: `1px solid ${C.border}`,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          height: '100%',
          width: `${Math.min(100, Math.max(0, (props.value / props.maxValue) * 100))}%`,
          background: props.color || C.amber,
          transition: 'width 0.3s',
        }}
      />
    </Box>
  </Box>
);

const TermModal = (props) => (
  <Modal
    {...props}
    style={{
      background: C.bg,
      border: `1px solid ${C.borderRed}`,
      borderRadius: 0,
      fontFamily: C.mono,
      color: C.text,
      padding: '16px',
    }}
  >
    {props.children}
  </Modal>
);

const getSCPStatusColor = (status) => {
  switch (status) {
    case 'contained':
      return C.green;
    case 'breached':
      return C.redBright;
    case 'warning':
      return C.amber;
    default:
      return C.textDim;
  }
};

const getSCPClassColor = (scpClass) => {
  switch (scpClass) {
    case 'Keter':
      return C.redBright;
    case 'Euclid':
      return C.amber;
    case 'Safe':
      return C.green;
    default:
      return C.textDim;
  }
};

const getProgressColor = (value) => {
  if (value > 80) return C.green;
  if (value > 50) return C.amber;
  return C.redBright;
};

export const SCPManagementInterface = (props) => {
  const { act, data } = useBackend<Data>();
  const [selectedTab, setSelectedTab] = useLocalState(
    'selectedTab',
    'overview',
  );
  const [selectedSCP, setSelectedSCP] = useLocalState('selectedSCP', '');
  const [showSpawnModal, setShowSpawnModal] = useLocalState(
    'showSpawnModal',
    false,
  );
  const [showConfigModal, setShowConfigModal] = useLocalState(
    'showConfigModal',
    false,
  );

  const {
    scp_data: raw_scp_data,
    scp_templates = {},
    player_data = [],
    spawn_schedules = {},
    containment_protocols = {},
  } = data || ({} as Data);

  const scp_data = {
    global_containment_stability:
      (raw_scp_data && (raw_scp_data as any).global_containment_stability) ?? 0,
    active_breaches:
      (raw_scp_data && (raw_scp_data as any).active_breaches) ?? 0,
    research_progress:
      (raw_scp_data && (raw_scp_data as any).research_progress) ?? 0,
    containment_effectiveness:
      (raw_scp_data && (raw_scp_data as any).containment_effectiveness) ?? 0,
    enabled_scps: (raw_scp_data && (raw_scp_data as any).enabled_scps) ?? [],
    disabled_scps: (raw_scp_data && (raw_scp_data as any).disabled_scps) ?? [],
    global_management_mode:
      (raw_scp_data && (raw_scp_data as any).global_management_mode) ??
      'standard',
    management_override:
      (raw_scp_data && (raw_scp_data as any).management_override) ?? false,
    auto_containment_enabled:
      (raw_scp_data && (raw_scp_data as any).auto_containment_enabled) ?? false,
    scp_rotation_enabled:
      (raw_scp_data && (raw_scp_data as any).scp_rotation_enabled) ?? false,
    rotation_interval:
      (raw_scp_data && (raw_scp_data as any).rotation_interval) ?? 6000,
    scp_instances: (raw_scp_data && (raw_scp_data as any).scp_instances) ?? [],
  } as SCPData;

  const TABS = [
    { key: 'overview', label: 'OVERVIEW' },
    { key: 'scps', label: 'SCP MGMT' },
    { key: 'spawning', label: 'SPAWN' },
    { key: 'players', label: 'ACCESS' },
    { key: 'containment', label: 'CONTAIN' },
    { key: 'logs', label: 'LOGS' },
  ];

  return (
    <Window width={1200} height={800} theme="scp_terminal">
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderRed}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          <Box
            style={{
              borderBottom: `2px solid ${C.borderRed}`,
              padding: '10px 14px 8px',
              background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '0.18em',
              }}
            >
              SCP FOUNDATION — CONTAINMENT MANAGEMENT TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 4 | CONTAINMENT CONTROL | ANOMALOUS ENTITY
              MANAGEMENT
            </Box>
          </Box>

          <Box
            style={{
              display: 'flex',
              borderBottom: `1px solid ${C.borderRed}`,
              overflowX: 'auto',
              background: C.panel,
            }}
          >
            {TABS.map((t) => {
              const isActive = selectedTab === t.key;
              return (
                <Box
                  key={t.key}
                  style={{
                    padding: '6px 12px',
                    cursor: 'pointer',
                    background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent',
                    borderRight: `1px solid ${C.border}`,
                    borderBottom: isActive
                      ? `2px solid ${C.amber}`
                      : '2px solid transparent',
                    color: isActive ? C.textBright : C.textDim,
                    fontSize: '10px',
                    letterSpacing: '0.12em',
                    textTransform: 'uppercase',
                    fontFamily: C.mono,
                    whiteSpace: 'nowrap',
                  }}
                  onClick={() => setSelectedTab(t.key)}
                >
                  {isActive && '▸ '}
                  {t.label}
                </Box>
              );
            })}
          </Box>

          <Box style={{ padding: '16px' }}>
            {selectedTab === 'overview' && (
              <Box>
                <TermHeader>GLOBAL SCP STATUS</TermHeader>
                <TermProgressBar
                  label="CONTAINMENT STABILITY"
                  value={scp_data.global_containment_stability}
                  maxValue={100}
                  color={getProgressColor(
                    scp_data.global_containment_stability,
                  )}
                  suffix="%"
                />
                <TermProgressBar
                  label="RESEARCH PROGRESS"
                  value={scp_data.research_progress}
                  maxValue={100}
                  color="#4488ff"
                  suffix="%"
                />
                <TermProgressBar
                  label="CONTAINMENT EFFECTIVENESS"
                  value={Math.round(scp_data.containment_effectiveness * 100)}
                  maxValue={100}
                  color={C.green}
                  suffix="%"
                />
                <TermRow>
                  <TermLabel>ACTIVE BREACHES</TermLabel>
                  <TermValue
                    color={scp_data.active_breaches > 0 ? C.redBright : C.green}
                  >
                    {scp_data.active_breaches}
                  </TermValue>
                </TermRow>

                <TermDivider />

                <TermHeader>MANAGEMENT CONTROLS</TermHeader>
                <TermRow>
                  <TermLabel>MODE</TermLabel>
                  <Dropdown
                    selected={scp_data.global_management_mode}
                    options={['standard', 'lockdown', 'research', 'emergency']}
                    onSelected={(value) =>
                      act('set_management_mode', { mode: value })
                    }
                  />
                </TermRow>
                <TermRow>
                  <TermLabel>AUTO-CONTAINMENT</TermLabel>
                  <TermButton
                    color="green"
                    selected={!!scp_data.auto_containment_enabled}
                    onClick={() => act('toggle_auto_containment')}
                  >
                    {scp_data.auto_containment_enabled ? 'ENABLED' : 'DISABLED'}
                  </TermButton>
                </TermRow>
                <TermRow>
                  <TermLabel>SCP ROTATION</TermLabel>
                  <TermButton
                    color="green"
                    selected={!!scp_data.scp_rotation_enabled}
                    onClick={() => act('toggle_scp_rotation')}
                  >
                    {scp_data.scp_rotation_enabled ? 'ENABLED' : 'DISABLED'}
                  </TermButton>
                </TermRow>
                <TermRow>
                  <TermLabel>ROTATION INTERVAL</TermLabel>
                  <NumberInput
                    value={Math.round(scp_data.rotation_interval / 600)}
                    minValue={5}
                    maxValue={120}
                    step={1}
                    onChange={(value) =>
                      act('set_rotation_interval', { interval: value })
                    }
                  />
                  <TermLabel style={{ marginLeft: '4px' }}>MIN</TermLabel>
                </TermRow>

                <TermDivider />

                <TermHeader>QUICK ACTIONS</TermHeader>
                <Box style={{ display: 'flex', gap: '4px' }}>
                  <TermButton
                    color="green"
                    onClick={() =>
                      Object.keys(scp_templates).forEach((scp_id) =>
                        act('enable_scp', { scp_id }),
                      )
                    }
                  >
                    ENABLE ALL
                  </TermButton>
                  <TermButton
                    color="red"
                    onClick={() =>
                      Object.keys(scp_templates).forEach((scp_id) =>
                        act('disable_scp', { scp_id }),
                      )
                    }
                  >
                    DISABLE ALL
                  </TermButton>
                  <TermButton onClick={() => act('force_scp_rotation')}>
                    FORCE ROTATION
                  </TermButton>
                  <TermButton
                    color="yellow"
                    onClick={() => act('export_scp_data')}
                  >
                    EXPORT
                  </TermButton>
                </Box>

                <TermDivider />

                <TermHeader>SCP INSTANCES</TermHeader>
                {(scp_data.scp_instances || []).length > 0 ? (
                  scp_data.scp_instances.map((instance) => (
                    <Box
                      key={instance.id}
                      style={{
                        marginBottom: '4px',
                        padding: '8px',
                        borderLeft: `2px solid ${getSCPStatusColor(instance.containment_status)}`,
                        background: C.panel,
                      }}
                    >
                      <TermRow>
                        <TermValue bold color={C.amber}>
                          {instance.id}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          STATUS
                        </TermLabel>
                        <TermValue
                          color={getSCPStatusColor(instance.containment_status)}
                        >
                          {instance.containment_status}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          HEALTH
                        </TermLabel>
                        <TermValue
                          color={getProgressColor(instance.containment_health)}
                        >
                          {instance.containment_health}%
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          INTERACTIONS
                        </TermLabel>
                        <TermValue>{instance.interaction_count}</TermValue>
                      </TermRow>
                      <Box
                        style={{
                          display: 'flex',
                          gap: '4px',
                          marginTop: '4px',
                        }}
                      >
                        <TermButton
                          onClick={() =>
                            act('view_scp_logs', { scp_id: instance.id })
                          }
                        >
                          LOGS
                        </TermButton>
                        <TermButton
                          color="green"
                          onClick={() =>
                            act('force_contain_scp', { scp_id: instance.id })
                          }
                        >
                          CONTAIN
                        </TermButton>
                      </Box>
                    </Box>
                  ))
                ) : (
                  <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                    NO ACTIVE INSTANCES
                  </Box>
                )}
              </Box>
            )}

            {selectedTab === 'scps' && (
              <Box>
                <TermHeader>SCP TEMPLATES</TermHeader>
                {Object.entries(scp_templates || {}).map(
                  ([scp_id, template]) => (
                    <Box
                      key={scp_id}
                      style={{
                        marginBottom: '6px',
                        padding: '8px',
                        borderLeft: `2px solid ${getSCPClassColor(template.class)}`,
                        background: C.panel,
                      }}
                    >
                      <TermRow>
                        <TermValue bold color={C.amber}>
                          {scp_id}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          CLASS
                        </TermLabel>
                        <TermValue color={getSCPClassColor(template.class)}>
                          {template.class}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          STATUS
                        </TermLabel>
                        <TermValue
                          color={
                            scp_data.enabled_scps.includes(scp_id)
                              ? C.green
                              : C.redBright
                          }
                        >
                          {scp_data.enabled_scps.includes(scp_id)
                            ? 'ENABLED'
                            : 'DISABLED'}
                        </TermValue>
                      </TermRow>
                      <Box
                        style={term({
                          color: C.textDim,
                          fontSize: '11px',
                          fontStyle: 'italic',
                          marginTop: '2px',
                        })}
                      >
                        {template.description}
                      </Box>
                      <Box
                        style={{
                          display: 'flex',
                          gap: '4px',
                          marginTop: '6px',
                        }}
                      >
                        <TermButton
                          color={
                            scp_data.enabled_scps.includes(scp_id)
                              ? 'red'
                              : 'green'
                          }
                          onClick={() =>
                            act(
                              scp_data.enabled_scps.includes(scp_id)
                                ? 'disable_scp'
                                : 'enable_scp',
                              { scp_id },
                            )
                          }
                        >
                          {scp_data.enabled_scps.includes(scp_id)
                            ? 'DISABLE'
                            : 'ENABLE'}
                        </TermButton>
                        <TermButton
                          onClick={() => {
                            setSelectedSCP(scp_id);
                            setShowConfigModal(true);
                          }}
                        >
                          CONFIG
                        </TermButton>
                        <TermButton
                          onClick={() => act('force_spawn_scp', { scp_id })}
                        >
                          SPAWN
                        </TermButton>
                      </Box>
                    </Box>
                  ),
                )}
              </Box>
            )}

            {selectedTab === 'spawning' && (
              <Box>
                <TermHeader>SPAWN SCHEDULES</TermHeader>
                <Box style={{ marginBottom: '12px' }}>
                  <TermButton
                    color="green"
                    onClick={() => setShowSpawnModal(true)}
                  >
                    NEW SCHEDULE
                  </TermButton>
                </Box>
                {Object.entries(spawn_schedules || {}).map(
                  ([name, schedule]) => (
                    <Box
                      key={name}
                      style={{
                        marginBottom: '6px',
                        padding: '8px',
                        borderLeft: `2px solid ${schedule.enabled ? C.green : C.border}`,
                        background: C.panel,
                      }}
                    >
                      <TermRow>
                        <TermValue bold color={C.amber}>
                          {name}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>SCP</TermLabel>
                        <TermValue>{schedule.scp_id}</TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          PLAYERS
                        </TermLabel>
                        <TermValue>
                          {schedule.min_players}-{schedule.max_players}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          PROB
                        </TermLabel>
                        <TermValue color={C.amber}>
                          {Math.round(schedule.spawn_probability * 100)}%
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          STATUS
                        </TermLabel>
                        <TermValue
                          color={schedule.enabled ? C.green : C.textDim}
                        >
                          {schedule.enabled ? 'ACTIVE' : 'INACTIVE'}
                        </TermValue>
                      </TermRow>
                      <Box
                        style={{
                          display: 'flex',
                          gap: '4px',
                          marginTop: '4px',
                        }}
                      >
                        <TermButton
                          color={schedule.enabled ? 'red' : 'green'}
                          onClick={() => act('toggle_spawn_schedule', { name })}
                        >
                          {schedule.enabled ? 'DISABLE' : 'ENABLE'}
                        </TermButton>
                        <TermButton
                          color="red"
                          onClick={() => act('delete_spawn_schedule', { name })}
                        >
                          DELETE
                        </TermButton>
                      </Box>
                    </Box>
                  ),
                )}
              </Box>
            )}

            {selectedTab === 'players' && (
              <Box>
                <TermHeader>PLAYER ACCESS MANAGEMENT</TermHeader>
                {(player_data || []).length > 0 ? (
                  player_data.map((player) => (
                    <Box
                      key={player.key}
                      style={{
                        marginBottom: '6px',
                        padding: '8px',
                        borderLeft: `2px solid ${player.online ? C.green : C.border}`,
                        background: C.panel,
                      }}
                    >
                      <TermRow>
                        <TermValue bold color={C.amber}>
                          {player.name}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>KEY</TermLabel>
                        <TermValue color={C.textDim}>{player.key}</TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>JOB</TermLabel>
                        <TermValue>{player.job}</TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          RANK
                        </TermLabel>
                        <TermValue>{player.rank}</TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          CLEARANCE
                        </TermLabel>
                        <TermValue color={C.amber}>
                          {player.clearance}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          STATUS
                        </TermLabel>
                        <TermValue color={player.online ? C.green : C.textDim}>
                          {player.online ? 'ONLINE' : 'OFFLINE'}
                        </TermValue>
                      </TermRow>
                      <Box style={{ marginTop: '4px' }}>
                        <TermButton onClick={() => {}}>MANAGE</TermButton>
                      </Box>
                    </Box>
                  ))
                ) : (
                  <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
                    NO PLAYER DATA
                  </Box>
                )}
              </Box>
            )}

            {selectedTab === 'containment' && (
              <Box>
                <TermHeader>CONTAINMENT PROTOCOLS</TermHeader>
                {Object.entries(containment_protocols || {}).map(
                  ([id, protocol]) => (
                    <Box
                      key={id}
                      style={{
                        marginBottom: '6px',
                        padding: '8px',
                        borderLeft: `2px solid ${C.borderRed}`,
                        background: C.panel,
                      }}
                    >
                      <TermRow>
                        <TermValue bold color={C.amber}>
                          {protocol.name}
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          EFFECTIVENESS
                        </TermLabel>
                        <TermValue color={C.green}>
                          {Math.round(protocol.effectiveness * 100)}%
                        </TermValue>
                        <TermLabel style={{ marginLeft: '8px' }}>
                          RESPONSE
                        </TermLabel>
                        <TermValue>{protocol.response_time}s</TermValue>
                      </TermRow>
                      <Box
                        style={term({
                          color: C.textDim,
                          fontSize: '11px',
                          fontStyle: 'italic',
                          marginTop: '2px',
                        })}
                      >
                        {protocol.description}
                      </Box>
                      <TermProgressBar
                        label="EFFECTIVENESS"
                        value={Math.round(protocol.effectiveness * 100)}
                        maxValue={100}
                        color={C.green}
                        suffix="%"
                      />
                    </Box>
                  ),
                )}
              </Box>
            )}

            {selectedTab === 'logs' && (
              <Box>
                <TermHeader>SCP LOGS & ANALYTICS</TermHeader>
                <Box
                  style={term({
                    color: C.textDim,
                    fontSize: '11px',
                    fontStyle: 'italic',
                    marginBottom: '12px',
                    borderLeft: `2px solid ${C.amber}`,
                    paddingLeft: '8px',
                  })}
                >
                  Detailed SCP interaction logs and analytics. Use actions below
                  to export or import data.
                </Box>
                <Box style={{ display: 'flex', gap: '4px' }}>
                  <TermButton
                    color="yellow"
                    onClick={() => act('export_scp_data')}
                  >
                    EXPORT ALL DATA
                  </TermButton>
                  <TermButton color="green" onClick={() => {}}>
                    IMPORT DATA
                  </TermButton>
                </Box>
              </Box>
            )}
          </Box>

          {showSpawnModal && (
            <SpawnScheduleModal
              scp_templates={scp_templates}
              onClose={() => setShowSpawnModal(false)}
              act={act}
            />
          )}

          {showConfigModal && selectedSCP && (
            <SCPConfigModal
              scp_template={scp_templates[selectedSCP]}
              scp_id={selectedSCP}
              onClose={() => setShowConfigModal(false)}
              act={act}
            />
          )}

          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '4px 14px',
              background: C.panel,
            }}
          >
            <Box
              style={term({
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              })}
            >
              SCP FOUNDATION | CONTAINMENT MANAGEMENT | ALL ACTIONS LOGGED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};

const SpawnScheduleModal = (props) => {
  const { scp_templates, onClose, act } = props;
  const [name, setName] = useLocalState('spawnScheduleName', '');
  const [scpId, setScpId] = useLocalState('spawnScheduleScpId', '');
  const [minPlayers, setMinPlayers] = useLocalState(
    'spawnScheduleMinPlayers',
    10,
  );
  const [maxPlayers, setMaxPlayers] = useLocalState(
    'spawnScheduleMaxPlayers',
    50,
  );
  const [probability, setProbability] = useLocalState(
    'spawnScheduleProbability',
    0.5,
  );

  const handleSubmit = () => {
    if (name && scpId) {
      act('create_spawn_schedule', {
        name,
        scp_id: scpId,
        min_players: minPlayers,
        max_players: maxPlayers,
        spawn_probability: probability,
      });
      onClose();
    }
  };

  return (
    <TermModal>
      <TermHeader>CREATE SPAWN SCHEDULE</TermHeader>
      <Box style={{ marginBottom: '10px' }}>
        <TermLabel>SCHEDULE NAME</TermLabel>
        <Input
          value={name}
          onChange={(e, value) => setName(value)}
          placeholder="Enter name..."
          style={{ fontFamily: C.mono, fontSize: '14px', height: '32px' }}
        />
      </Box>
      <Box style={{ marginBottom: '10px' }}>
        <TermLabel>SCP ID</TermLabel>
        <Dropdown
          selected={scpId}
          options={Object.keys(scp_templates)}
          onSelected={(value) => setScpId(value)}
        />
      </Box>
      <Box style={{ marginBottom: '10px' }}>
        <TermLabel>MIN PLAYERS</TermLabel>
        <NumberInput
          value={minPlayers}
          minValue={1}
          maxValue={100}
          step={1}
          onChange={(value) => setMinPlayers(value)}
        />
      </Box>
      <Box style={{ marginBottom: '10px' }}>
        <TermLabel>MAX PLAYERS</TermLabel>
        <NumberInput
          value={maxPlayers}
          minValue={minPlayers}
          maxValue={200}
          step={1}
          onChange={(value) => setMaxPlayers(value)}
        />
      </Box>
      <Box style={{ marginBottom: '10px' }}>
        <TermLabel>SPAWN PROBABILITY</TermLabel>
        <NumberInput
          value={probability}
          minValue={0}
          maxValue={1}
          step={0.1}
          onChange={(value) => setProbability(value)}
        />
      </Box>
      <Box style={{ display: 'flex', gap: '4px' }}>
        <TermButton color="green" onClick={handleSubmit}>
          CREATE
        </TermButton>
        <TermButton color="red" onClick={onClose}>
          CANCEL
        </TermButton>
      </Box>
    </TermModal>
  );
};

const SCPConfigModal = (props) => {
  const { scp_template, scp_id, onClose, act } = props;
  const [configTab, setConfigTab] = useLocalState('scpConfigTab', 'spawn');

  if (!scp_template) return null;

  const CONFIG_TABS = [
    { key: 'spawn', label: 'SPAWN' },
    { key: 'access', label: 'ACCESS' },
    { key: 'containment', label: 'CONTAIN' },
  ];

  return (
    <TermModal maxWidth="700px">
      <TermHeader>CONFIGURE — {scp_id}</TermHeader>

      <Box
        style={{
          display: 'flex',
          marginBottom: '12px',
          borderBottom: `1px solid ${C.border}`,
        }}
      >
        {CONFIG_TABS.map((t) => {
          const isActive = configTab === t.key;
          return (
            <Box
              key={t.key}
              style={{
                padding: '4px 10px',
                cursor: 'pointer',
                background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent',
                borderBottom: isActive
                  ? `2px solid ${C.amber}`
                  : '2px solid transparent',
                color: isActive ? C.textBright : C.textDim,
                fontSize: '10px',
                letterSpacing: '0.1em',
                textTransform: 'uppercase',
                fontFamily: C.mono,
              }}
              onClick={() => setConfigTab(t.key)}
            >
              {t.label}
            </Box>
          );
        })}
      </Box>

      {configTab === 'spawn' && (
        <Box>
          <TermRow>
            <TermLabel>MIN PLAYERS</TermLabel>
            <NumberInput
              value={scp_template.spawn_conditions.min_players}
              minValue={1}
              maxValue={100}
              step={1}
              onChange={(value) =>
                act('set_scp_configuration', {
                  scp_id,
                  config_key: 'spawn_conditions.min_players',
                  value,
                })
              }
            />
          </TermRow>
          <TermRow>
            <TermLabel>MIN TIME (MIN)</TermLabel>
            <NumberInput
              value={scp_template.spawn_conditions.min_time}
              minValue={1}
              maxValue={120}
              step={1}
              onChange={(value) =>
                act('set_scp_configuration', {
                  scp_id,
                  config_key: 'spawn_conditions.min_time',
                  value,
                })
              }
            />
          </TermRow>
          <TermRow>
            <TermLabel>SPAWN PROBABILITY</TermLabel>
            <NumberInput
              value={scp_template.spawn_conditions.spawn_probability}
              minValue={0}
              maxValue={1}
              step={0.1}
              onChange={(value) =>
                act('set_scp_configuration', {
                  scp_id,
                  config_key: 'spawn_conditions.spawn_probability',
                  value,
                })
              }
            />
          </TermRow>
        </Box>
      )}

      {configTab === 'access' && (
        <Box>
          <TermRow>
            <TermLabel>MIN RANK</TermLabel>
            <NumberInput
              value={scp_template.player_access.min_rank}
              minValue={1}
              maxValue={10}
              step={1}
              onChange={(value) =>
                act('set_scp_configuration', {
                  scp_id,
                  config_key: 'player_access.min_rank',
                  value,
                })
              }
            />
          </TermRow>
          <TermRow>
            <TermLabel>CLEARANCE</TermLabel>
            <NumberInput
              value={scp_template.player_access.clearance_level}
              minValue={1}
              maxValue={5}
              step={1}
              onChange={(value) =>
                act('set_scp_configuration', {
                  scp_id,
                  config_key: 'player_access.clearance_level',
                  value,
                })
              }
            />
          </TermRow>
          <TermRow>
            <TermLabel>MAX PLAYERS</TermLabel>
            <NumberInput
              value={scp_template.player_access.max_players}
              minValue={1}
              maxValue={20}
              step={1}
              onChange={(value) =>
                act('set_scp_configuration', {
                  scp_id,
                  config_key: 'player_access.max_players',
                  value,
                })
              }
            />
          </TermRow>
        </Box>
      )}

      {configTab === 'containment' && (
        <Box>
          <TermRow>
            <TermLabel>AUTO-CONTAINMENT</TermLabel>
            <TermButton
              color="green"
              selected={!!scp_template.containment_settings.auto_containment}
              onClick={() =>
                act('set_scp_configuration', {
                  scp_id,
                  config_key: 'containment_settings.auto_containment',
                  value: !scp_template.containment_settings.auto_containment,
                })
              }
            >
              {scp_template.containment_settings.auto_containment
                ? 'ENABLED'
                : 'DISABLED'}
            </TermButton>
          </TermRow>
          <TermRow>
            <TermLabel>CONTAINMENT RADIUS</TermLabel>
            <NumberInput
              value={scp_template.containment_settings.containment_radius}
              minValue={1}
              maxValue={50}
              step={1}
              onChange={(value) =>
                act('set_scp_configuration', {
                  scp_id,
                  config_key: 'containment_settings.containment_radius',
                  value,
                })
              }
            />
          </TermRow>
          <TermRow>
            <TermLabel>BREACH RESPONSE (S)</TermLabel>
            <NumberInput
              value={scp_template.containment_settings.breach_response_time}
              minValue={1}
              maxValue={60}
              step={1}
              onChange={(value) =>
                act('set_scp_configuration', {
                  scp_id,
                  config_key: 'containment_settings.breach_response_time',
                  value,
                })
              }
            />
          </TermRow>
        </Box>
      )}

      <Box style={{ display: 'flex', gap: '4px', marginTop: '12px' }}>
        <TermButton color="green" onClick={onClose}>
          SAVE
        </TermButton>
        <TermButton color="red" onClick={onClose}>
          CANCEL
        </TermButton>
      </Box>
    </TermModal>
  );
};
