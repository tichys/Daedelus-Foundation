import { BooleanLike } from 'common/react';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  Modal,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Table,
  Tabs,
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

// Helper functions moved outside component scope
const getSCPStatusColor = (status: string) => {
  switch (status) {
    case 'contained':
      return 'good';
    case 'breached':
      return 'bad';
    case 'warning':
      return 'average';
    default:
      return 'label';
  }
};

const getSCPClassColor = (scpClass: string) => {
  switch (scpClass) {
    case 'Keter':
      return 'bad';
    case 'Euclid':
      return 'average';
    case 'Safe':
      return 'good';
    default:
      return 'label';
  }
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

  return (
    <Window width={1200} height={800} theme="admin">
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            selected={selectedTab === 'overview'}
            onClick={() => setSelectedTab('overview')}
          >
            Overview
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'scps'}
            onClick={() => setSelectedTab('scps')}
          >
            SCP Management
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'spawning'}
            onClick={() => setSelectedTab('spawning')}
          >
            Spawn Control
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'players'}
            onClick={() => setSelectedTab('players')}
          >
            Player Access
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'containment'}
            onClick={() => setSelectedTab('containment')}
          >
            Containment
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedTab === 'logs'}
            onClick={() => setSelectedTab('logs')}
          >
            Logs & Analytics
          </Tabs.Tab>
        </Tabs>

        {selectedTab === 'overview' && (
          <OverviewTab
            scp_data={scp_data}
            scp_templates={scp_templates}
            act={act}
          />
        )}

        {selectedTab === 'scps' && (
          <SCPsTab
            scp_data={scp_data}
            scp_templates={scp_templates}
            selectedSCP={selectedSCP}
            setSelectedSCP={setSelectedSCP}
            setShowConfigModal={setShowConfigModal}
            act={act}
          />
        )}

        {selectedTab === 'spawning' && (
          <SpawningTab
            scp_templates={scp_templates}
            spawn_schedules={spawn_schedules}
            setShowSpawnModal={setShowSpawnModal}
            act={act}
          />
        )}

        {selectedTab === 'players' && (
          <PlayersTab
            player_data={player_data}
            scp_templates={scp_templates}
            act={act}
          />
        )}

        {selectedTab === 'containment' && (
          <ContainmentTab
            containment_protocols={containment_protocols}
            scp_templates={scp_templates}
            act={act}
          />
        )}

        {selectedTab === 'logs' && <LogsTab scp_data={scp_data} act={act} />}

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
      </Window.Content>
    </Window>
  );
};

const OverviewTab = (props: {
  act: any;
  scp_data: SCPData;
  scp_templates: Record<string, SCPTemplate>;
}) => {
  const { scp_data, scp_templates, act } = props;

  return (
    <Box>
      <Section title="Global SCP Status">
        <Flex>
          <Flex.Item grow={1}>
            <LabeledList>
              <LabeledList.Item label="Global Containment Stability">
                <ProgressBar
                  value={scp_data.global_containment_stability}
                  maxValue={100}
                  color={
                    scp_data.global_containment_stability > 80
                      ? 'good'
                      : scp_data.global_containment_stability > 50
                        ? 'average'
                        : 'bad'
                  }
                />
                {scp_data.global_containment_stability}%
              </LabeledList.Item>
              <LabeledList.Item label="Active Breaches">
                <Box color={scp_data.active_breaches > 0 ? 'bad' : 'good'}>
                  {scp_data.active_breaches}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Research Progress">
                <ProgressBar
                  value={scp_data.research_progress}
                  maxValue={100}
                  color="blue"
                />
                {scp_data.research_progress}%
              </LabeledList.Item>
              <LabeledList.Item label="Containment Effectiveness">
                <ProgressBar
                  value={scp_data.containment_effectiveness * 100}
                  maxValue={100}
                  color="green"
                />
                {Math.round(scp_data.containment_effectiveness * 100)}%
              </LabeledList.Item>
            </LabeledList>
          </Flex.Item>
          <Flex.Item grow={1}>
            <LabeledList>
              <LabeledList.Item label="Management Mode">
                <Dropdown
                  selected={scp_data.global_management_mode}
                  options={['standard', 'lockdown', 'research', 'emergency']}
                  onSelected={(value) =>
                    act('set_management_mode', { mode: value })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Auto-Containment">
                <Button
                  selected={scp_data.auto_containment_enabled}
                  onClick={() => act('toggle_auto_containment')}
                >
                  {scp_data.auto_containment_enabled ? 'Enabled' : 'Disabled'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="SCP Rotation">
                <Button
                  selected={scp_data.scp_rotation_enabled}
                  onClick={() => act('toggle_scp_rotation')}
                >
                  {scp_data.scp_rotation_enabled ? 'Enabled' : 'Disabled'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Rotation Interval (minutes)">
                <NumberInput
                  value={Math.round(scp_data.rotation_interval / 600)}
                  minValue={5}
                  maxValue={120}
                  step={1}
                  onChange={(value) =>
                    act('set_rotation_interval', { interval: value })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          </Flex.Item>
        </Flex>
      </Section>

      <Section title="Quick Actions">
        <Flex wrap>
          <Flex.Item>
            <Button
              color="green"
              onClick={() => {
                Object.keys(scp_templates).forEach((scp_id) => {
                  act('enable_scp', { scp_id });
                });
              }}
            >
              Enable All SCPs
            </Button>
          </Flex.Item>
          <Flex.Item>
            <Button
              color="red"
              onClick={() => {
                Object.keys(scp_templates).forEach((scp_id) => {
                  act('disable_scp', { scp_id });
                });
              }}
            >
              Disable All SCPs
            </Button>
          </Flex.Item>
          <Flex.Item>
            <Button color="blue" onClick={() => act('force_scp_rotation')}>
              Force SCP Rotation
            </Button>
          </Flex.Item>
          <Flex.Item>
            <Button color="yellow" onClick={() => act('export_scp_data')}>
              Export Data
            </Button>
          </Flex.Item>
        </Flex>
      </Section>

      <Section title="SCP Instances">
        <Table>
          <Table.Row header>
            <Table.Cell>SCP ID</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Containment Health</Table.Cell>
            <Table.Cell>Interactions</Table.Cell>
            <Table.Cell>Last Interaction</Table.Cell>
            <Table.Cell>Actions</Table.Cell>
          </Table.Row>
          {(scp_data.scp_instances || []).map((instance) => (
            <Table.Row key={instance.id}>
              <Table.Cell>{instance.id}</Table.Cell>
              <Table.Cell>
                <Box color={getSCPStatusColor(instance.containment_status)}>
                  {instance.containment_status}
                </Box>
              </Table.Cell>
              <Table.Cell>
                <ProgressBar
                  value={instance.containment_health}
                  maxValue={100}
                  color={
                    instance.containment_health > 80
                      ? 'good'
                      : instance.containment_health > 50
                        ? 'average'
                        : 'bad'
                  }
                />
                {instance.containment_health}%
              </Table.Cell>
              <Table.Cell>{instance.interaction_count}</Table.Cell>
              <Table.Cell>{instance.last_interaction}</Table.Cell>
              <Table.Cell>
                <Button
                  size="small"
                  onClick={() => act('view_scp_logs', { scp_id: instance.id })}
                >
                  View Logs
                </Button>
                <Button
                  size="small"
                  color="green"
                  onClick={() =>
                    act('force_contain_scp', { scp_id: instance.id })
                  }
                >
                  Contain
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Box>
  );
};

const SCPsTab = (props: {
  act: any;
  scp_data: SCPData;
  scp_templates: Record<string, SCPTemplate>;
  selectedSCP: string;
  setSelectedSCP: (scp: string) => void;
  setShowConfigModal: (show: boolean) => void;
}) => {
  const {
    scp_data,
    scp_templates,
    selectedSCP,
    setSelectedSCP,
    setShowConfigModal,
    act,
  } = props;

  return (
    <Box>
      <Section title="SCP Templates">
        <Table>
          <Table.Row header>
            <Table.Cell>SCP ID</Table.Cell>
            <Table.Cell>Class</Table.Cell>
            <Table.Cell>Description</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Actions</Table.Cell>
          </Table.Row>
          {Object.entries(scp_templates || {}).map(([scp_id, template]) => (
            <Table.Row key={scp_id} selected={selectedSCP === scp_id}>
              <Table.Cell>{scp_id}</Table.Cell>
              <Table.Cell>
                <Box color={getSCPClassColor(template.class)}>
                  {template.class}
                </Box>
              </Table.Cell>
              <Table.Cell>{template.description}</Table.Cell>
              <Table.Cell>
                <Box
                  color={
                    scp_data.enabled_scps.includes(scp_id) ? 'good' : 'bad'
                  }
                >
                  {scp_data.enabled_scps.includes(scp_id)
                    ? 'Enabled'
                    : 'Disabled'}
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Button
                  size="small"
                  color={
                    scp_data.enabled_scps.includes(scp_id) ? 'red' : 'green'
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
                    ? 'Disable'
                    : 'Enable'}
                </Button>
                <Button
                  size="small"
                  onClick={() => {
                    setSelectedSCP(scp_id);
                    setShowConfigModal(true);
                  }}
                >
                  Configure
                </Button>
                <Button
                  size="small"
                  color="blue"
                  onClick={() => act('force_spawn_scp', { scp_id })}
                >
                  Force Spawn
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Box>
  );
};

const SpawningTab = (props: {
  act: any;
  scp_templates: Record<string, SCPTemplate>;
  setShowSpawnModal: (show: boolean) => void;
  spawn_schedules: Record<string, SpawnSchedule>;
}) => {
  const { scp_templates, spawn_schedules, setShowSpawnModal, act } = props;

  return (
    <Box>
      <Section title="Spawn Schedules">
        <Button color="green" onClick={() => setShowSpawnModal(true)}>
          Create New Schedule
        </Button>

        <Table>
          <Table.Row header>
            <Table.Cell>Schedule Name</Table.Cell>
            <Table.Cell>SCP ID</Table.Cell>
            <Table.Cell>Player Range</Table.Cell>
            <Table.Cell>Spawn Probability</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Actions</Table.Cell>
          </Table.Row>
          {Object.entries(spawn_schedules || {}).map(([name, schedule]) => (
            <Table.Row key={name}>
              <Table.Cell>{name}</Table.Cell>
              <Table.Cell>{schedule.scp_id}</Table.Cell>
              <Table.Cell>
                {schedule.min_players}-{schedule.max_players}
              </Table.Cell>
              <Table.Cell>
                {Math.round(schedule.spawn_probability * 100)}%
              </Table.Cell>
              <Table.Cell>
                <Box color={schedule.enabled ? 'good' : 'bad'}>
                  {schedule.enabled ? 'Active' : 'Inactive'}
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Button
                  size="small"
                  color={schedule.enabled ? 'red' : 'green'}
                  onClick={() => act('toggle_spawn_schedule', { name })}
                >
                  {schedule.enabled ? 'Disable' : 'Enable'}
                </Button>
                <Button
                  size="small"
                  color="red"
                  onClick={() => act('delete_spawn_schedule', { name })}
                >
                  Delete
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Box>
  );
};

const PlayersTab = (props: {
  act: any;
  player_data: PlayerData[];
  scp_templates: Record<string, SCPTemplate>;
}) => {
  const { player_data, scp_templates, act } = props;

  return (
    <Box>
      <Section title="Player Access Management">
        <Table>
          <Table.Row header>
            <Table.Cell>Player</Table.Cell>
            <Table.Cell>Job</Table.Cell>
            <Table.Cell>Rank</Table.Cell>
            <Table.Cell>Clearance</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Actions</Table.Cell>
          </Table.Row>
          {(player_data || []).map((player) => (
            <Table.Row key={player.key}>
              <Table.Cell>
                {player.name} ({player.key})
              </Table.Cell>
              <Table.Cell>{player.job}</Table.Cell>
              <Table.Cell>{player.rank}</Table.Cell>
              <Table.Cell>{player.clearance}</Table.Cell>
              <Table.Cell>
                <Box color={player.online ? 'good' : 'bad'}>
                  {player.online ? 'Online' : 'Offline'}
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Button
                  size="small"
                  onClick={() => {
                    // Open player permissions modal
                  }}
                >
                  Manage Permissions
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Box>
  );
};

const ContainmentTab = (props: {
  act: any;
  containment_protocols: Record<string, ContainmentProtocol>;
  scp_templates: Record<string, SCPTemplate>;
}) => {
  const { containment_protocols, scp_templates, act } = props;

  return (
    <Box>
      <Section title="Containment Protocols">
        <Table>
          <Table.Row header>
            <Table.Cell>Protocol</Table.Cell>
            <Table.Cell>Description</Table.Cell>
            <Table.Cell>Effectiveness</Table.Cell>
            <Table.Cell>Response Time</Table.Cell>
            <Table.Cell>Requirements</Table.Cell>
          </Table.Row>
          {Object.entries(containment_protocols || {}).map(([id, protocol]) => (
            <Table.Row key={id}>
              <Table.Cell>{protocol.name}</Table.Cell>
              <Table.Cell>{protocol.description}</Table.Cell>
              <Table.Cell>
                <ProgressBar
                  value={protocol.effectiveness * 100}
                  maxValue={100}
                  color="green"
                />
                {Math.round(protocol.effectiveness * 100)}%
              </Table.Cell>
              <Table.Cell>{protocol.response_time}s</Table.Cell>
              <Table.Cell>{protocol.requirements.join(', ')}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Box>
  );
};

const LogsTab = (props: { act: any; scp_data: SCPData }) => {
  const { scp_data, act } = props;

  return (
    <Box>
      <Section title="SCP Logs & Analytics">
        <NoticeBox>
          This section provides access to detailed SCP interaction logs and
          analytics. Use the buttons below to view specific SCP logs or export
          data.
        </NoticeBox>

        <Flex wrap>
          <Flex.Item>
            <Button color="blue" onClick={() => act('export_scp_data')}>
              Export All Data
            </Button>
          </Flex.Item>
          <Flex.Item>
            <Button
              color="green"
              onClick={() => {
                // Open import modal
              }}
            >
              Import Data
            </Button>
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const SpawnScheduleModal = (props: {
  act: any;
  onClose: () => void;
  scp_templates: Record<string, SCPTemplate>;
}) => {
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
    <Modal>
      <Section title="Create Spawn Schedule">
        <LabeledList>
          <LabeledList.Item label="Schedule Name">
            <Input
              value={name}
              onChange={(e, value) => setName(value)}
              placeholder="Enter schedule name"
            />
          </LabeledList.Item>
          <LabeledList.Item label="SCP ID">
            <Dropdown
              selected={scpId}
              options={Object.keys(scp_templates)}
              onSelected={(value) => setScpId(value)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Min Players">
            <NumberInput
              value={minPlayers}
              minValue={1}
              maxValue={100}
              step={1}
              onChange={(value) => setMinPlayers(value)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Max Players">
            <NumberInput
              value={maxPlayers}
              minValue={minPlayers}
              maxValue={200}
              step={1}
              onChange={(value) => setMaxPlayers(value)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Spawn Probability">
            <NumberInput
              value={probability}
              minValue={0}
              maxValue={1}
              step={0.1}
              onChange={(value) => setProbability(value)}
            />
          </LabeledList.Item>
        </LabeledList>

        <Flex>
          <Flex.Item grow={1}>
            <Button color="green" onClick={handleSubmit}>
              Create Schedule
            </Button>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Button color="red" onClick={onClose}>
              Cancel
            </Button>
          </Flex.Item>
        </Flex>
      </Section>
    </Modal>
  );
};

const SCPConfigModal = (props: {
  act: any;
  onClose: () => void;
  scp_id: string;
  scp_template: SCPTemplate;
}) => {
  const { scp_template, scp_id, onClose, act } = props;

  return (
    <Modal width={800}>
      <Section title={`Configure ${scp_id}`}>
        <Tabs>
          <Tabs.Tab label="Spawn Conditions">
            <LabeledList>
              <LabeledList.Item label="Min Players">
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
              </LabeledList.Item>
              <LabeledList.Item label="Min Time (minutes)">
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
              </LabeledList.Item>
              <LabeledList.Item label="Spawn Probability">
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
              </LabeledList.Item>
            </LabeledList>
          </Tabs.Tab>

          <Tabs.Tab label="Player Access">
            <LabeledList>
              <LabeledList.Item label="Min Rank">
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
              </LabeledList.Item>
              <LabeledList.Item label="Clearance Level">
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
              </LabeledList.Item>
              <LabeledList.Item label="Max Players">
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
              </LabeledList.Item>
            </LabeledList>
          </Tabs.Tab>

          <Tabs.Tab label="Containment">
            <LabeledList>
              <LabeledList.Item label="Auto-Containment">
                <Button
                  selected={scp_template.containment_settings.auto_containment}
                  onClick={() =>
                    act('set_scp_configuration', {
                      scp_id,
                      config_key: 'containment_settings.auto_containment',
                      value:
                        !scp_template.containment_settings.auto_containment,
                    })
                  }
                >
                  {scp_template.containment_settings.auto_containment
                    ? 'Enabled'
                    : 'Disabled'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Containment Radius">
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
              </LabeledList.Item>
              <LabeledList.Item label="Breach Response Time">
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
              </LabeledList.Item>
            </LabeledList>
          </Tabs.Tab>
        </Tabs>

        <Flex>
          <Flex.Item grow={1}>
            <Button color="green" onClick={onClose}>
              Save Configuration
            </Button>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Button color="red" onClick={onClose}>
              Cancel
            </Button>
          </Flex.Item>
        </Flex>
      </Section>
    </Modal>
  );
};
