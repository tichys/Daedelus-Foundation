import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type DepartmentStatusBoardData = {
  departments: Department[];
  display_mode: number;
  show_detailed: boolean;
  operational: boolean;
  powered: boolean;
  research_points?: number;
  active_goals?: number;
  completed_goals?: number;
};

type Department = {
  id: string;
  name: string;
  balance: number;
  status: string;
  color: string;
};

enum DisplayMode {
  Budgets = 0,
  Status = 1,
  Combined = 2,
}

export const DepartmentStatusBoard = (_) => {
  const { act, data } = useBackend<DepartmentStatusBoardData>();
  const [tab, setTab] = useLocalState('tab', 1);

  const {
    departments,
    display_mode,
    show_detailed,
    operational,
    powered,
    research_points,
    active_goals,
    completed_goals,
  } = data;

  if (!operational || !powered) {
    return (
      <Window title="Department Status Board" width={600} height={400}>
        <Window.Content>
          <NoticeBox danger>
            <Icon name="exclamation-triangle" />
            System Offline
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window title="Department Status Board" width={700} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
                <Icon name="dollar-sign" /> Budget Overview
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
                <Icon name="chart-line" /> Status Report
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
                <Icon name="flask" /> Research Status
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="sync"
                  onClick={() => act('toggle_display_mode')}
                >
                  Display Mode:{' '}
                  {display_mode === DisplayMode.Budgets
                    ? 'Budgets'
                    : display_mode === DisplayMode.Status
                      ? 'Status'
                      : 'Combined'}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={show_detailed ? 'eye-slash' : 'eye'}
                  onClick={() => act('toggle_detailed')}
                >
                  {show_detailed ? 'Hide' : 'Show'} Details
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 1 && (
              <BudgetOverviewTab
                departments={departments}
                show_detailed={show_detailed}
              />
            )}
            {tab === 2 && <StatusReportTab departments={departments} />}
            {tab === 3 && (
              <ResearchStatusTab
                research_points={research_points}
                active_goals={active_goals}
                completed_goals={completed_goals}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BudgetOverviewTab = (props: {
  departments: Department[];
  show_detailed: boolean;
}) => {
  const { departments, show_detailed } = props;

  const totalBudget = departments.reduce((sum, dept) => sum + dept.balance, 0);
  const averageBudget =
    departments.length > 0 ? totalBudget / departments.length : 0;

  return (
    <Section title="Department Budgets" fill scrollable>
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Total Budget">
              <Box color={totalBudget >= 0 ? 'good' : 'bad'} bold>
                {totalBudget.toLocaleString()} cr
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Average Budget">
              <Box color={averageBudget >= 0 ? 'good' : 'bad'} bold>
                {averageBudget.toLocaleString()} cr
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item grow>
          <Table>
            <Table.Row header>
              <Table.Cell>Department</Table.Cell>
              <Table.Cell>Budget</Table.Cell>
              <Table.Cell>Status</Table.Cell>
              {show_detailed && <Table.Cell>Details</Table.Cell>}
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
                  <Box style={{ color: dept.color }} bold>
                    {dept.status}
                  </Box>
                </Table.Cell>
                {show_detailed && (
                  <Table.Cell>
                    <ProgressBar
                      value={Math.max(0, dept.balance)}
                      maxValue={Math.max(2000, dept.balance + 1000)}
                      color={dept.balance >= 0 ? 'good' : 'bad'}
                    />
                  </Table.Cell>
                )}
              </Table.Row>
            ))}
          </Table>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const StatusReportTab = (props: { departments: Department[] }) => {
  const { departments } = props;

  const statusCounts = {
    EXCELLENT: 0,
    GOOD: 0,
    ADEQUATE: 0,
    LOW: 0,
    CRITICAL: 0,
  };

  departments.forEach((dept) => {
    statusCounts[dept.status] = (statusCounts[dept.status] || 0) + 1;
  });

  const totalDepartments = departments.length;
  const healthyDepartments =
    statusCounts.EXCELLENT + statusCounts.GOOD + statusCounts.ADEQUATE;
  const criticalDepartments = statusCounts.CRITICAL;

  return (
    <Section title="Department Status Report" fill scrollable>
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Total Departments">
              {totalDepartments}
            </LabeledList.Item>
            <LabeledList.Item label="Healthy Departments">
              <Box color="good" bold>
                {healthyDepartments}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Critical Departments">
              <Box color="bad" bold>
                {criticalDepartments}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <Section title="Status Distribution">
            <Stack>
              <Stack.Item grow>
                <Box color="good" bold>
                  Excellent: {statusCounts.EXCELLENT}
                </Box>
              </Stack.Item>
              <Stack.Item grow>
                <Box color="average" bold>
                  Good: {statusCounts.GOOD}
                </Box>
              </Stack.Item>
              <Stack.Item grow>
                <Box color="yellow" bold>
                  Adequate: {statusCounts.ADEQUATE}
                </Box>
              </Stack.Item>
              <Stack.Item grow>
                <Box color="orange" bold>
                  Low: {statusCounts.LOW}
                </Box>
              </Stack.Item>
              <Stack.Item grow>
                <Box color="bad" bold>
                  Critical: {statusCounts.CRITICAL}
                </Box>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Table>
            <Table.Row header>
              <Table.Cell>Department</Table.Cell>
              <Table.Cell>Status</Table.Cell>
              <Table.Cell>Budget</Table.Cell>
            </Table.Row>
            {departments
              .sort((a, b) => {
                const statusOrder = {
                  EXCELLENT: 0,
                  GOOD: 1,
                  ADEQUATE: 2,
                  LOW: 3,
                  CRITICAL: 4,
                };
                return statusOrder[a.status] - statusOrder[b.status];
              })
              .map((dept) => (
                <Table.Row key={dept.id}>
                  <Table.Cell>
                    <Box bold>{dept.name}</Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: dept.color }} bold>
                      {dept.status}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box color={dept.balance >= 0 ? 'good' : 'bad'} bold>
                      {dept.balance.toLocaleString()} cr
                    </Box>
                  </Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ResearchStatusTab = (props: {
  research_points?: number;
  active_goals?: number;
  completed_goals?: number;
}) => {
  const { research_points, active_goals, completed_goals } = props;

  return (
    <Section title="Research & Development Status" fill scrollable>
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Total Research Points">
              <Box color="blue" bold>
                {research_points || 0}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Active Goals">
              <Box color="average" bold>
                {active_goals || 0}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Completed Goals">
              <Box color="good" bold>
                {completed_goals || 0}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <NoticeBox info>
            <Icon name="info-circle" />
            Research progress directly impacts R&D department funding. Complete
            goals to increase departmental budgets.
          </NoticeBox>
        </Stack.Item>
        <Stack.Item>
          <NoticeBox warning>
            <Icon name="exclamation-triangle" />
            Violations of Foundation protocols may result in budget penalties
            and research point deductions.
          </NoticeBox>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
