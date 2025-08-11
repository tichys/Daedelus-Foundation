import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Dropdown,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type FoundationEconomyConsoleData = {
  departments: Department[];
  penalties: Record<string, PenaltyDefinition>;
  audit_log: AuditLogEntry[];
  user_access: UserAccess;
};

type Department = {
  id: string;
  name: string;
  balance: number;
  can_transfer: boolean;
};

type PenaltyDefinition = {
  name: string;
  description: string;
  department: string;
  amount: number;
  points: number;
};

type AuditLogEntry = {
  time: number;
  user: string;
  user_name: string;
  action: string;
  details: string;
  amount: number;
  department: string;
};

type UserAccess = {
  can_penalize: boolean;
  can_transfer: boolean;
  can_view_logs: boolean;
};

enum Tab {
  Budgets = 1,
  Penalties = 2,
  Transfers = 3,
  AuditLog = 4,
}

export const FoundationEconomyConsole = (_) => {
  const { act, data } = useBackend<FoundationEconomyConsoleData>();
  const [tab, setTab] = useLocalState('tab', Tab.Budgets);

  const { departments, penalties, audit_log, user_access } = data;

  return (
    <Window title="Foundation Economy Console" width={800} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={tab === Tab.Budgets}
                onClick={() => setTab(Tab.Budgets)}
              >
                <Icon name="dollar-sign" /> Department Budgets
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Penalties}
                onClick={() => setTab(Tab.Penalties)}
                disabled={!user_access.can_penalize}
              >
                <Icon name="exclamation-triangle" /> Penalties
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Transfers}
                onClick={() => setTab(Tab.Transfers)}
                disabled={!user_access.can_transfer}
              >
                <Icon name="exchange-alt" /> Transfers
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.AuditLog}
                onClick={() => setTab(Tab.AuditLog)}
                disabled={!user_access.can_view_logs}
              >
                <Icon name="history" /> Audit Log
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === Tab.Budgets && <BudgetsTab departments={departments} />}
            {tab === Tab.Penalties && (
              <PenaltiesTab penalties={penalties} departments={departments} />
            )}
            {tab === Tab.Transfers && (
              <TransfersTab departments={departments} />
            )}
            {tab === Tab.AuditLog && <AuditLogTab audit_log={audit_log} />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BudgetsTab = (props: { departments: Department[] }) => {
  const { departments } = props;

  return (
    <Section title="Department Budgets" fill scrollable>
      <Table>
        <Table.Row header>
          <Table.Cell>Department</Table.Cell>
          <Table.Cell>Budget</Table.Cell>
          <Table.Cell>Status</Table.Cell>
        </Table.Row>
        {departments.map((dept) => (
          <Table.Row key={dept.id}>
            <Table.Cell>
              <Box bold>{dept.name}</Box>
            </Table.Cell>
            <Table.Cell>
              <Box color={dept.balance >= 0 ? 'good' : 'bad'} bold>
                {dept.balance.toLocaleString()} cr
              </Box>
            </Table.Cell>
            <Table.Cell>
              <Box
                color={
                  dept.balance > 1000
                    ? 'good'
                    : dept.balance > 0
                      ? 'average'
                      : 'bad'
                }
              >
                {dept.balance > 1000
                  ? 'Excellent'
                  : dept.balance > 0
                    ? 'Adequate'
                    : 'Critical'}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const PenaltiesTab = (props: {
  penalties: Record<string, PenaltyDefinition>;
  departments: Department[];
}) => {
  const { act } = useBackend();
  const { penalties, departments } = props;
  const [selectedPenalty, setSelectedPenalty] = useLocalState(
    'selectedPenalty',
    '',
  );
  const [selectedDepartment, setSelectedDepartment] = useLocalState(
    'selectedDepartment',
    '',
  );

  const penaltyEntries = Object.entries(penalties);

  return (
    <Stack fill>
      <Stack.Item width="50%">
        <Section title="Available Penalties" fill scrollable>
          {penaltyEntries.map(([key, penalty]) => (
            <Collapsible
              key={key}
              title={penalty.name}
              open={selectedPenalty === key}
              onToggle={() =>
                setSelectedPenalty(selectedPenalty === key ? '' : key)
              }
            >
              <Box mb={1}>
                <strong>Description:</strong> {penalty.description}
              </Box>
              <Box mb={1}>
                <strong>Default Department:</strong> {penalty.department}
              </Box>
              <Box mb={1}>
                <strong>Amount:</strong>{' '}
                <Box color="bad" inline>
                  {penalty.amount} cr
                </Box>
              </Box>
              <Box mb={1}>
                <strong>Research Points:</strong>{' '}
                <Box color="bad" inline>
                  {penalty.points}
                </Box>
              </Box>
              <Button
                fluid
                color="bad"
                icon="exclamation-triangle"
                onClick={() => {
                  setSelectedPenalty(key);
                  setSelectedDepartment(penalty.department);
                }}
              >
                Select Penalty
              </Button>
            </Collapsible>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item width="50%">
        <Section title="Apply Penalty" fill>
          {selectedPenalty ? (
            <Stack vertical>
              <Stack.Item>
                <Box bold>
                  Selected Penalty: {penalties[selectedPenalty]?.name}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Dropdown
                  label="Target Department"
                  options={departments.map((dept) => ({
                    value: dept.id,
                    displayText: dept.name,
                  }))}
                  selected={selectedDepartment}
                  onSelected={setSelectedDepartment}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  color="bad"
                  icon="exclamation-triangle"
                  disabled={!selectedDepartment}
                  onClick={() => {
                    act('apply_penalty', {
                      penalty_type: selectedPenalty,
                      department: selectedDepartment,
                    });
                    setSelectedPenalty('');
                    setSelectedDepartment('');
                  }}
                >
                  Apply Penalty
                </Button>
              </Stack.Item>
            </Stack>
          ) : (
            <NoticeBox>Select a penalty from the left panel.</NoticeBox>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const TransfersTab = (props: { departments: Department[] }) => {
  const { act } = useBackend();
  const { departments } = props;
  const [fromDepartment, setFromDepartment] = useLocalState(
    'fromDepartment',
    '',
  );
  const [toDepartment, setToDepartment] = useLocalState('toDepartment', '');
  const [amount, setAmount] = useLocalState('transferAmount', 100);

  const transferableDepartments = departments.filter(
    (dept) => dept.can_transfer,
  );

  return (
    <Section title="Budget Transfers" fill>
      <Stack vertical>
        <Stack.Item>
          <Dropdown
            label="From Department"
            options={transferableDepartments.map((dept) => ({
              value: dept.id,
              displayText: `${dept.name} (${dept.balance} cr)`,
            }))}
            selected={fromDepartment}
            onSelected={setFromDepartment}
          />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            label="To Department"
            options={departments.map((dept) => ({
              value: dept.id,
              displayText: dept.name,
            }))}
            selected={toDepartment}
            onSelected={setToDepartment}
          />
        </Stack.Item>
        <Stack.Item>
          <NumberInput
            label="Amount (credits)"
            value={amount}
            minValue={1}
            maxValue={999999}
            step={100}
            onChange={(_, value) => setAmount(value)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            color="blue"
            icon="exchange-alt"
            disabled={
              !fromDepartment ||
              !toDepartment ||
              fromDepartment === toDepartment ||
              amount <= 0
            }
            onClick={() => {
              act('transfer_budget', {
                from_department: fromDepartment,
                to_department: toDepartment,
                amount: amount,
              });
              setFromDepartment('');
              setToDepartment('');
              setAmount(100);
            }}
          >
            Transfer Budget
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AuditLogTab = (props: { audit_log: AuditLogEntry[] }) => {
  const { audit_log } = props;

  const formatTime = (time: number) => {
    const date = new Date(time);
    return date.toLocaleTimeString();
  };

  return (
    <Section title="Audit Log" fill scrollable>
      <Table>
        <Table.Row header>
          <Table.Cell>Time</Table.Cell>
          <Table.Cell>User</Table.Cell>
          <Table.Cell>Action</Table.Cell>
          <Table.Cell>Details</Table.Cell>
          <Table.Cell>Amount</Table.Cell>
          <Table.Cell>Department</Table.Cell>
        </Table.Row>
        {audit_log.map((entry, index) => (
          <Table.Row key={index}>
            <Table.Cell>{formatTime(entry.time)}</Table.Cell>
            <Table.Cell>{entry.user_name}</Table.Cell>
            <Table.Cell>
              <Box
                color={
                  entry.action === 'penalty'
                    ? 'bad'
                    : entry.action === 'transfer'
                      ? 'blue'
                      : 'normal'
                }
              >
                {entry.action}
              </Box>
            </Table.Cell>
            <Table.Cell>{entry.details}</Table.Cell>
            <Table.Cell>
              <Box color={entry.amount >= 0 ? 'good' : 'bad'} bold>
                {entry.amount} cr
              </Box>
            </Table.Cell>
            <Table.Cell>{entry.department}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
