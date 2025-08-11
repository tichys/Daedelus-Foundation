import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
  TextArea,
} from '../components';
import { Window } from '../layouts';

type ScpResearchConsoleData = {
  points_total: number;
  points_by_designation: Record<string, number>;
  points_by_player: Record<string, number>;
  active_goals: ActiveGoal[];
  completed_goals: CompletedGoal[];
  reports: Report[];
  recent_events: EventLogEntry[];
};

type ActiveGoal = {
  id: string;
  title: string;
  desc: string;
  current_count: number;
  required_count: number;
  points_reward: number;
  cash_reward: number;
  budget_reward: number;
  repeatable: boolean;
};

type CompletedGoal = {
  id: string;
  title: string;
  times_completed: number;
};

type Report = {
  id: string;
  title: string;
  designation: string;
  name: string;
  body: string;
  time: number;
};

type EventLogEntry = {
  time: number;
  designation: string;
  event: string;
  name: string;
  details: string;
};

enum Tab {
  Overview = 1,
  Goals = 2,
  Reports = 3,
  Events = 4,
}

export const ScpResearchConsole = (_) => {
  const { act, data } = useBackend<ScpResearchConsoleData>();
  const [tab, setTab] = useLocalState('tab', Tab.Overview);

  const {
    points_total = 0,
    points_by_designation = {},
    points_by_player = {},
    active_goals = [],
    completed_goals = [],
    reports = [],
    recent_events = [],
  } = data || {};

  return (
    <Window title="SCP Research Terminal" width={900} height={700}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Box
              style={{
                background: 'linear-gradient(90deg, #0b0e11 0%, #1a1f2e 100%)',
                color: '#73ffa6',
                padding: '8px 12px',
                borderBottom: '2px solid #1d2a2a',
                fontFamily: 'Consolas, monospace',
                fontSize: '16px',
                fontWeight: 'bold',
              }}
            >
              <Icon name="flask" /> SCP FOUNDATION // RESEARCH TERMINAL
            </Box>
            <Box
              style={{
                background: '#0b0e11',
                color: '#7aa5a5',
                padding: '4px 12px',
                fontSize: '12px',
                fontFamily: 'Consolas, monospace',
              }}
            >
              ACCESS: LEVEL 2 // CLASSIFIED
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={tab === Tab.Overview}
                onClick={() => setTab(Tab.Overview)}
              >
                <Icon name="chart-line" /> Overview
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Goals}
                onClick={() => setTab(Tab.Goals)}
              >
                <Icon name="target" /> Goals
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Reports}
                onClick={() => setTab(Tab.Reports)}
              >
                <Icon name="file-alt" /> Reports
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Events}
                onClick={() => setTab(Tab.Events)}
              >
                <Icon name="history" /> Events
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === Tab.Overview && (
              <OverviewTab
                points_total={points_total}
                points_by_designation={points_by_designation}
                points_by_player={points_by_player}
              />
            )}
            {tab === Tab.Goals && (
              <GoalsTab
                active_goals={active_goals}
                completed_goals={completed_goals}
              />
            )}
            {tab === Tab.Reports && <ReportsTab reports={reports} />}
            {tab === Tab.Events && <EventsTab recent_events={recent_events} />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const OverviewTab = (props: {
  points_total: number;
  points_by_designation: Record<string, number>;
  points_by_player: Record<string, number>;
}) => {
  const { points_total, points_by_designation, points_by_player } = props;

  // Ensure we have valid objects to work with
  const designationData = points_by_designation || {};
  const playerData = points_by_player || {};

  return (
    <Stack fill>
      <Stack.Item width="50%">
        <Section title="Research Statistics" fill>
          <LabeledList>
            <LabeledList.Item label="Total Research Points">
              <Box color="green" bold>
                {points_total}
              </Box>
            </LabeledList.Item>
          </LabeledList>
          <Divider />
          <Box bold color="green" mb={1}>
            Points by SCP Designation
          </Box>
          <Table>
            <Table.Row header>
              <Table.Cell>SCP</Table.Cell>
              <Table.Cell>Points</Table.Cell>
            </Table.Row>
            {Object.entries(designationData)
              .sort(([, a], [, b]) => b - a)
              .map(([designation, points]) => (
                <Table.Row key={designation}>
                  <Table.Cell>
                    <Box bold>SCP-{designation}</Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box color="green">{points}</Box>
                  </Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item width="50%">
        <Section title="Top Researchers" fill>
          <Table>
            <Table.Row header>
              <Table.Cell>Researcher</Table.Cell>
              <Table.Cell>Points</Table.Cell>
            </Table.Row>
            {Object.entries(playerData)
              .sort(([, a], [, b]) => b - a)
              .slice(0, 10)
              .map(([ckey, points]) => (
                <Table.Row key={ckey}>
                  <Table.Cell>{ckey}</Table.Cell>
                  <Table.Cell>
                    <Box color="green">{points}</Box>
                  </Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const GoalsTab = (props: {
  active_goals: ActiveGoal[];
  completed_goals: CompletedGoal[];
}) => {
  const { active_goals, completed_goals } = props;

  // Ensure we have valid arrays to work with
  const activeGoals = active_goals || [];
  const completedGoals = completed_goals || [];

  return (
    <Stack fill>
      <Stack.Item width="60%">
        <Section title="Active Research Goals" fill scrollable>
          {activeGoals.length === 0 ? (
            <NoticeBox info>No active research goals.</NoticeBox>
          ) : (
            activeGoals.map((goal) => (
              <Collapsible key={goal.id} title={goal.title}>
                <Box mb={1}>
                  <strong>Description:</strong> {goal.desc}
                </Box>
                <Box mb={1}>
                  <strong>Progress:</strong>{' '}
                  <Box color="green" inline>
                    {goal.current_count}/{goal.required_count}
                  </Box>
                </Box>
                <ProgressBar
                  value={goal.current_count}
                  maxValue={goal.required_count}
                  color="green"
                  mb={1}
                />
                <Box mb={1}>
                  <strong>Rewards:</strong>
                  <Box color="green" inline>
                    {' '}
                    {goal.points_reward} pts, {goal.cash_reward} cr
                  </Box>
                  {goal.budget_reward > 0 && (
                    <Box color="blue" inline>
                      , {goal.budget_reward} budget
                    </Box>
                  )}
                  {goal.repeatable && (
                    <Box color="orange" inline>
                      {' '}
                      (Repeatable)
                    </Box>
                  )}
                </Box>
              </Collapsible>
            ))
          )}
        </Section>
      </Stack.Item>
      <Stack.Item width="40%">
        <Section title="Completed Goals" fill scrollable>
          {completedGoals.length === 0 ? (
            <NoticeBox info>No completed goals yet.</NoticeBox>
          ) : (
            completedGoals.map((goal) => (
              <Box key={goal.id} mb={1}>
                <Box bold>{goal.title}</Box>
                <Box color="green">
                  Completed {goal.times_completed} time(s)
                </Box>
              </Box>
            ))
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ReportsTab = (props: { reports: Report[] }) => {
  const { reports } = props;

  // Ensure we have a valid array to work with
  const reportsList = reports || [];
  const [showSubmit, setShowSubmit] = useLocalState('showSubmit', false);
  const [reportTitle, setReportTitle] = useLocalState('reportTitle', '');
  const [reportDesignation, setReportDesignation] = useLocalState(
    'reportDesignation',
    '',
  );
  const [reportBody, setReportBody] = useLocalState('reportBody', '');

  const { act } = useBackend();

  const handleSubmit = () => {
    console.log('handleSubmit called with:', {
      reportTitle,
      reportDesignation,
      reportBody,
    });

    if (!reportTitle || !reportBody) {
      console.log('handleSubmit: Missing title or body, returning');
      return;
    }

    console.log('handleSubmit: Calling act with submit_report');
    act('submit_report', {
      title: reportTitle,
      designation: reportDesignation,
      body: reportBody,
    });

    console.log('handleSubmit: Clearing form and hiding submit');
    setReportTitle('');
    setReportDesignation('');
    setReportBody('');
    setShowSubmit(false);
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <NoticeBox
          info
          style={{
            backgroundColor: '#1a1f2e',
            border: '1px solid #1d2a2a',
            color: '#73ffa6',
            marginBottom: '8px',
          }}
        >
          <strong>Research Report Guidelines:</strong>
          <br />
          • Title: Brief, descriptive summary of findings
          <br />
          • SCP Designation: The SCP number being documented (e.g., 106, 049)
          <br />
          • Body: Detailed observations, analysis, and conclusions
          <br />• Reports are automatically saved and contribute to research
          progress
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          icon={showSubmit ? 'times' : 'plus'}
          onClick={() => setShowSubmit(!showSubmit)}
          style={{
            backgroundColor: showSubmit ? '#5a2a2a' : '#2a5a2a',
            border: '2px solid #1d2a2a',
            color: showSubmit ? '#ff7373' : '#73ffa6',
            fontWeight: 'bold',
            fontSize: '16px',
            padding: '12px',
            marginBottom: '8px',
          }}
        >
          {showSubmit ? 'Cancel Report Submission' : 'Create New Report'}
        </Button>
      </Stack.Item>
      {showSubmit && (
        <Stack.Item>
          <Section
            title="Submit Research Report"
            style={{
              background: 'linear-gradient(135deg, #1a1f2e 0%, #0b0e11 100%)',
              border: '2px solid #1d2a2a',
              borderRadius: '8px',
            }}
          >
            <Stack vertical spacing={2}>
              <Stack.Item>
                <Box style={{ marginBottom: '8px' }}>
                  <Box
                    style={{
                      color: '#73ffa6',
                      fontWeight: 'bold',
                      marginBottom: '4px',
                    }}
                  >
                    Report Title: ({reportTitle.length}/128)
                  </Box>
                  <Input
                    value={reportTitle}
                    onChange={(_, value) => {
                      console.log('Title changed to:', value);
                      setReportTitle(value);
                    }}
                    maxLength={128}
                    placeholder="Enter report title..."
                    style={{
                      backgroundColor: '#0b0e11',
                      border: '1px solid #1d2a2a',
                      color: '#ffffff',
                    }}
                  />
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Box style={{ marginBottom: '8px' }}>
                  <Box
                    style={{
                      color: '#73ffa6',
                      fontWeight: 'bold',
                      marginBottom: '4px',
                    }}
                  >
                    SCP Designation: ({reportDesignation.length}/8)
                  </Box>
                  <Input
                    value={reportDesignation}
                    onChange={(_, value) => setReportDesignation(value)}
                    maxLength={8}
                    placeholder="e.g., 106, 049, 096..."
                    style={{
                      backgroundColor: '#0b0e11',
                      border: '1px solid #1d2a2a',
                      color: '#ffffff',
                    }}
                  />
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Box style={{ marginBottom: '8px' }}>
                  <Box
                    style={{
                      color: '#73ffa6',
                      fontWeight: 'bold',
                      marginBottom: '4px',
                    }}
                  >
                    Report Body: ({reportBody.length}/8000)
                  </Box>
                  <TextArea
                    value={reportBody}
                    onChange={(_, value) => {
                      console.log('Body changed to:', value);
                      setReportBody(value);
                    }}
                    rows={8}
                    maxLength={8000}
                    placeholder="Enter your research findings, observations, and analysis..."
                    style={{
                      backgroundColor: '#0b0e11',
                      border: '1px solid #1d2a2a',
                      color: '#ffffff',
                      fontFamily: 'Consolas, monospace',
                      fontSize: '14px',
                    }}
                  />
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  color="green"
                  icon="paper-plane"
                  disabled={!reportTitle || !reportBody}
                  onClick={handleSubmit}
                  style={{
                    backgroundColor:
                      reportTitle && reportBody ? '#2d5a2d' : '#1a2a1a',
                    border: '2px solid #1d2a2a',
                    color: reportTitle && reportBody ? '#73ffa6' : '#4a5a4a',
                    fontWeight: 'bold',
                    fontSize: '16px',
                    padding: '12px',
                    cursor:
                      reportTitle && reportBody ? 'pointer' : 'not-allowed',
                  }}
                >
                  {reportTitle && reportBody
                    ? 'Submit Report'
                    : `Fill in title and body to submit (Title: ${reportTitle ? '✓' : '✗'}, Body: ${reportBody ? '✓' : '✗'})`}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  color="blue"
                  icon="bug"
                  onClick={() => {
                    alert('Test button clicked!');
                    console.log('Test button clicked!');
                  }}
                  style={{
                    backgroundColor: '#2a2a5a',
                    border: '2px solid #1d2a2a',
                    color: '#73a6ff',
                    fontWeight: 'bold',
                    fontSize: '14px',
                    padding: '8px',
                  }}
                >
                  Test Button (Alert Only)
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  color="red"
                  icon="paper-plane"
                  onClick={() => {
                    console.log('Act test button clicked!');
                    act('test_action', { test: 'data' });
                  }}
                  style={{
                    backgroundColor: '#5a2a2a',
                    border: '2px solid #1d2a2a',
                    color: '#ff7373',
                    fontWeight: 'bold',
                    fontSize: '14px',
                    padding: '8px',
                  }}
                >
                  Test Act Function
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <Section
          title="Recent Reports"
          fill
          scrollable
          style={{
            background: 'linear-gradient(135deg, #1a1f2e 0%, #0b0e11 100%)',
            border: '2px solid #1d2a2a',
            borderRadius: '8px',
          }}
        >
          {reportsList.length === 0 ? (
            <NoticeBox
              info
              style={{
                backgroundColor: '#1a1f2e',
                border: '1px solid #1d2a2a',
                color: '#73ffa6',
              }}
            >
              No reports submitted yet. Be the first to document your findings!
            </NoticeBox>
          ) : (
            reportsList.map((report) => (
              <Collapsible
                key={report.id}
                title={
                  <Box style={{ color: '#73ffa6', fontWeight: 'bold' }}>
                    {report.title}
                  </Box>
                }
                style={{
                  backgroundColor: '#0b0e11',
                  border: '1px solid #1d2a2a',
                  marginBottom: '8px',
                  borderRadius: '4px',
                }}
              >
                <Box style={{ padding: '8px', color: '#ffffff' }}>
                  <Box mb={1} style={{ color: '#73ffa6' }}>
                    <strong>SCP Designation:</strong> SCP-{report.designation}
                  </Box>
                  <Box mb={1} style={{ color: '#73ffa6' }}>
                    <strong>Submitted by:</strong> {report.name}
                  </Box>
                  <Box mb={1} style={{ color: '#73ffa6' }}>
                    <strong>Report ID:</strong> {report.id}
                  </Box>
                  <Divider
                    style={{ borderColor: '#1d2a2a', margin: '8px 0' }}
                  />
                  <Box
                    style={{
                      fontFamily: 'Consolas, monospace',
                      fontSize: '14px',
                      lineHeight: '1.4',
                      whiteSpace: 'pre-wrap',
                    }}
                  >
                    {report.body}
                  </Box>
                </Box>
              </Collapsible>
            ))
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const EventsTab = (props: { recent_events: EventLogEntry[] }) => {
  const { recent_events } = props;

  // Ensure we have a valid array to work with
  const eventsList = recent_events || [];

  const formatTime = (time: number) => {
    const date = new Date(time);
    return date.toLocaleTimeString();
  };

  return (
    <Section title="Recent Research Events" fill scrollable>
      {eventsList.length === 0 ? (
        <NoticeBox info>No recent events recorded.</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Time</Table.Cell>
            <Table.Cell>SCP</Table.Cell>
            <Table.Cell>Event</Table.Cell>
            <Table.Cell>Researcher</Table.Cell>
            <Table.Cell>Details</Table.Cell>
          </Table.Row>
          {eventsList.map((event, index) => (
            <Table.Row key={index}>
              <Table.Cell>{formatTime(event.time)}</Table.Cell>
              <Table.Cell>
                <Box bold>SCP-{event.designation}</Box>
              </Table.Cell>
              <Table.Cell>
                <Box color="green">{event.event}</Box>
              </Table.Cell>
              <Table.Cell>{event.name}</Table.Cell>
              <Table.Cell>{event.details}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
