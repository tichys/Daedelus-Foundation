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
  NoticeBox,
} from '../components';
import { Window } from '../layouts';

export const SCPProgression = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useLocalState('scpTab', 1);
  const [selectedSCP, setSelectedSCP] = useLocalState('selectedSCP', null);

  // Ensure data exists and has required properties
  const safeData = data || {};
  const hasData = safeData.has_data || false;

  if (!hasData) {
    return (
      <Window
        title="SCP Foundation - SCP Progression System"
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
            ╔══════════════════════════════════════════════════════════════╗
            ║                    SCP FOUNDATION                           ║
            ║                SCP PROGRESSION SYSTEM                       ║
            ║                                                             ║
            ║              NO SCP PROGRESSION DATA FOUND                  ║
            ║                                                             ║
            ║              PLEASE CONTACT AN ADMINISTRATOR                ║
            ╚══════════════════════════════════════════════════════════════╝
          </Box>
        </Window.Content>
      </Window>
    );
  }

  const {
    player_name = 'Unknown',
    player_key = 'Unknown',
    current_scp = 'None',
    scp_progression_data = {},
    global_scp_stats = {},
    available_scps = [],
    achievements = [],
    recent_events = [],
  } = safeData;

  // NavButton component matching personnel persistence style
  const NavButton = ({ children, isActive, onClick, icon }) => (
    <Button
      onClick={onClick}
      selected={isActive}
      style={{
        backgroundColor: isActive ? 'rgba(0,255,0,0.2)' : 'rgba(0,0,0,0.5)',
        border: isActive ? '1px solid #00ff00' : '1px solid rgba(255,255,255,0.3)',
        color: isActive ? '#00ff00' : '#ffffff',
        fontFamily: 'monospace',
        fontSize: '12px',
        fontWeight: 'bold',
        padding: '8px 12px',
        marginRight: '5px',
        borderRadius: '3px',
        transition: 'all 0.2s ease',
      }}
    >
      <Box style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
        <span>{icon}</span>
        <span>{children}</span>
      </Box>
    </Button>
  );

  // EnhancedButton component matching personnel persistence style
  const EnhancedButton = ({ children, onClick, color = 'default', icon, tooltip }) => {
    const colorMap = {
      good: '#00ff00',
      average: '#ffff00',
      bad: '#ff0000',
      blue: '#0088ff',
      purple: '#8800ff',
      default: '#ffffff',
    };

    return (
      <Button
        onClick={onClick}
        style={{
          backgroundColor: 'rgba(0,0,0,0.5)',
          border: `1px solid ${colorMap[color]}`,
          color: colorMap[color],
          fontFamily: 'monospace',
          fontSize: '12px',
          fontWeight: 'bold',
          padding: '6px 10px',
          borderRadius: '3px',
          transition: 'all 0.2s ease',
        }}
        tooltip={tooltip}
      >
        <Box style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          {icon && <span>{icon}</span>}
          <span>{children}</span>
        </Box>
      </Button>
    );
  };

  // SCP Card component
  const SCPCard = ({ scpData, isSelected, onClick }) => (
    <Box
      onClick={onClick}
      style={{
        backgroundColor: isSelected ? 'rgba(0,255,0,0.1)' : 'rgba(0,0,0,0.5)',
        border: isSelected ? '2px solid #00ff00' : '1px solid rgba(255,255,255,0.3)',
        borderRadius: '5px',
        padding: '15px',
        margin: '5px',
        cursor: 'pointer',
        transition: 'all 0.2s ease',
        minWidth: '200px',
      }}
    >
      <Box style={{ fontSize: '16px', fontWeight: 'bold', color: '#00ff00', marginBottom: '5px' }}>
        SCP-{scpData.scp_id}
      </Box>
      <Box style={{ fontSize: '12px', opacity: 0.8, marginBottom: '10px' }}>
        {scpData.scp_name || 'Unknown SCP'}
      </Box>
      <Box style={{ fontSize: '11px', color: '#00ffff' }}>
        Rounds Played: {scpData.rounds_played || 0}
      </Box>
      <Box style={{ fontSize: '11px', color: '#00ffff' }}>
        Total Experience: {scpData.total_experience || 0}
      </Box>
      <Box style={{ fontSize: '11px', color: '#ffff00' }}>
        Achievements: {scpData.achievements?.length || 0}
      </Box>
    </Box>
  );

  return (
    <Window
      title="SCP Foundation - SCP Progression System"
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
            SCP PROGRESSION SYSTEM
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            ANOMALOUS ENTITY PERFORMANCE & ACHIEVEMENT TRACKING
          </Box>
          <Box style={{ fontSize: '12px', opacity: 0.6, marginTop: '5px' }}>
            Player: {player_name} | Key: {player_key} | Current SCP: {current_scp}
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
          <NavButton isActive={tab === 2} onClick={() => setTab(2)} icon="👹">
            SCP PROGRESSION
          </NavButton>
          <NavButton isActive={tab === 3} onClick={() => setTab(3)} icon="🏆">
            ACHIEVEMENTS
          </NavButton>
          <NavButton isActive={tab === 4} onClick={() => setTab(4)} icon="📈">
            RECENT EVENTS
          </NavButton>
          <NavButton isActive={tab === 5} onClick={() => setTab(5)} icon="🌐">
            GLOBAL STATS
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
              SCP progression system overview - all anomalous entities operational.
            </Box>

            <Section title="Quick Actions">
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                <EnhancedButton
                  icon="📊"
                  color="good"
                  onClick={() => act('export_scp_data')}
                  tooltip="Export SCP progression data"
                >
                  Export Data
                </EnhancedButton>
                <EnhancedButton
                  icon="🔄"
                  color="blue"
                  onClick={() => act('refresh_scp_data')}
                  tooltip="Refresh SCP progression data"
                >
                  Refresh Data
                </EnhancedButton>
                <EnhancedButton
                  icon="💾"
                  color="purple"
                  onClick={() => act('save_scp_data')}
                  tooltip="Save SCP progression data"
                >
                  Save Data
                </EnhancedButton>
                <EnhancedButton
                  icon="📂"
                  color="average"
                  onClick={() => act('load_scp_data')}
                  tooltip="Load SCP progression data"
                >
                  Load Data
                </EnhancedButton>
              </Flex>
            </Section>

            <Section title="Current SCP Status">
              <Grid>
                <Grid.Column size={6}>
                  <LabeledList>
                    <LabeledList.Item label="Current SCP">
                      <Box style={{ color: '#00ff00', fontWeight: 'bold' }}>
                        {current_scp !== 'None' ? `SCP-${current_scp}` : 'Not Playing as SCP'}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Total SCPs Played">
                      <Box style={{ color: '#00ffff' }}>
                        {Object.keys(scp_progression_data).length}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Total SCP Experience">
                      <Box style={{ color: '#ffff00' }}>
                        {Object.values(scp_progression_data).reduce((sum, scp) => sum + (scp.total_experience || 0), 0)}
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
                <Grid.Column size={6}>
                  <LabeledList>
                    <LabeledList.Item label="Total Achievements">
                      <Box style={{ color: '#ff8800' }}>
                        {achievements.length}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Recent Events">
                      <Box style={{ color: '#ff0088' }}>
                        {recent_events.length}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="System Status">
                      <Box style={{ color: '#00ff00' }}>
                        OPERATIONAL
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* SCP Progression Tab */}
        {tab === 2 && (
          <Box>
            <Section title="Available SCPs">
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                {available_scps.map((scp) => (
                  <SCPCard
                    key={scp.scp_id}
                    scpData={scp}
                    isSelected={selectedSCP === scp.scp_id}
                    onClick={() => setSelectedSCP(scp.scp_id)}
                  />
                ))}
              </Flex>
            </Section>

            {selectedSCP && scp_progression_data[selectedSCP] && (
              <Section title={`SCP-${selectedSCP} Progression Details`}>
                <Grid>
                  <Grid.Column size={6}>
                    <LabeledList>
                      <LabeledList.Item label="SCP ID">
                        <Box style={{ color: '#00ff00', fontWeight: 'bold' }}>
                          SCP-{selectedSCP}
                        </Box>
                      </LabeledList.Item>
                      <LabeledList.Item label="Rounds Played">
                        <Box style={{ color: '#00ffff' }}>
                          {scp_progression_data[selectedSCP].rounds_played || 0}
                        </Box>
                      </LabeledList.Item>
                      <LabeledList.Item label="Total Experience">
                        <Box style={{ color: '#ffff00' }}>
                          {scp_progression_data[selectedSCP].total_experience || 0}
                        </Box>
                      </LabeledList.Item>
                    </LabeledList>
                  </Grid.Column>
                  <Grid.Column size={6}>
                    <LabeledList>
                      <LabeledList.Item label="Achievements Unlocked">
                        <Box style={{ color: '#ff8800' }}>
                          {scp_progression_data[selectedSCP].achievements?.length || 0}
                        </Box>
                      </LabeledList.Item>
                      <LabeledList.Item label="Last Update">
                        <Box style={{ color: '#ff0088' }}>
                          {scp_progression_data[selectedSCP].last_update ?
                            new Date(scp_progression_data[selectedSCP].last_update * 1000).toLocaleString() :
                            'Never'
                          }
                        </Box>
                      </LabeledList.Item>
                    </LabeledList>
                  </Grid.Column>
                </Grid>

                {/* SCP-specific metrics */}
                <Section title="SCP-Specific Metrics" level={2}>
                  <Grid>
                    {Object.entries(scp_progression_data[selectedSCP].metrics || {}).map(([metric, value]) => (
                      <Grid.Column key={metric} size={4}>
                        <Box
                          style={{
                            backgroundColor: 'rgba(0,0,0,0.3)',
                            border: '1px solid rgba(255,255,255,0.2)',
                            borderRadius: '3px',
                            padding: '10px',
                            margin: '5px',
                          }}
                        >
                          <Box style={{ fontSize: '12px', color: '#00ff00', fontWeight: 'bold' }}>
                            {metric.replace(/_/g, ' ').toUpperCase()}
                          </Box>
                          <Box style={{ fontSize: '16px', color: '#00ffff' }}>
                            {value}
                          </Box>
                        </Box>
                      </Grid.Column>
                    ))}
                  </Grid>
                </Section>
              </Section>
            )}
          </Box>
        )}

        {/* Achievements Tab */}
        {tab === 3 && (
          <Box>
            <Section title="SCP Achievements">
              <Grid>
                {achievements.map((achievement, index) => (
                  <Grid.Column key={index} size={6}>
                    <Box
                      style={{
                        backgroundColor: achievement.unlocked ? 'rgba(0,255,0,0.1)' : 'rgba(0,0,0,0.3)',
                        border: achievement.unlocked ? '2px solid #00ff00' : '1px solid rgba(255,255,255,0.2)',
                        borderRadius: '5px',
                        padding: '15px',
                        margin: '5px',
                      }}
                    >
                      <Box style={{
                        fontSize: '14px',
                        fontWeight: 'bold',
                        color: achievement.unlocked ? '#00ff00' : '#888888',
                        marginBottom: '5px'
                      }}>
                        {achievement.name}
                      </Box>
                      <Box style={{
                        fontSize: '12px',
                        color: achievement.unlocked ? '#ffffff' : '#666666',
                        marginBottom: '5px'
                      }}>
                        {achievement.description}
                      </Box>
                      <Box style={{
                        fontSize: '10px',
                        color: achievement.unlocked ? '#00ffff' : '#444444'
                      }}>
                        Status: {achievement.unlocked ? 'UNLOCKED' : 'LOCKED'}
                      </Box>
                    </Box>
                  </Grid.Column>
                ))}
              </Grid>
            </Section>
          </Box>
        )}

        {/* Recent Events Tab */}
        {tab === 4 && (
          <Box>
            <Section title="Recent SCP Events">
              <Table>
                <Table.Row header>
                  <Table.Cell>Timestamp</Table.Cell>
                  <Table.Cell>SCP</Table.Cell>
                  <Table.Cell>Event Type</Table.Cell>
                  <Table.Cell>Details</Table.Cell>
                  <Table.Cell>Experience</Table.Cell>
                </Table.Row>
                {recent_events.map((event, index) => (
                  <Table.Row key={index}>
                    <Table.Cell>
                      {new Date(event.timestamp * 1000).toLocaleString()}
                    </Table.Cell>
                    <Table.Cell style={{ color: '#00ff00' }}>
                      SCP-{event.scp_id}
                    </Table.Cell>
                    <Table.Cell style={{ color: '#00ffff' }}>
                      {event.event_type}
                    </Table.Cell>
                    <Table.Cell style={{ color: '#ffffff' }}>
                      {event.details}
                    </Table.Cell>
                    <Table.Cell style={{ color: '#ffff00' }}>
                      +{event.experience} XP
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Box>
        )}

        {/* Global Stats Tab */}
        {tab === 5 && (
          <Box>
            <Section title="Global SCP Statistics">
              <Grid>
                <Grid.Column size={6}>
                  <LabeledList>
                    <LabeledList.Item label="Total SCP Rounds">
                      <Box style={{ color: '#00ff00' }}>
                        {global_scp_stats.total_scp_rounds_played || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Total Achievements">
                      <Box style={{ color: '#00ffff' }}>
                        {global_scp_stats.total_scp_achievements_unlocked || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Average Performance">
                      <Box style={{ color: '#ffff00' }}>
                        {global_scp_stats.average_scp_performance || 0}
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
                <Grid.Column size={6}>
                  <LabeledList>
                    <LabeledList.Item label="Research Points">
                      <Box style={{ color: '#ff8800' }}>
                        {global_scp_stats.total_scp_research_points || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Containment Breaches">
                      <Box style={{ color: '#ff0088' }}>
                        {global_scp_stats.scp_containment_breaches || 0}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Research Breakthroughs">
                      <Box style={{ color: '#8800ff' }}>
                        {global_scp_stats.scp_research_breakthroughs || 0}
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        <Box
          style={{
            fontSize: '10px',
            opacity: 0.5,
            textAlign: 'center',
            marginTop: '20px',
            borderTop: '1px solid rgba(255,255,255,0.1)',
            paddingTop: '10px',
          }}
        >
          SCP Foundation - Anomalous Entity Progression System v1.0
        </Box>
      </Window.Content>
    </Window>
  );
};
