import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  Flex,
  Grid,
  Table,
} from '../components';
import { Window } from '../layouts';

export const PersistentProgression = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useLocalState('tab', 1);
  const [viewMode, setViewMode] = useLocalState('viewMode', 'current');

  // Ensure data exists and has required properties
  const safeData = data || {};
  const hasData = safeData.has_data || false;

  if (!hasData) {
    return (
      <Window
        title="SCP Foundation - Persistent Progression System"
        width={1200}
        height={800}
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
            SCP FOUNDATION ║ ║ PERSISTENT PROGRESSION SYSTEM ║ ║ ║ ║ NO
            PERSISTENT DATA FOUND ║ ║ ║ ║ PLEASE CONTACT AN ADMINISTRATOR ║
            ╚══════════════════════════════════════════════════════════════╝
          </Box>
        </Window.Content>
      </Window>
    );
  }

  const {
    player_name = 'Unknown',
    player_key = 'Unknown',
    current_class = 'Unknown',
    current_faction = 'Unknown',
    current_rank = 'Unknown',
    current_rank_level = 0,
    total_experience = 0,
    rounds_played = 0,
    progress_to_next = 0,
    exp_needed = 0,
    total_rounds_survived = 0,
    total_rounds_died = 0,
    survival_rate = 0,
    average_exp_per_round = 0,
    class_description = 'No description available',
    class_exp_multiplier = 1.0,
    class_max_rank = 0,
    ranks = [],
    faction_description = 'No description available',
    faction_exp_multiplier = 1.0,
    available_classes = [],
    available_factions = [],
    all_classes = [],
    all_factions = [],
    unlocked_items = [],
    unlocked_titles = [],
    achievements = [],
    recent_experience = [],
  } = safeData;

  return (
    <Window
      title="SCP Foundation - Persistent Progression System"
      width={1200}
      height={800}
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
            PERSISTENT PROGRESSION
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            PERSONNEL DEVELOPMENT & ACHIEVEMENT TRACKING
          </Box>
        </Box>

        {/* Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
            gap: '5px',
          }}
        >
          <NavButton isActive={tab === 1} onClick={() => setTab(1)} icon="📊">
            OVERVIEW
          </NavButton>
          <NavButton isActive={tab === 2} onClick={() => setTab(2)} icon="🏆">
            ACHIEVEMENTS
          </NavButton>
          <NavButton isActive={tab === 3} onClick={() => setTab(3)} icon="📦">
            UNLOCKED CONTENT
          </NavButton>
          <NavButton isActive={tab === 4} onClick={() => setTab(4)} icon="📈">
            RECENT ACTIVITY
          </NavButton>
          <NavButton isActive={tab === 5} onClick={() => setTab(5)} icon="👥">
            CLASS MANAGEMENT
          </NavButton>
          <NavButton isActive={tab === 6} onClick={() => setTab(6)} icon="👹">
            SCP PROGRESSION
          </NavButton>
        </Flex>

        {/* Overview Tab */}
        {tab === 1 && (
          <Box>
            <Box
              style={{
                fontSize: '12px',
                opacity: 0.7,
                textAlign: 'center',
                marginTop: '20px',
              }}
            >
              Persistent progression system overview - all systems operational.
            </Box>

            <Section title="Quick Actions">
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                <EnhancedButton
                  icon="📊"
                  color="good"
                  onClick={() => act('export_data')}
                  tooltip="Export progression data"
                >
                  Export Data
                </EnhancedButton>
                <EnhancedButton
                  icon="🔄"
                  color="blue"
                  onClick={() => act('reset_progress')}
                  tooltip="Reset progression data"
                >
                  Reset Progress
                </EnhancedButton>
                <EnhancedButton
                  icon="💾"
                  color="purple"
                  onClick={() => act('save_data')}
                  tooltip="Save progression data"
                >
                  Save Data
                </EnhancedButton>
                <EnhancedButton
                  icon="📂"
                  color="average"
                  onClick={() => act('load_data')}
                  tooltip="Load progression data"
                >
                  Load Data
                </EnhancedButton>
              </Flex>
            </Section>

            <Section title="Player Information">
              <Grid style={{ gap: '20px' }}>
                <Grid.Column size={6}>
                  <LabeledList>
                    <LabeledList.Item label="NAME">
                      <Box style={{ color: '#66ff66' }}>{player_name}</Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="IDENTIFICATION KEY">
                      <Box style={{ color: '#ffff66' }}>{player_key}</Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="CURRENT CLASS">
                      <Box style={{ color: '#66ffff' }}>{current_class}</Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
                <Grid.Column size={6}>
                  <LabeledList>
                    <LabeledList.Item label="CURRENT FACTION">
                      <Box style={{ color: '#66ffff' }}>{current_faction}</Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="CURRENT RANK">
                      <Box style={{ color: '#66ff66' }}>
                        {current_rank} (Level {current_rank_level})
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="TOTAL EXPERIENCE">
                      <Box style={{ color: '#ffff66' }}>
                        {total_experience.toLocaleString()} XP
                      </Box>
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
              <Grid style={{ gap: '20px' }}>
                <Grid.Column size={4}>
                  <Box style={{ textAlign: 'center' }}>
                    <Box style={{ fontSize: '16px', color: '#66ff66' }}>
                      {rounds_played}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      ROUNDS PLAYED
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={4}>
                  <Box style={{ textAlign: 'center' }}>
                    <Box style={{ fontSize: '16px', color: '#ffff66' }}>
                      {survival_rate}%
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      SURVIVAL RATE
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={4}>
                  <Box style={{ textAlign: 'center' }}>
                    <Box style={{ fontSize: '16px', color: '#66ffff' }}>
                      {average_exp_per_round}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      AVG XP/ROUND
                    </Box>
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* Achievements Tab */}
        {tab === 2 && (
          <Box>
            <Section title="Achievements & Milestones">
              {achievements && achievements.length > 0 ? (
                <Table>
                  <Table.Row header>
                    <Table.Cell>Achievement</Table.Cell>
                    <Table.Cell>Description</Table.Cell>
                    <Table.Cell>Date Unlocked</Table.Cell>
                    <Table.Cell>Actions</Table.Cell>
                  </Table.Row>
                  {achievements.map((achievement, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>
                        <Box style={{ fontWeight: 'bold', color: '#66ff66' }}>
                          {achievement.name}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>{achievement.description}</Table.Cell>
                      <Table.Cell>{achievement.date}</Table.Cell>
                      <Table.Cell>
                        <Button size="small">View</Button>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              ) : (
                <Box
                  style={{ textAlign: 'center', padding: '20px', opacity: 0.6 }}
                >
                  NO ACHIEVEMENTS UNLOCKED YET
                </Box>
              )}
            </Section>
          </Box>
        )}

        {/* Unlocked Content Tab */}
        {tab === 3 && (
          <Box>
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
          </Box>
        )}

        {/* Recent Activity Tab */}
        {tab === 4 && (
          <Box>
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
                <Box
                  style={{ textAlign: 'center', padding: '20px', opacity: 0.6 }}
                >
                  NO RECENT ACTIVITY
                </Box>
              )}
            </Section>
          </Box>
        )}

        {/* Class Management Tab */}
        {tab === 5 && (
          <Box>
            <Section title="Class & Faction Management">
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
                      CURRENT CLASS: {current_class}
                    </Box>
                    <Box style={{ fontSize: '12px', marginBottom: '10px' }}>
                      {class_description}
                    </Box>
                    <Box style={{ fontSize: '12px', color: '#ffff66' }}>
                      EXP MULTIPLIER: {class_exp_multiplier}x
                    </Box>
                    <Box style={{ fontSize: '12px', color: '#66ffff' }}>
                      MAX RANK: {class_max_rank}
                    </Box>
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
                      CURRENT FACTION: {current_faction}
                    </Box>
                    <Box style={{ fontSize: '12px', marginBottom: '10px' }}>
                      {faction_description}
                    </Box>
                    <Box style={{ fontSize: '12px', color: '#ffff66' }}>
                      EXP MULTIPLIER: {faction_exp_multiplier}x
                    </Box>
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* SCP Progression Tab */}
        {tab === 6 && (
          <Box>
            <Box
              style={{
                fontSize: '12px',
                opacity: 0.7,
                textAlign: 'center',
                marginTop: '20px',
              }}
            >
              SCP progression tracking system - monitoring anomalous entity performance.
            </Box>

            <Section title="SCP Progression Overview">
              <Grid style={{ gap: '20px' }}>
                <Grid.Column size={6}>
                  <LabeledList>
                    <LabeledList.Item label="CURRENT SCP">
                      <Box style={{ color: '#66ff66' }}>
                        {safeData.current_scp || 'None'}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="SCP EXPERIENCE">
                      <Box style={{ color: '#ffff66' }}>
                        {safeData.scp_total_experience || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="SCP ROUNDS PLAYED">
                      <Box style={{ color: '#66ffff' }}>
                        {safeData.scp_rounds_played || 0}
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
                <Grid.Column size={6}>
                  <LabeledList>
                    <LabeledList.Item label="SCP ACHIEVEMENTS">
                      <Box style={{ color: '#ff66ff' }}>
                        {safeData.scp_achievements_unlocked || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="TOTAL SCP PERFORMANCE">
                      <Box style={{ color: '#ff9966' }}>
                        {safeData.scp_performance_score || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="SCP RANK">
                      <Box style={{ color: '#66ff99' }}>
                        {safeData.scp_rank || 'Novice'}
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
              </Grid>
            </Section>

            <Section title="SCP-Specific Metrics">
              <Grid style={{ gap: '15px' }}>
                {safeData.scp_metrics && Object.keys(safeData.scp_metrics).length > 0 ? (
                  Object.entries(safeData.scp_metrics).map(([scp_id, metrics]) => (
                    <Grid.Column size={4} key={scp_id}>
                      <Box
                        style={{
                          border: '1px solid rgba(255,255,255,0.3)',
                          padding: '15px',
                          borderRadius: '5px',
                          background: 'rgba(0,0,0,0.3)',
                        }}
                      >
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            marginBottom: '10px',
                            color: '#66ff66',
                          }}
                        >
                          SCP-{scp_id}
                        </Box>
                        <LabeledList>
                          {Object.entries(metrics).map(([metric, value]) => (
                            <LabeledList.Item key={metric} label={metric.toUpperCase()}>
                              <Box style={{ color: '#ffff66' }}>{value}</Box>
                            </LabeledList.Item>
                          ))}
                        </LabeledList>
                      </Box>
                    </Grid.Column>
                  ))
                ) : (
                  <Grid.Column size={12}>
                    <Box
                      style={{
                        textAlign: 'center',
                        padding: '20px',
                        color: '#ff6666',
                        fontSize: '14px',
                      }}
                    >
                      No SCP progression data available.
                      <br />
                      Play as an SCP to start tracking your progression.
                    </Box>
                  </Grid.Column>
                )}
              </Grid>
            </Section>

            <Section title="SCP Achievements">
              <Grid style={{ gap: '10px' }}>
                {safeData.scp_achievements && safeData.scp_achievements.length > 0 ? (
                  safeData.scp_achievements.map((achievement, index) => (
                    <Grid.Column size={6} key={index}>
                      <Box
                        style={{
                          border: '1px solid rgba(255,255,255,0.3)',
                          padding: '10px',
                          borderRadius: '3px',
                          background: achievement.unlocked 
                            ? 'rgba(0,255,0,0.1)' 
                            : 'rgba(100,100,100,0.1)',
                        }}
                      >
                        <Box
                          style={{
                            fontSize: '14px',
                            fontWeight: 'bold',
                            color: achievement.unlocked ? '#66ff66' : '#666666',
                          }}
                        >
                          {achievement.name}
                        </Box>
                        <Box
                          style={{
                            fontSize: '12px',
                            color: achievement.unlocked ? '#ffffff' : '#888888',
                          }}
                        >
                          {achievement.description}
                        </Box>
                        <Box
                          style={{
                            fontSize: '10px',
                            color: achievement.unlocked ? '#66ff66' : '#666666',
                            marginTop: '5px',
                          }}
                        >
                          Status: {achievement.unlocked ? 'UNLOCKED' : 'LOCKED'}
                        </Box>
                      </Box>
                    </Grid.Column>
                  ))
                ) : (
                  <Grid.Column size={12}>
                    <Box
                      style={{
                        textAlign: 'center',
                        padding: '20px',
                        color: '#ff6666',
                        fontSize: '14px',
                      }}
                    >
                      No SCP achievements available.
                    </Box>
                  </Grid.Column>
                )}
              </Grid>
            </Section>

            <Section title="SCP Performance Statistics">
              <Grid style={{ gap: '20px' }}>
                <Grid.Column size={6}>
                  <LabeledList>
                    <LabeledList.Item label="TOTAL SCP ROUNDS">
                      <Box style={{ color: '#66ff66' }}>
                        {safeData.total_scp_rounds || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="AVERAGE SCP PERFORMANCE">
                      <Box style={{ color: '#ffff66' }}>
                        {safeData.average_scp_performance || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="SCP CONTAINMENT BREACHES">
                      <Box style={{ color: '#ff6666' }}>
                        {safeData.scp_containment_breaches || 0}
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
                <Grid.Column size={6}>
                  <LabeledList>
                    <LabeledList.Item label="SCP RESEARCH POINTS">
                      <Box style={{ color: '#66ffff' }}>
                        {safeData.scp_research_points || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="SCP RESEARCH BREAKTHROUGHS">
                      <Box style={{ color: '#ff66ff' }}>
                        {safeData.scp_research_breakthroughs || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="SCP INTERACTION EVENTS">
                      <Box style={{ color: '#ff9966' }}>
                        {safeData.scp_interaction_events || 0}
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};

// NavButton component matching personnel persistence style
const NavButton = ({ children, isActive, onClick, icon }) => (
  <Box
    style={{
      padding: '8px 16px',
      background: isActive ? 'rgba(255,255,255,0.2)' : 'transparent',
      border: '1px solid rgba(255,255,255,0.3)',
      borderRadius: '3px',
      cursor: 'pointer',
      fontSize: '12px',
      fontWeight: isActive ? 'bold' : 'normal',
      transition: 'all 0.3s ease',
    }}
    onClick={onClick}
    onMouseEnter={(e) => {
      if (!isActive) {
        e.target.style.background = 'rgba(255,255,255,0.1)';
      }
    }}
    onMouseLeave={(e) => {
      if (!isActive) {
        e.target.style.background = 'transparent';
      }
    }}
  >
    {icon} {children}
  </Box>
);

// EnhancedButton component matching personnel persistence style
const EnhancedButton = ({ children, icon, color, onClick, tooltip }) => {
  const getColorStyle = (color) => {
    switch (color) {
      case 'good':
        return { backgroundColor: 'rgba(0,255,0,0.2)', borderColor: '#66ff66' };
      case 'bad':
        return { backgroundColor: 'rgba(255,0,0,0.2)', borderColor: '#ff6666' };
      case 'average':
        return {
          backgroundColor: 'rgba(255,255,0,0.2)',
          borderColor: '#ffff66',
        };
      case 'blue':
        return {
          backgroundColor: 'rgba(0,100,255,0.2)',
          borderColor: '#6666ff',
        };
      case 'purple':
        return {
          backgroundColor: 'rgba(255,0,255,0.2)',
          borderColor: '#ff66ff',
        };
      default:
        return {
          backgroundColor: 'rgba(100,100,100,0.2)',
          borderColor: '#cccccc',
        };
    }
  };

  const colorStyle = getColorStyle(color);

  return (
    <Button
      onClick={onClick}
      style={{
        ...colorStyle,
        border: `1px solid ${colorStyle.borderColor}`,
        color: '#ffffff',
        fontFamily: 'monospace',
        fontSize: '12px',
        padding: '8px 16px',
        transition: 'all 0.3s ease',
      }}
      title={tooltip}
    >
      {icon} {children}
    </Button>
  );
};
