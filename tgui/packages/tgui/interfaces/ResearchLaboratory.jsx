import React from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';

export const ResearchLaboratory = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = React.useState('overview');
  const [selectedProject, setSelectedProject] = React.useState(null);
  const [selectedExperiment, setSelectedExperiment] = React.useState(null);

  const {
    research_projects,
    active_experiments,
    research_teams,
    research_facilities,
    safety_protocols,
    research_achievements,
    system_metrics,
    scp_research_data,
    technology_data,
    researcher_skills, // New: Research skill data
  } = data;

  return (
    <Window
      title="SCP Foundation Research Laboratory"
      width={1400}
      height={900}
      theme="scp_terminal"
    >
      <Window.Content>
        <Flex>
          {/* Left Panel - Navigation */}
          <Flex.Item width="200px">
            <Section title="Research Navigation">
              <Button
                fluid
                selected={activeTab === 'overview'}
                onClick={() => setActiveTab('overview')}
                mb={1}
              >
                <Icon name="home" mr={1} />
                Overview
              </Button>
              <Button
                fluid
                selected={activeTab === 'projects'}
                onClick={() => setActiveTab('projects')}
                mb={1}
              >
                <Icon name="folder" mr={1} />
                Research Projects
              </Button>
              <Button
                fluid
                selected={activeTab === 'experiments'}
                onClick={() => setActiveTab('experiments')}
                mb={1}
              >
                <Icon name="flask" mr={1} />
                Active Experiments
              </Button>
              <Button
                fluid
                selected={activeTab === 'teams'}
                onClick={() => setActiveTab('teams')}
                mb={1}
              >
                <Icon name="users" mr={1} />
                Research Teams
              </Button>
              <Button
                fluid
                selected={activeTab === 'skills'}
                onClick={() => setActiveTab('skills')}
                mb={1}
              >
                <Icon name="graduation-cap" mr={1} />
                Research Skills
              </Button>
              <Button
                fluid
                selected={activeTab === 'facilities'}
                onClick={() => setActiveTab('facilities')}
                mb={1}
              >
                <Icon name="building" mr={1} />
                Facilities
              </Button>
              <Button
                fluid
                selected={activeTab === 'safety'}
                onClick={() => setActiveTab('safety')}
                mb={1}
              >
                <Icon name="shield-alt" mr={1} />
                Safety Protocols
              </Button>
              <Button
                fluid
                selected={activeTab === 'achievements'}
                onClick={() => setActiveTab('achievements')}
                mb={1}
              >
                <Icon name="trophy" mr={1} />
                Achievements
              </Button>
            </Section>
          </Flex.Item>

          {/* Right Panel - Content */}
          <Flex.Item grow={1}>
            {activeTab === 'overview' && <ResearchOverview />}
            {activeTab === 'projects' && <ResearchProjects />}
            {activeTab === 'experiments' && <ActiveExperiments />}
            {activeTab === 'teams' && <ResearchTeams />}
            {activeTab === 'skills' && <ResearchSkills />}
            {activeTab === 'facilities' && <ResearchFacilities />}
            {activeTab === 'safety' && <SafetyProtocols />}
            {activeTab === 'achievements' && <ResearchAchievements />}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const NavigationSidebar = ({ activeTab, setActiveTab, systemMetrics }) => {
  const navigationItems = [
    { id: 'overview', name: 'System Overview', icon: 'home' },
    { id: 'projects', name: 'Research Projects', icon: 'folder' },
    { id: 'experiments', name: 'Active Experiments', icon: 'flask' },
    { id: 'teams', name: 'Research Teams', icon: 'users' },
    { id: 'facilities', name: 'Research Facilities', icon: 'building' },
    { id: 'safety', name: 'Safety Protocols', icon: 'shield-alt' },
    { id: 'achievements', name: 'Achievements', icon: 'trophy' },
    { id: 'integration', name: 'Research Integration', icon: 'link' },
  ];

  return (
    <Box>
      <Section title="Research Laboratory">
        <Box
          style={{
            background: 'rgba(0,0,0,0.7)',
            border: '1px solid rgba(255,255,255,0.2)',
            borderRadius: '5px',
            padding: '10px',
            marginBottom: '15px',
            fontFamily: 'monospace',
            fontSize: '12px',
            color: '#ffffff',
          }}
        >
          <Box style={{ textAlign: 'center', marginBottom: '10px' }}>
            <Box style={{ fontSize: '16px', fontWeight: 'bold' }}>
              RESEARCH LABORATORY
            </Box>
            <Box style={{ fontSize: '14px', opacity: 0.8 }}>
              Advanced Research System
            </Box>
          </Box>

          <Box style={{ fontSize: '10px' }}>
            <Box>
              Research Points: {systemMetrics?.total_research_points || 0}
            </Box>
            <Box>
              Active Experiments: {systemMetrics?.total_experiments || 0}
            </Box>
            <Box>Breakthroughs: {systemMetrics?.total_breakthroughs || 0}</Box>
            <Box>Safety Rating: {systemMetrics?.safety_rating || 100}%</Box>
          </Box>
        </Box>

        {navigationItems.map((item) => (
          <Button
            key={item.id}
            content={
              <Flex align="center">
                <Flex.Item>
                  <Icon name={item.icon} mr={1} />
                </Flex.Item>
                <Flex.Item>{item.name}</Flex.Item>
              </Flex>
            }
            selected={activeTab === item.id}
            onClick={() => setActiveTab(item.id)}
            fluid
            mb={1}
          />
        ))}
      </Section>
    </Box>
  );
};

const SystemOverview = ({
  systemMetrics,
  researchProjects,
  activeExperiments,
  researchTeams,
  safetyProtocols,
  act,
}) => {
  return (
    <Box>
      <Section title="Research Laboratory Overview">
        <Flex>
          <Flex.Item width="50%">
            <Section title="System Metrics" level={2}>
              <LabeledList>
                <LabeledList.Item label="Total Research Points">
                  {systemMetrics?.total_research_points || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Active Experiments">
                  {systemMetrics?.total_experiments || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Research Breakthroughs">
                  {systemMetrics?.total_breakthroughs || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Research Efficiency">
                  {(systemMetrics?.research_efficiency || 1.0) * 100}%
                </LabeledList.Item>
                <LabeledList.Item label="Safety Rating">
                  <ProgressBar
                    value={systemMetrics?.safety_rating || 100}
                    maxValue={100}
                    color={
                      systemMetrics?.safety_rating > 80
                        ? 'green'
                        : systemMetrics?.safety_rating > 60
                          ? 'yellow'
                          : 'red'
                    }
                  >
                    {systemMetrics?.safety_rating || 100}%
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Containment Breaches">
                  <Box
                    color={
                      systemMetrics?.containment_breaches > 0 ? 'red' : 'green'
                    }
                  >
                    {systemMetrics?.containment_breaches || 0}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Research Incidents">
                  <Box
                    color={
                      systemMetrics?.research_incidents > 0 ? 'orange' : 'green'
                    }
                  >
                    {systemMetrics?.research_incidents || 0}
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Flex.Item>

          <Flex.Item width="50%" ml={2}>
            <Section title="Quick Statistics" level={2}>
              <LabeledList>
                <LabeledList.Item label="Research Projects">
                  {researchProjects ? Object.keys(researchProjects).length : 0}
                </LabeledList.Item>
                <LabeledList.Item label="Active Experiments">
                  {activeExperiments
                    ? Object.keys(activeExperiments).length
                    : 0}
                </LabeledList.Item>
                <LabeledList.Item label="Research Teams">
                  {researchTeams ? Object.keys(researchTeams).length : 0}
                </LabeledList.Item>
                <LabeledList.Item label="Safety Protocols">
                  {safetyProtocols ? Object.keys(safetyProtocols).length : 0}
                </LabeledList.Item>
              </LabeledList>

              <Box mt={2}>
                <Button
                  content="Create New Project"
                  icon="plus"
                  onClick={() => act('create_project')}
                  color="blue"
                  fluid
                  mb={1}
                />
                <Button
                  content="Create Research Team"
                  icon="users"
                  onClick={() => act('create_team')}
                  color="green"
                  fluid
                  mb={1}
                />
                <Button
                  content="Register Facility"
                  icon="building"
                  onClick={() => act('create_facility')}
                  color="orange"
                  fluid
                />
              </Box>
            </Section>
          </Flex.Item>
        </Flex>

        {systemMetrics?.research_incidents > 0 && (
          <Section title="Recent Incidents" color="orange">
            <Box
              p={2}
              backgroundColor="rgba(255, 165, 0, 0.1)"
              border="1px solid orange"
              borderRadius="5px"
            >
              <Flex align="center">
                <Flex.Item>
                  <Icon name="exclamation-triangle" color="orange" mr={2} />
                </Flex.Item>
                <Flex.Item grow={1}>
                  <Box>
                    {systemMetrics.research_incidents} research incident(s)
                    detected
                  </Box>
                  <Box fontSize="12px" opacity={0.7}>
                    Review safety protocols and experiment parameters
                  </Box>
                </Flex.Item>
              </Flex>
            </Box>
          </Section>
        )}
      </Section>
    </Box>
  );
};

const ProjectManagement = ({
  researchProjects,
  selectedProject,
  setSelectedProject,
  act,
}) => {
  const projectList = researchProjects ? Object.values(researchProjects) : [];

  return (
    <Box>
      <Section title="Research Project Management">
        <Flex>
          <Flex.Item width="400px">
            <Section title="Research Projects" level={2}>
              <Table>
                <Table.Row header>
                  <Table.Cell>Project</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>SCP Target</Table.Cell>
                  <Table.Cell>Progress</Table.Cell>
                </Table.Row>
                {projectList.map((project) => (
                  <Table.Row
                    key={project.id}
                    className={selectedProject === project.id ? 'selected' : ''}
                    onClick={() => setSelectedProject(project.id)}
                    style={{ cursor: 'pointer' }}
                  >
                    <Table.Cell>
                      <Box fontWeight="bold">{project.name}</Box>
                      <Box fontSize="11px" opacity={0.7}>
                        {project.description}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box
                        color={
                          project.status === 'approved'
                            ? 'green'
                            : project.status === 'proposed'
                              ? 'yellow'
                              : 'red'
                        }
                      >
                        {project.status}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>{project.scp_target || 'N/A'}</Table.Cell>
                    <Table.Cell>
                      <ProgressBar
                        value={project.progress || 0}
                        maxValue={100}
                        color={
                          project.progress > 80
                            ? 'green'
                            : project.progress > 50
                              ? 'yellow'
                              : 'blue'
                        }
                      >
                        {project.progress || 0}%
                      </ProgressBar>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Flex.Item>

          <Flex.Item grow={1} ml={2}>
            {selectedProject ? (
              <ProjectDetails
                project={projectList.find((p) => p.id === selectedProject)}
                act={act}
              />
            ) : (
              <Section title="Select a Project" level={2}>
                <Box p={4} textAlign="center" opacity={0.7}>
                  <Icon name="folder" size={3} mb={2} />
                  <Box>
                    Select a research project from the list to view details.
                  </Box>
                </Box>
              </Section>
            )}
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const ProjectDetails = ({ project, act }) => {
  if (!project) return null;

  return (
    <Section title={`Project: ${project.name}`} level={2}>
      <LabeledList>
        <LabeledList.Item label="Project ID">{project.id}</LabeledList.Item>
        <LabeledList.Item label="Description">
          {project.description}
        </LabeledList.Item>
        <LabeledList.Item label="SCP Target">
          {project.scp_target || 'N/A'}
        </LabeledList.Item>
        <LabeledList.Item label="Status">
          <Box
            color={
              project.status === 'approved'
                ? 'green'
                : project.status === 'proposed'
                  ? 'yellow'
                  : 'red'
            }
          >
            {project.status}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Progress">
          <ProgressBar
            value={project.progress || 0}
            maxValue={100}
            color={
              project.progress > 80
                ? 'green'
                : project.progress > 50
                  ? 'yellow'
                  : 'blue'
            }
          >
            {project.progress || 0}%
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Research Points">
          {project.research_points || 100}
        </LabeledList.Item>
        <LabeledList.Item label="Risk Level">
          {project.risk_level || 1}
        </LabeledList.Item>
        <LabeledList.Item label="Created">
          {new Date(project.creation_time * 1000).toLocaleString()}
        </LabeledList.Item>
      </LabeledList>

      <Box mt={3}>
        {project.status === 'proposed' && (
          <Button
            content="Approve Project"
            icon="check"
            onClick={() => act('approve_project', { project_id: project.id })}
            color="green"
            mr={1}
          />
        )}
        <Button content="Edit Project" icon="edit" color="blue" mr={1} />
        <Button content="Delete Project" icon="trash" color="red" />
      </Box>
    </Section>
  );
};

const ExperimentMonitoring = ({
  activeExperiments,
  selectedExperiment,
  setSelectedExperiment,
  act,
}) => {
  const experimentList = activeExperiments
    ? Object.values(activeExperiments)
    : [];

  return (
    <Box>
      <Section title="Active Experiment Monitoring">
        <Flex>
          <Flex.Item width="400px">
            <Section title="Active Experiments" level={2}>
              <Table>
                <Table.Row header>
                  <Table.Cell>Experiment</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Progress</Table.Cell>
                  <Table.Cell>Risk</Table.Cell>
                </Table.Row>
                {experimentList.map((experiment) => (
                  <Table.Row
                    key={experiment.id}
                    className={
                      selectedExperiment === experiment.id ? 'selected' : ''
                    }
                    onClick={() => setSelectedExperiment(experiment.id)}
                    style={{ cursor: 'pointer' }}
                  >
                    <Table.Cell>
                      <Box fontWeight="bold">{experiment.name}</Box>
                      <Box fontSize="11px" opacity={0.7}>
                        {experiment.description}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box
                        color={
                          experiment.status === 'active'
                            ? 'green'
                            : experiment.status === 'suspended'
                              ? 'orange'
                              : 'red'
                        }
                      >
                        {experiment.status}
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <ProgressBar
                        value={experiment.current_progress || 0}
                        maxValue={experiment.max_progress || 100}
                        color={
                          experiment.current_progress > 80
                            ? 'green'
                            : experiment.current_progress > 50
                              ? 'yellow'
                              : 'blue'
                        }
                      >
                        {experiment.current_progress || 0}/
                        {experiment.max_progress || 100}
                      </ProgressBar>
                    </Table.Cell>
                    <Table.Cell>
                      <Box
                        color={
                          experiment.risk_level > 7
                            ? 'red'
                            : experiment.risk_level > 4
                              ? 'orange'
                              : 'green'
                        }
                      >
                        {experiment.risk_level || 1}
                      </Box>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Flex.Item>

          <Flex.Item grow={1} ml={2}>
            {selectedExperiment ? (
              <ExperimentDetails
                experiment={experimentList.find(
                  (e) => e.id === selectedExperiment,
                )}
                act={act}
              />
            ) : (
              <Section title="Select an Experiment" level={2}>
                <Box p={4} textAlign="center" opacity={0.7}>
                  <Icon name="flask" size={3} mb={2} />
                  <Box>
                    Select an active experiment from the list to view details.
                  </Box>
                </Box>
              </Section>
            )}
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const ExperimentDetails = ({ experiment, act }) => {
  if (!experiment) return null;

  return (
    <Section title={`Experiment: ${experiment.name}`} level={2}>
      <LabeledList>
        <LabeledList.Item label="Experiment ID">
          {experiment.id}
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          {experiment.description}
        </LabeledList.Item>
        <LabeledList.Item label="SCP Target">
          {experiment.scp_target || 'N/A'}
        </LabeledList.Item>
        <LabeledList.Item label="Status">
          <Box
            color={
              experiment.status === 'active'
                ? 'green'
                : experiment.status === 'suspended'
                  ? 'orange'
                  : 'red'
            }
          >
            {experiment.status}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Progress">
          <ProgressBar
            value={experiment.current_progress || 0}
            maxValue={experiment.max_progress || 100}
            color={
              experiment.current_progress > 80
                ? 'green'
                : experiment.current_progress > 50
                  ? 'yellow'
                  : 'blue'
            }
          >
            {experiment.current_progress || 0}/{experiment.max_progress || 100}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Research Points">
          {experiment.research_points || 100}
        </LabeledList.Item>
        <LabeledList.Item label="Risk Level">
          <Box
            color={
              experiment.risk_level > 7
                ? 'red'
                : experiment.risk_level > 4
                  ? 'orange'
                  : 'green'
            }
          >
            {experiment.risk_level || 1}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Data Points Collected">
          {experiment.data_points_collected || 0}
        </LabeledList.Item>
        <LabeledList.Item label="Breakthrough Chance">
          {experiment.breakthrough_chance || 5}%
        </LabeledList.Item>
        <LabeledList.Item label="Started">
          {new Date(experiment.start_time * 1000).toLocaleString()}
        </LabeledList.Item>
      </LabeledList>

      {experiment.breakthrough && (
        <Box
          mt={2}
          p={2}
          backgroundColor="rgba(0, 255, 0, 0.1)"
          border="1px solid green"
          borderRadius="5px"
        >
          <Flex align="center">
            <Flex.Item>
              <Icon name="star" color="gold" mr={2} />
            </Flex.Item>
            <Flex.Item grow={1}>
              <Box fontWeight="bold" color="gold">
                BREAKTHROUGH ACHIEVED!
              </Box>
              <Box fontSize="12px">
                This experiment has achieved a major research breakthrough.
              </Box>
            </Flex.Item>
          </Flex>
        </Box>
      )}

      <Box mt={3}>
        <Button
          content="Suspend Experiment"
          icon="pause"
          onClick={() =>
            act('suspend_experiment', { experiment_id: experiment.id })
          }
          color="orange"
          mr={1}
        />
        <Button
          content="Terminate Experiment"
          icon="stop"
          onClick={() =>
            act('terminate_experiment', { experiment_id: experiment.id })
          }
          color="red"
          mr={1}
        />
        <Button content="View Data" icon="database" color="blue" />
      </Box>
    </Section>
  );
};

const TeamManagement = ({ researchTeams, act }) => {
  const teamList = researchTeams ? Object.values(researchTeams) : [];

  return (
    <Box>
      <Section title="Research Team Management">
        <Flex>
          <Flex.Item width="50%">
            <Section title="Research Teams" level={2}>
              {teamList.map((team) => (
                <Box
                  key={team.id}
                  mb={2}
                  p={2}
                  backgroundColor="rgba(0,0,0,0.3)"
                  border="1px solid rgba(255,255,255,0.2)"
                  borderRadius="5px"
                >
                  <Flex align="center" mb={2}>
                    <Flex.Item grow={1}>
                      <Box fontSize="16px" fontWeight="bold">
                        {team.name || team.id}
                      </Box>
                      <Box fontSize="12px" opacity={0.7}>
                        {team.members ? team.members.length : 0} members
                      </Box>
                    </Flex.Item>
                    <Flex.Item>
                      <Box color={team.status === 'active' ? 'green' : 'red'}>
                        {team.status}
                      </Box>
                    </Flex.Item>
                  </Flex>

                  <Box fontSize="12px">
                    <Box>
                      Completed Experiments: {team.completed_experiments || 0}
                    </Box>
                    <Box>
                      Total Research Points: {team.total_research_points || 0}
                    </Box>
                  </Box>

                  <Box mt={2}>
                    <Button
                      content="View Members"
                      icon="users"
                      size="small"
                      color="blue"
                      mr={1}
                    />
                    <Button
                      content="Edit Team"
                      icon="edit"
                      size="small"
                      color="green"
                    />
                  </Box>
                </Box>
              ))}
            </Section>
          </Flex.Item>

          <Flex.Item width="50%" ml={2}>
            <Section title="Team Statistics" level={2}>
              <LabeledList>
                <LabeledList.Item label="Total Teams">
                  {teamList.length}
                </LabeledList.Item>
                <LabeledList.Item label="Active Teams">
                  {teamList.filter((team) => team.status === 'active').length}
                </LabeledList.Item>
                <LabeledList.Item label="Total Members">
                  {teamList.reduce(
                    (total, team) =>
                      total + (team.members ? team.members.length : 0),
                    0,
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Average Team Size">
                  {teamList.length > 0
                    ? Math.round(
                        teamList.reduce(
                          (total, team) =>
                            total + (team.members ? team.members.length : 0),
                          0,
                        ) / teamList.length,
                      )
                    : 0}
                </LabeledList.Item>
              </LabeledList>

              <Box mt={3}>
                <Button
                  content="Create New Team"
                  icon="plus"
                  onClick={() => act('create_team')}
                  color="green"
                  fluid
                  mb={1}
                />
                <Button
                  content="Add Team Member"
                  icon="user-plus"
                  onClick={() => act('add_team_member')}
                  color="blue"
                  fluid
                />
              </Box>
            </Section>
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const FacilityManagement = ({ researchFacilities, act }) => {
  const facilityList = researchFacilities
    ? Object.values(researchFacilities)
    : [];

  return (
    <Box>
      <Section title="Research Facility Management">
        <Flex>
          <Flex.Item width="50%">
            <Section title="Research Facilities" level={2}>
              {facilityList.map((facility) => (
                <Box
                  key={facility.id}
                  mb={2}
                  p={2}
                  backgroundColor="rgba(0,0,0,0.3)"
                  border="1px solid rgba(255,255,255,0.2)"
                  borderRadius="5px"
                >
                  <Flex align="center" mb={2}>
                    <Flex.Item grow={1}>
                      <Box fontSize="16px" fontWeight="bold">
                        {facility.name || facility.id}
                      </Box>
                      <Box fontSize="12px" opacity={0.7}>
                        {facility.active_experiments || 0} active experiments
                      </Box>
                    </Flex.Item>
                    <Flex.Item>
                      <Box
                        color={
                          facility.status === 'operational' ? 'green' : 'red'
                        }
                      >
                        {facility.status}
                      </Box>
                    </Flex.Item>
                  </Flex>

                  <Box fontSize="12px">
                    <Box>Safety Rating: {facility.safety_rating || 100}%</Box>
                    <Box>Location: {facility.location || 'Unknown'}</Box>
                  </Box>

                  <Box mt={2}>
                    <Button
                      content="View Details"
                      icon="info"
                      size="small"
                      color="blue"
                      mr={1}
                    />
                    <Button
                      content="Edit Facility"
                      icon="edit"
                      size="small"
                      color="green"
                    />
                  </Box>
                </Box>
              ))}
            </Section>
          </Flex.Item>

          <Flex.Item width="50%" ml={2}>
            <Section title="Facility Statistics" level={2}>
              <LabeledList>
                <LabeledList.Item label="Total Facilities">
                  {facilityList.length}
                </LabeledList.Item>
                <LabeledList.Item label="Operational Facilities">
                  {
                    facilityList.filter(
                      (facility) => facility.status === 'operational',
                    ).length
                  }
                </LabeledList.Item>
                <LabeledList.Item label="Average Safety Rating">
                  {facilityList.length > 0
                    ? Math.round(
                        facilityList.reduce(
                          (total, facility) =>
                            total + (facility.safety_rating || 100),
                          0,
                        ) / facilityList.length,
                      )
                    : 100}
                  %
                </LabeledList.Item>
                <LabeledList.Item label="Total Active Experiments">
                  {facilityList.reduce(
                    (total, facility) =>
                      total + (facility.active_experiments || 0),
                    0,
                  )}
                </LabeledList.Item>
              </LabeledList>

              <Box mt={3}>
                <Button
                  content="Register New Facility"
                  icon="plus"
                  onClick={() => act('create_facility')}
                  color="green"
                  fluid
                  mb={1}
                />
                <Button
                  content="Safety Audit"
                  icon="shield-alt"
                  onClick={() => act('safety_audit')}
                  color="orange"
                  fluid
                />
              </Box>
            </Section>
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const SafetyProtocols = ({ safetyProtocols, act }) => {
  const protocolList = safetyProtocols ? Object.values(safetyProtocols) : [];

  return (
    <Box>
      <Section title="Safety Protocol Management">
        <Flex>
          <Flex.Item width="50%">
            <Section title="Safety Protocols" level={2}>
              {protocolList.map((protocol) => (
                <Box
                  key={protocol.id}
                  mb={2}
                  p={2}
                  backgroundColor="rgba(0,0,0,0.3)"
                  border="1px solid rgba(255,255,255,0.2)"
                  borderRadius="5px"
                >
                  <Flex align="center" mb={2}>
                    <Flex.Item grow={1}>
                      <Box fontSize="16px" fontWeight="bold">
                        {protocol.name || protocol.id}
                      </Box>
                      <Box fontSize="12px" opacity={0.7}>
                        {protocol.description || 'No description'}
                      </Box>
                    </Flex.Item>
                    <Flex.Item>
                      <Box
                        color={
                          protocol.status === 'active'
                            ? 'green'
                            : protocol.status === 'emergency'
                              ? 'red'
                              : 'orange'
                        }
                      >
                        {protocol.status}
                      </Box>
                    </Flex.Item>
                  </Flex>

                  <Box fontSize="12px">
                    <Box>Violations: {protocol.violations || 0}</Box>
                    <Box>Threshold: {protocol.violation_threshold || 5}</Box>
                  </Box>

                  <Box mt={2}>
                    <Button
                      content="View Details"
                      icon="info"
                      size="small"
                      color="blue"
                      mr={1}
                    />
                    <Button
                      content="Edit Protocol"
                      icon="edit"
                      size="small"
                      color="green"
                    />
                  </Box>
                </Box>
              ))}
            </Section>
          </Flex.Item>

          <Flex.Item width="50%" ml={2}>
            <Section title="Safety Overview" level={2}>
              <LabeledList>
                <LabeledList.Item label="Total Protocols">
                  {protocolList.length}
                </LabeledList.Item>
                <LabeledList.Item label="Active Protocols">
                  {
                    protocolList.filter(
                      (protocol) => protocol.status === 'active',
                    ).length
                  }
                </LabeledList.Item>
                <LabeledList.Item label="Emergency Protocols">
                  {
                    protocolList.filter(
                      (protocol) => protocol.status === 'emergency',
                    ).length
                  }
                </LabeledList.Item>
                <LabeledList.Item label="Total Violations">
                  {protocolList.reduce(
                    (total, protocol) => total + (protocol.violations || 0),
                    0,
                  )}
                </LabeledList.Item>
              </LabeledList>

              <Box mt={3}>
                <Button
                  content="Create New Protocol"
                  icon="plus"
                  onClick={() => act('create_safety_protocol')}
                  color="green"
                  fluid
                  mb={1}
                />
                <Button
                  content="Emergency Review"
                  icon="exclamation-triangle"
                  onClick={() => act('emergency_review')}
                  color="red"
                  fluid
                />
              </Box>
            </Section>
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const AchievementTracker = ({ researchAchievements, act }) => {
  const achievementList = researchAchievements
    ? Object.values(researchAchievements)
    : [];

  return (
    <Box>
      <Section title="Research Achievement Tracker">
        <Flex>
          <Flex.Item width="50%">
            <Section title="Unlocked Achievements" level={2}>
              {achievementList.map((achievement) => (
                <Box
                  key={achievement.id}
                  mb={2}
                  p={2}
                  backgroundColor="rgba(0, 255, 0, 0.1)"
                  border="1px solid green"
                  borderRadius="5px"
                >
                  <Flex align="center">
                    <Flex.Item>
                      <Icon name="trophy" color="gold" mr={2} />
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <Box fontWeight="bold">{achievement.description}</Box>
                      <Box fontSize="12px" opacity={0.7}>
                        Unlocked:{' '}
                        {new Date(
                          achievement.unlock_time * 1000,
                        ).toLocaleString()}
                      </Box>
                    </Flex.Item>
                  </Flex>
                </Box>
              ))}
            </Section>
          </Flex.Item>

          <Flex.Item width="50%" ml={2}>
            <Section title="Achievement Statistics" level={2}>
              <LabeledList>
                <LabeledList.Item label="Total Achievements">
                  {achievementList.length}
                </LabeledList.Item>
                <LabeledList.Item label="Recent Achievements">
                  {
                    achievementList.filter(
                      (achievement) =>
                        achievement.unlock_time > world.time - 36000,
                    ).length
                  }
                </LabeledList.Item>
              </LabeledList>

              <Box mt={3}>
                <Button
                  content="View All Achievements"
                  icon="trophy"
                  color="gold"
                  fluid
                  mb={1}
                />
                <Button
                  content="Achievement Report"
                  icon="file-alt"
                  color="blue"
                  fluid
                />
              </Box>
            </Section>
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const ResearchIntegration = ({ scpResearchData, technologyData, act }) => {
  return (
    <Box>
      <Section title="Research System Integration">
        <Flex>
          <Flex.Item width="50%">
            <Section title="SCP Research System" level={2}>
              <LabeledList>
                <LabeledList.Item label="Total Research Points">
                  {scpResearchData?.total_research_points || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Research Breakthroughs">
                  {scpResearchData?.research_breakthroughs || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Containment Improvements">
                  {scpResearchData?.containment_improvements || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Classification Updates">
                  {scpResearchData?.classification_updates || 0}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Flex.Item>

          <Flex.Item width="50%" ml={2}>
            <Section title="Technology Persistence" level={2}>
              <LabeledList>
                <LabeledList.Item label="Technology Level">
                  {technologyData?.technology_level || 1}
                </LabeledList.Item>
                <LabeledList.Item label="Innovation Score">
                  {technologyData?.innovation_score || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Research Progress">
                  {technologyData?.research_progress || 0}
                </LabeledList.Item>
                <LabeledList.Item label="Breakthrough Chance">
                  {(
                    (technologyData?.breakthrough_chance || 0.05) * 100
                  ).toFixed(1)}
                  %
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Flex.Item>
        </Flex>

        <Section title="Integration Status" level={2} mt={2}>
          <Box
            p={2}
            backgroundColor="rgba(0, 255, 0, 0.1)"
            border="1px solid green"
            borderRadius="5px"
          >
            <Flex align="center">
              <Flex.Item>
                <Icon name="check-circle" color="green" mr={2} />
              </Flex.Item>
              <Flex.Item grow={1}>
                <Box fontWeight="bold" color="green">
                  Research Systems Integrated
                </Box>
                <Box fontSize="12px">
                  All research persistence systems are connected and
                  synchronized
                </Box>
              </Flex.Item>
            </Flex>
          </Box>
        </Section>
      </Section>
    </Box>
  );
};

// Research Skills Tab Component
const ResearchSkills = (props, context) => {
  const { act, data } = useBackend(context);
  const { researcher_skills, active_experiments, research_teams } = data;

  return (
    <Section title="Research Skills Analysis">
      <Flex>
        <Flex.Item width="50%">
          <Section title="Researcher Skill Levels" level={2}>
            {researcher_skills && Object.keys(researcher_skills).length > 0 ? (
              <Table>
                <Table.Row header>
                  <Table.Cell>Researcher</Table.Cell>
                  <Table.Cell>Research Skill</Table.Cell>
                  <Table.Cell>Level</Table.Cell>
                  <Table.Cell>Bonus</Table.Cell>
                </Table.Row>
                {Object.entries(researcher_skills).map(
                  ([researcher, skillData]) => (
                    <Table.Row key={researcher}>
                      <Table.Cell>{researcher}</Table.Cell>
                      <Table.Cell>{skillData.skill_name}</Table.Cell>
                      <Table.Cell>{skillData.level}</Table.Cell>
                      <Table.Cell>
                        <Box color={skillData.bonus > 0 ? 'good' : 'normal'}>
                          +{skillData.bonus}%
                        </Box>
                      </Table.Cell>
                    </Table.Row>
                  ),
                )}
              </Table>
            ) : (
              <Box color="average">No researcher skill data available.</Box>
            )}
          </Section>
        </Flex.Item>

        <Flex.Item width="50%">
          <Section title="Skill-Based Research Bonuses" level={2}>
            <LabeledList>
              <LabeledList.Item label="Research Intuition">
                <Box color="good">
                  Level 25+ researchers gain 10% chance for insights
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Research Mastery">
                <Box color="good">
                  Level 50+ researchers gain 5% chance for optimization
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Research Breakthrough">
                <Box color="good">
                  Level 75+ researchers gain 2% chance for breakthroughs
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Legendary Research">
                <Box color="good">
                  Level 100 researchers gain 1% chance for revolutionary results
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>

          <Section title="Team Skill Synergies" level={2}>
            {research_teams && Object.keys(research_teams).length > 0 ? (
              <Table>
                <Table.Row header>
                  <Table.Cell>Team</Table.Cell>
                  <Table.Cell>Members</Table.Cell>
                  <Table.Cell>Avg Skill</Table.Cell>
                  <Table.Cell>Synergy Bonus</Table.Cell>
                </Table.Row>
                {Object.entries(research_teams).map(([teamId, teamData]) => {
                  const avgSkill = teamData.avg_research_skill || 0;
                  const synergyBonus = avgSkill * 0.5; // +0.5% per average skill level
                  return (
                    <Table.Row key={teamId}>
                      <Table.Cell>{teamData.name || teamId}</Table.Cell>
                      <Table.Cell>
                        {teamData.members ? teamData.members.length : 0}
                      </Table.Cell>
                      <Table.Cell>{avgSkill}</Table.Cell>
                      <Table.Cell>
                        <Box color={synergyBonus > 0 ? 'good' : 'normal'}>
                          +{synergyBonus.toFixed(1)}%
                        </Box>
                      </Table.Cell>
                    </Table.Row>
                  );
                })}
              </Table>
            ) : (
              <Box color="average">No research team data available.</Box>
            )}
          </Section>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

// Enhanced Active Experiments Component
const ActiveExperiments = (props, context) => {
  const { act, data } = useBackend(context);
  const { active_experiments, researcher_skills } = data;

  return (
    <Section title="Active Experiments">
      {active_experiments && Object.keys(active_experiments).length > 0 ? (
        <Table>
          <Table.Row header>
            <Table.Cell>Experiment</Table.Cell>
            <Table.Cell>Progress</Table.Cell>
            <Table.Cell>Team</Table.Cell>
            <Table.Cell>Skill Bonus</Table.Cell>
            <Table.Cell>Breakthrough Chance</Table.Cell>
            <Table.Cell>Status</Table.Cell>
          </Table.Row>
          {Object.entries(active_experiments).map(([expId, expData]) => {
            const skillBonus = expData.skill_bonus || 0;
            const breakthroughChance = expData.breakthrough_chance || 5;
            return (
              <Table.Row key={expId}>
                <Table.Cell>{expData.name}</Table.Cell>
                <Table.Cell>
                  <ProgressBar
                    value={expData.current_progress || 0}
                    maxValue={expData.max_progress || 100}
                    color={
                      expData.current_progress >= expData.max_progress * 0.8
                        ? 'good'
                        : 'normal'
                    }
                  >
                    {Math.round(
                      ((expData.current_progress || 0) /
                        (expData.max_progress || 100)) *
                        100,
                    )}
                    %
                  </ProgressBar>
                </Table.Cell>
                <Table.Cell>{expData.team_id || 'Unassigned'}</Table.Cell>
                <Table.Cell>
                  <Box color={skillBonus > 0 ? 'good' : 'normal'}>
                    +{skillBonus.toFixed(1)}%
                  </Box>
                </Table.Cell>
                <Table.Cell>
                  <Box color={breakthroughChance > 10 ? 'good' : 'normal'}>
                    {breakthroughChance.toFixed(1)}%
                  </Box>
                </Table.Cell>
                <Table.Cell>
                  <Box color={expData.status === 'active' ? 'good' : 'average'}>
                    {expData.status}
                  </Box>
                </Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      ) : (
        <Box color="average">No active experiments.</Box>
      )}
    </Section>
  );
};
