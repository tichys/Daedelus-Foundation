import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Table, Tabs, ProgressBar, LabeledList, NoticeBox, Icon } from '../components';
import { Window } from '../layouts';

export const SkillProgression = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = useLocalState(context, 'activeTab', 'overview');

  const {
    has_data,
    player_name,
    player_key,
    current_class,
    current_faction,
    current_rank,
    current_rank_level,
    total_experience,
    rounds_played,
    progress_to_next,
    exp_needed,
    skill_summary,
    skill_milestones,
    performance_metrics,
    skill_boosts,
  } = data;

  if (!has_data) {
    return (
      <Window width={800} height={600}>
        <Window.Content>
          <NoticeBox>
            No progression data available. Please ensure you have persistent progression enabled.
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={1000} height={700}>
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            selected={activeTab === 'overview'}
            onClick={() => setActiveTab('overview')}>
            Overview
          </Tabs.Tab>
          <Tabs.Tab
            selected={activeTab === 'skills'}
            onClick={() => setActiveTab('skills')}>
            Skills
          </Tabs.Tab>
          <Tabs.Tab
            selected={activeTab === 'progression'}
            onClick={() => setActiveTab('progression')}>
            Progression
          </Tabs.Tab>
          <Tabs.Tab
            selected={activeTab === 'milestones'}
            onClick={() => setActiveTab('milestones')}>
            Milestones
          </Tabs.Tab>
          <Tabs.Tab
            selected={activeTab === 'analytics'}
            onClick={() => setActiveTab('analytics')}>
            Analytics
          </Tabs.Tab>
        </Tabs>

        {activeTab === 'overview' && (
          <SkillOverview
            player_name={player_name}
            current_class={current_class}
            current_faction={current_faction}
            current_rank={current_rank}
            current_rank_level={current_rank_level}
            total_experience={total_experience}
            rounds_played={rounds_played}
            progress_to_next={progress_to_next}
            exp_needed={exp_needed}
            skill_summary={skill_summary}
            performance_metrics={performance_metrics}
          />
        )}

        {activeTab === 'skills' && (
          <SkillDetails
            skill_summary={skill_summary}
            skill_boosts={skill_boosts}
            current_class={current_class}
            act={act}
          />
        )}

        {activeTab === 'progression' && (
          <ProgressionDetails
            current_class={current_class}
            current_rank={current_rank}
            current_rank_level={current_rank_level}
            total_experience={total_experience}
            progress_to_next={progress_to_next}
            exp_needed={exp_needed}
            skill_summary={skill_summary}
            act={act}
          />
        )}

        {activeTab === 'milestones' && (
          <MilestoneTracker
            skill_milestones={skill_milestones}
            skill_summary={skill_summary}
            act={act}
          />
        )}

        {activeTab === 'analytics' && (
          <SkillAnalytics
            skill_summary={skill_summary}
            performance_metrics={performance_metrics}
            rounds_played={rounds_played}
            act={act}
          />
        )}
      </Window.Content>
    </Window>
  );
};

const SkillOverview = (props, context) => {
  const {
    player_name,
    current_class,
    current_faction,
    current_rank,
    current_rank_level,
    total_experience,
    rounds_played,
    progress_to_next,
    exp_needed,
    skill_summary,
    performance_metrics,
  } = props;

  // Calculate skill statistics
  const total_skill_levels = performance_metrics?.total_skill_levels || 0;
  const highest_skill_level = performance_metrics?.highest_skill_level || 0;
  const skill_count = performance_metrics?.skill_count || 0;
  const average_skill_level = performance_metrics?.average_skill_level || 0;

  // Count skills by level
  const skill_counts = {
    novice: 0,
    apprentice: 0,
    journeyman: 0,
    expert: 0,
    master: 0,
    legendary: 0,
  };

  Object.values(skill_summary || {}).forEach(skill => {
    const level = skill.level;
    if (level >= 2) skill_counts.novice++;
    if (level >= 3) skill_counts.apprentice++;
    if (level >= 4) skill_counts.journeyman++;
    if (level >= 5) skill_counts.expert++;
    if (level >= 6) skill_counts.master++;
    if (level >= 7) skill_counts.legendary++;
  });

  return (
    <Box>
      <Section title="Player Information">
        <LabeledList>
          <LabeledList.Item label="Name">{player_name}</LabeledList.Item>
          <LabeledList.Item label="Class">{current_class}</LabeledList.Item>
          <LabeledList.Item label="Faction">{current_faction}</LabeledList.Item>
          <LabeledList.Item label="Rank">{current_rank} (Level {current_rank_level})</LabeledList.Item>
          <LabeledList.Item label="Total Experience">{total_experience.toLocaleString()}</LabeledList.Item>
          <LabeledList.Item label="Rounds Played">{rounds_played}</LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Rank Progress">
        <ProgressBar
          value={progress_to_next}
          maxValue={100}
          color={progress_to_next >= 100 ? 'good' : 'average'}>
          {progress_to_next}% to next rank
        </ProgressBar>
        {exp_needed > 0 && (
          <Box mt={1}>
            <NoticeBox info>
              {exp_needed.toLocaleString()} experience needed for next rank
            </NoticeBox>
          </Box>
        )}
      </Section>

      <Section title="Skill Statistics">
        <LabeledList>
          <LabeledList.Item label="Total Skill Levels">{total_skill_levels}</LabeledList.Item>
          <LabeledList.Item label="Highest Skill Level">{highest_skill_level}</LabeledList.Item>
          <LabeledList.Item label="Active Skills">{skill_count}</LabeledList.Item>
          <LabeledList.Item label="Average Skill Level">{average_skill_level.toFixed(1)}</LabeledList.Item>
        </LabeledList>

        <Box mt={2}>
          <h3>Skill Distribution</h3>
          <Table>
            <Table.Row header>
              <Table.Cell>Level</Table.Cell>
              <Table.Cell>Count</Table.Cell>
              <Table.Cell>Progress</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Novice</Table.Cell>
              <Table.Cell>{skill_counts.novice}</Table.Cell>
              <Table.Cell>
                <ProgressBar value={skill_counts.novice} maxValue={Object.keys(skill_summary || {}).length} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Apprentice</Table.Cell>
              <Table.Cell>{skill_counts.apprentice}</Table.Cell>
              <Table.Cell>
                <ProgressBar value={skill_counts.apprentice} maxValue={Object.keys(skill_summary || {}).length} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Journeyman</Table.Cell>
              <Table.Cell>{skill_counts.journeyman}</Table.Cell>
              <Table.Cell>
                <ProgressBar value={skill_counts.journeyman} maxValue={Object.keys(skill_summary || {}).length} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Expert</Table.Cell>
              <Table.Cell>{skill_counts.expert}</Table.Cell>
              <Table.Cell>
                <ProgressBar value={skill_counts.expert} maxValue={Object.keys(skill_summary || {}).length} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Master</Table.Cell>
              <Table.Cell>{skill_counts.master}</Table.Cell>
              <Table.Cell>
                <ProgressBar value={skill_counts.master} maxValue={Object.keys(skill_summary || {}).length} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Legendary</Table.Cell>
              <Table.Cell>{skill_counts.legendary}</Table.Cell>
              <Table.Cell>
                <ProgressBar value={skill_counts.legendary} maxValue={Object.keys(skill_summary || {}).length} />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Box>
      </Section>
    </Box>
  );
};

const SkillDetails = (props, context) => {
  const { skill_summary, skill_boosts, current_class, act } = props;

  const [skillFilter, setSkillFilter] = useLocalState(context, 'skillFilter', 'all');

  const skillCategories = {
    all: 'All Skills',
    security: 'Security',
    engineering: 'Engineering',
    medical: 'Medical',
    research: 'Research',
    service: 'Service',
    supply: 'Supply',
    administrative: 'Administrative',
    containment: 'Containment',
  };

  const filteredSkills = Object.entries(skill_summary || {}).filter(([skillType, skillData]) => {
    if (skillFilter === 'all') return true;
    return skillData.progression_class === skillFilter;
  });

  return (
    <Box>
      <Section title="Skill Details">
        <Box mb={2}>
          <Button
            selected={skillFilter === 'all'}
            onClick={() => setSkillFilter('all')}>
            All Skills
          </Button>
          {Object.entries(skillCategories).filter(([key]) => key !== 'all').map(([key, name]) => (
            <Button
              key={key}
              selected={skillFilter === key}
              onClick={() => setSkillFilter(key)}>
              {name}
            </Button>
          ))}
        </Box>

        <Table>
          <Table.Row header>
            <Table.Cell>Skill</Table.Cell>
            <Table.Cell>Level</Table.Cell>
            <Table.Cell>Experience</Table.Cell>
            <Table.Cell>Class</Table.Cell>
            <Table.Cell>Boost</Table.Cell>
            <Table.Cell>Progress</Table.Cell>
          </Table.Row>
          {filteredSkills.map(([skillType, skillData]) => (
            <Table.Row key={skillType}>
              <Table.Cell>
                <Box>
                  <strong>{skillType.split('/').pop()}</strong>
                  <Box textColor="gray" fontSize="0.8em">
                    {skillData.progression_class}
                  </Box>
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Box>
                  <strong>{skillData.level_name}</strong>
                  <Box textColor="gray" fontSize="0.8em">
                    Level {skillData.level}
                  </Box>
                </Box>
              </Table.Cell>
              <Table.Cell>{skillData.experience.toLocaleString()}</Table.Cell>
              <Table.Cell>
                <Box textColor={skillData.progression_class === current_class ? 'green' : 'gray'}>
                  {skillData.progression_class}
                </Box>
              </Table.Cell>
              <Table.Cell>
                {skillData.boost_multiplier > 1.0 ? (
                  <Box textColor="green">
                    +{((skillData.boost_multiplier - 1) * 100).toFixed(0)}%
                  </Box>
                ) : (
                  <Box textColor="gray">None</Box>
                )}
              </Table.Cell>
              <Table.Cell>
                <ProgressBar
                  value={skillData.experience}
                  maxValue={getSkillExpForLevel(skillData.level + 1)}
                  color={getSkillLevelColor(skillData.level)}>
                  {skillData.experience.toLocaleString()}
                </ProgressBar>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Box>
  );
};

const ProgressionDetails = (props, context) => {
  const {
    current_class,
    current_rank,
    current_rank_level,
    total_experience,
    progress_to_next,
    exp_needed,
    skill_summary,
    act,
  } = props;

  // Calculate skill-based rank requirements
  const skillRequirements = getSkillBasedRankRequirements();
  const currentRequirements = skillRequirements[current_rank_level + 1] || {};
  const playerStats = calculatePlayerSkillStats(skill_summary);

  return (
    <Box>
      <Section title="Current Status">
        <LabeledList>
          <LabeledList.Item label="Class">{current_class}</LabeledList.Item>
          <LabeledList.Item label="Current Rank">{current_rank} (Level {current_rank_level})</LabeledList.Item>
          <LabeledList.Item label="Total Experience">{total_experience.toLocaleString()}</LabeledList.Item>
          <LabeledList.Item label="Progress to Next Rank">{progress_to_next}%</LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Skill-Based Rank Requirements">
        <NoticeBox info>
          Your progression class provides skill experience boosts for relevant skills.
        </NoticeBox>

        <Box mt={2}>
          <h3>Next Rank Requirements (Rank {current_rank_level + 1})</h3>
          {Object.entries(currentRequirements).map(([requirement, value]) => (
            <Box key={requirement} mb={1}>
              <LabeledList>
                <LabeledList.Item label={formatRequirementName(requirement)}>
                  {playerStats[requirement] || 0} / {value}
                  <ProgressBar
                    value={playerStats[requirement] || 0}
                    maxValue={value}
                    color={(playerStats[requirement] || 0) >= value ? 'good' : 'average'}
                    mt={0.5}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Box>
          ))}
        </Box>
      </Section>

      <Section title="Class Skill Boosts">
        <Table>
          <Table.Row header>
            <Table.Cell>Skill Category</Table.Cell>
            <Table.Cell>Boost Multiplier</Table.Cell>
            <Table.Cell>Description</Table.Cell>
          </Table.Row>
          {getClassSkillBoosts(current_class).map(([skill, boost]) => (
            <Table.Row key={skill}>
              <Table.Cell>{skill}</Table.Cell>
              <Table.Cell>
                <Box textColor="green">+{((boost - 1) * 100).toFixed(0)}%</Box>
              </Table.Cell>
              <Table.Cell>Primary skill for {current_class} class</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Box>
  );
};

const MilestoneTracker = (props, context) => {
  const { skill_milestones, skill_summary, act } = props;

  const milestoneLevels = [
    { level: 2, name: 'Novice', color: 'blue' },
    { level: 3, name: 'Apprentice', color: 'green' },
    { level: 4, name: 'Journeyman', color: 'yellow' },
    { level: 5, name: 'Expert', color: 'orange' },
    { level: 6, name: 'Master', color: 'red' },
    { level: 7, name: 'Legendary', color: 'purple' },
  ];

  return (
    <Box>
      <Section title="Skill Milestones">
        <NoticeBox info>
          Track your progress through skill milestones and unlock progression rewards.
        </NoticeBox>

        {milestoneLevels.map(({ level, name, color }) => (
          <Section key={level} title={`${name} Milestones`} level={2}>
            <Table>
              <Table.Row header>
                <Table.Cell>Skill</Table.Cell>
                <Table.Cell>Current Level</Table.Cell>
                <Table.Cell>Milestone Status</Table.Cell>
                <Table.Cell>Rewards</Table.Cell>
              </Table.Row>
              {Object.entries(skill_summary || {}).map(([skillType, skillData]) => {
                const hasMilestone = skill_milestones?.[skillType]?.includes(level);
                const canReach = skillData.level >= level;

                return (
                  <Table.Row key={skillType}>
                    <Table.Cell>{skillType.split('/').pop()}</Table.Cell>
                    <Table.Cell>
                      <Box textColor={getSkillLevelColor(skillData.level)}>
                        {skillData.level_name} ({skillData.level})
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      {hasMilestone ? (
                        <Box textColor="green">
                          <Icon name="check" /> Achieved
                        </Box>
                      ) : canReach ? (
                        <Box textColor="orange">
                          <Icon name="times" /> Not Claimed
                        </Box>
                      ) : (
                        <Box textColor="gray">
                          <Icon name="minus" /> Not Reached
                        </Box>
                      )}
                    </Table.Cell>
                    <Table.Cell>
                      {hasMilestone ? (
                        <Box textColor="green">
                          +{getMilestoneReward(level)} XP
                        </Box>
                      ) : (
                        <Box textColor="gray">-</Box>
                      )}
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          </Section>
        ))}
      </Section>
    </Box>
  );
};

const SkillAnalytics = (props, context) => {
  const { skill_summary, performance_metrics, rounds_played, act } = props;

  const skillData = Object.values(skill_summary || {});
  const totalSkills = skillData.length;
  const activeSkills = skillData.filter(skill => skill.level > 1).length;
  const averageLevel = skillData.reduce((sum, skill) => sum + skill.level, 0) / totalSkills;

  return (
    <Box>
      <Section title="Skill Analytics">
        <LabeledList>
          <LabeledList.Item label="Total Skills">{totalSkills}</LabeledList.Item>
          <LabeledList.Item label="Active Skills">{activeSkills}</LabeledList.Item>
          <LabeledList.Item label="Average Skill Level">{averageLevel.toFixed(1)}</LabeledList.Item>
          <LabeledList.Item label="Highest Skill Level">{performance_metrics?.highest_skill_level || 0}</LabeledList.Item>
          <LabeledList.Item label="Total Skill Levels">{performance_metrics?.total_skill_levels || 0}</LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Skill Distribution by Class">
        <Table>
          <Table.Row header>
            <Table.Cell>Class</Table.Cell>
            <Table.Cell>Skills</Table.Cell>
            <Table.Cell>Average Level</Table.Cell>
            <Table.Cell>Highest Level</Table.Cell>
          </Table.Row>
          {getClassSkillStats(skillData).map(([className, stats]) => (
            <Table.Row key={className}>
              <Table.Cell>{className}</Table.Cell>
              <Table.Cell>{stats.count}</Table.Cell>
              <Table.Cell>{stats.average.toFixed(1)}</Table.Cell>
              <Table.Cell>{stats.highest}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Box>
  );
};

// Helper functions
const getSkillExpForLevel = (level) => {
  const expList = [0, 100, 250, 500, 900, 1500, 2500];
  return expList[level] || 2500;
};

const getSkillLevelColor = (level) => {
  if (level >= 7) return 'purple';
  if (level >= 6) return 'red';
  if (level >= 5) return 'orange';
  if (level >= 4) return 'yellow';
  if (level >= 3) return 'green';
  if (level >= 2) return 'blue';
  return 'gray';
};

const getSkillBasedRankRequirements = () => ({
  1: { total_skill_levels: 10 },
  2: { total_skill_levels: 25, expert_skills: 1 },
  3: { total_skill_levels: 50, expert_skills: 2, master_skills: 1 },
  4: { total_skill_levels: 100, expert_skills: 3, master_skills: 2 },
  5: { total_skill_levels: 200, expert_skills: 5, master_skills: 3, legendary_skills: 1 },
});

const calculatePlayerSkillStats = (skillSummary) => {
  const stats = {
    total_skill_levels: 0,
    expert_skills: 0,
    master_skills: 0,
    legendary_skills: 0,
  };

  Object.values(skillSummary || {}).forEach(skill => {
    stats.total_skill_levels += skill.level;
    if (skill.level >= 5) stats.expert_skills++;
    if (skill.level >= 6) stats.master_skills++;
    if (skill.level >= 7) stats.legendary_skills++;
  });

  return stats;
};

const formatRequirementName = (requirement) => {
  const names = {
    total_skill_levels: 'Total Skill Levels',
    expert_skills: 'Expert Skills',
    master_skills: 'Master Skills',
    legendary_skills: 'Legendary Skills',
  };
  return names[requirement] || requirement;
};

const getClassSkillBoosts = (className) => {
  const boosts = {
    security: [['Combat', 1.5], ['Security', 1.5], ['Melee', 1.5], ['Firearms', 1.5]],
    engineering: [['Engineering', 1.5], ['Construction', 1.5], ['Electrical', 1.5], ['Atmospherics', 1.5]],
    medical: [['Medical', 1.5], ['Surgery', 1.5], ['Chemistry', 1.5]],
    research: [['Science', 1.5], ['Plasmatech', 1.5], ['Robotics', 1.5]],
    containment: [['Containment', 1.5], ['Security', 1.3], ['Combat', 1.3]],
  };
  return boosts[className] || [];
};

const getMilestoneReward = (level) => {
  const rewards = { 2: 10, 3: 25, 4: 50, 5: 100, 6: 250, 7: 500 };
  return rewards[level] || 0;
};

const getClassSkillStats = (skillData) => {
  const classStats = {};

  skillData.forEach(skill => {
    const className = skill.progression_class;
    if (!classStats[className]) {
      classStats[className] = { count: 0, total: 0, highest: 0 };
    }
    classStats[className].count++;
    classStats[className].total += skill.level;
    classStats[className].highest = Math.max(classStats[className].highest, skill.level);
  });

  return Object.entries(classStats).map(([className, stats]) => [
    className,
    {
      count: stats.count,
      average: stats.total / stats.count,
      highest: stats.highest,
    }
  ]);
};


