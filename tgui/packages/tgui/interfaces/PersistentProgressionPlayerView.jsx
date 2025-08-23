import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Box,
  Stack,
  ProgressBar,
  Grid,
  Table,
} from '../components';
import { Window } from '../layouts';

export const PersistentProgressionPlayerView = (props, context) => {
  const { act, data } = useBackend(context);

  if (!data.has_data) {
    return (
      <Window
        title="SCP Foundation - Player Progress Viewer"
        width={1000}
        height={700}
        theme="scp_terminal"
      >
        <Window.Content
          style={{
            background: 'rgba(0,0,0,0.7)',
            fontFamily: 'monospace',
            fontSize: '14px',
            color: '#ffffff',
            padding: '20px',
          }}
        >
          <Box
            style={{
              textAlign: 'center',
              fontSize: '18px',
              color: '#ff4444',
              marginTop: '100px',
            }}
          >
            ╔══════════════════════════════════════════════════════════════╗ ║
            SCP FOUNDATION ║ ║ PLAYER PROGRESS VIEWER ║ ║ ║ ║ NO PERSISTENT DATA
            FOUND ║ ║ ║ ║ FOR THIS PLAYER ║
            ╚══════════════════════════════════════════════════════════════╝
          </Box>
        </Window.Content>
      </Window>
    );
  }

  const {
    ckey,
    current_class,
    current_faction,
    current_rank,
    current_rank_level,
    total_experience,
    rounds_played,
    last_login,
    progress_to_next,
    exp_needed,
    unlocked_items,
    unlocked_titles,
    achievements,
    recent_experience,
  } = data;

  return (
    <Window
      title={`SCP Foundation - Player Progress Viewer - ${ckey}`}
      width={1000}
      height={700}
      theme="scp_terminal"
    >
      <Window.Content
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            PLAYER PROGRESS VIEWER
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            ADMINISTRATIVE PERSONNEL MONITORING
          </Box>
        </Box>

        <Section title="Target Personnel Identification">
          <Grid style={{ gap: '20px' }}>
            <Grid.Column size={6}>
              <LabeledList>
                <LabeledList.Item label="IDENTIFICATION KEY">
                  <Box style={{ color: '#ffff66' }}>{ckey}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="CURRENT CLASS">
                  <Box style={{ color: '#66ffff' }}>{current_class}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="CURRENT RANK">
                  <Box style={{ color: '#66ff66' }}>
                    {current_rank} (Level {current_rank_level})
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </Grid.Column>
            <Grid.Column size={6}>
              <LabeledList>
                <LabeledList.Item label="CURRENT FACTION">
                  <Box style={{ color: '#66ffff' }}>{current_faction}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="TOTAL EXPERIENCE">
                  <Box style={{ color: '#ffff66' }}>
                    {total_experience.toLocaleString()} XP
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="ROUNDS PLAYED">
                  <Box style={{ color: '#66ff66' }}>{rounds_played}</Box>
                </LabeledList.Item>
              </LabeledList>
            </Grid.Column>
          </Grid>
        </Section>

        <Section title="Progression Status">
          <Box style={{ marginBottom: '15px' }}>
            <Box style={{ marginBottom: '5px' }}>
              PROGRESS TO NEXT RANK: {progress_to_next}% ({exp_needed} XP
              needed)
            </Box>
            <ProgressBar
              value={progress_to_next}
              maxValue={100}
              color={progress_to_next >= 100 ? '#66ff66' : '#ffff66'}
            />
          </Box>
        </Section>

        <Section title="Unlocked Content">
          <Grid style={{ gap: '20px' }}>
            <Grid.Column size={6}>
              <Box style={{ marginBottom: '15px' }}>
                <Box
                  style={{
                    fontWeight: 'bold',
                    marginBottom: '10px',
                    color: '#66ff66',
                  }}
                >
                  UNLOCKED ITEMS ({unlocked_items.length})
                </Box>
                {unlocked_items && unlocked_items.length > 0 ? (
                  unlocked_items.map((item, index) => (
                    <Box
                      key={index}
                      style={{ fontSize: '12px', marginBottom: '5px' }}
                    >
                      • {item}
                    </Box>
                  ))
                ) : (
                  <Box style={{ fontSize: '12px', opacity: 0.6 }}>
                    NO ITEMS UNLOCKED
                  </Box>
                )}
              </Box>
            </Grid.Column>
            <Grid.Column size={6}>
              <Box style={{ marginBottom: '15px' }}>
                <Box
                  style={{
                    fontWeight: 'bold',
                    marginBottom: '10px',
                    color: '#66ff66',
                  }}
                >
                  UNLOCKED TITLES ({unlocked_titles.length})
                </Box>
                {unlocked_titles && unlocked_titles.length > 0 ? (
                  unlocked_titles.map((title, index) => (
                    <Box
                      key={index}
                      style={{ fontSize: '12px', marginBottom: '5px' }}
                    >
                      • {title}
                    </Box>
                  ))
                ) : (
                  <Box style={{ fontSize: '12px', opacity: 0.6 }}>
                    NO TITLES UNLOCKED
                  </Box>
                )}
              </Box>
            </Grid.Column>
          </Grid>
        </Section>

        <Section title="Recent Experience Activity">
          {recent_experience && recent_experience.length > 0 ? (
            <Table>
              <Table.Row header>
                <Table.Cell>Experience</Table.Cell>
                <Table.Cell>Reason</Table.Cell>
                <Table.Cell>Timestamp</Table.Cell>
                <Table.Cell>Actions</Table.Cell>
              </Table.Row>
              {recent_experience.map((exp, index) => (
                <Table.Row key={index}>
                  <Table.Cell>
                    <Box style={{ fontWeight: 'bold', color: '#ffff66' }}>
                      +{exp.amount} XP
                    </Box>
                  </Table.Cell>
                  <Table.Cell>{exp.reason}</Table.Cell>
                  <Table.Cell>{exp.timestamp}</Table.Cell>
                  <Table.Cell>
                    <Button size="small">Details</Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          ) : (
            <Box style={{ textAlign: 'center', padding: '20px', opacity: 0.6 }}>
              NO RECENT ACTIVITY
            </Box>
          )}
        </Section>

        <Section title="Administrative Actions">
          <Stack style={{ gap: '10px' }}>
            <Stack.Item>
              <Button
                content="EXPORT DATA"
                onClick={() => act('export_data')}
                style={{
                  backgroundColor: 'rgba(0,100,255,0.3)',
                  border: '1px solid rgba(255,255,255,0.3)',
                  color: '#ffffff',
                  fontFamily: 'monospace',
                  fontSize: '12px',
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                content="RESET PROGRESS"
                onClick={() => act('reset_progress')}
                style={{
                  backgroundColor: 'rgba(255,0,0,0.3)',
                  border: '1px solid rgba(255,255,255,0.3)',
                  color: '#ffffff',
                  fontFamily: 'monospace',
                  fontSize: '12px',
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                content="CLOSE VIEWER"
                onClick={() => act('close_viewer')}
                style={{
                  backgroundColor: 'rgba(100,100,100,0.3)',
                  border: '1px solid rgba(255,255,255,0.3)',
                  color: '#ffffff',
                  fontFamily: 'monospace',
                  fontSize: '12px',
                }}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
