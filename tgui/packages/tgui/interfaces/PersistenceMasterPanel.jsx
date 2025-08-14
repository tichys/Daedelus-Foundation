import React from 'react';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Grid,
  Icon,
  Modal,
  ProgressBar,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';

export const PersistenceMasterPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = React.useState('terminal');

  // Debug activeTab changes
  React.useEffect(() => {
    console.log('activeTab changed to:', activeTab, 'type:', typeof activeTab);
  }, [activeTab]);

  const {
    facility_data,
    scp_data,
    technology_data,
    medical_data,
    security_data,
    research_data,
    personnel_data,
    player_data,
    system_status,
    analytics,
    notifications,
    personnel_details,
  } = data;

  // Data status indicator
  const DataStatusIndicator = ({ data, label }) => (
    <Box style={{ display: 'inline-block', marginLeft: '10px' }}>
      <Box
        style={{
          display: 'inline-block',
          width: '8px',
          height: '8px',
          borderRadius: '50%',
          backgroundColor: data ? '#00ff00' : '#ff0000',
          marginRight: '5px',
        }}
      />
      <Box style={{ fontSize: '10px', opacity: 0.7 }}>
        {label}: {data ? 'LIVE' : 'OFFLINE'}
      </Box>
    </Box>
  );

  // Grid background pattern
  const GridBackground = () => (
    <Box
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundImage: `
          linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
          linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px)
        `,
        backgroundSize: '20px 20px',
        pointerEvents: 'none',
        zIndex: 0,
      }}
    />
  );

  // SCP Foundation watermark logo
  const WatermarkLogo = () => (
    <Box
      style={{
        position: 'absolute',
        bottom: '20%',
        left: '50%',
        transform: 'translateX(-50%)',
        width: '200px',
        height: '200px',
        background:
          'radial-gradient(circle, rgba(255,255,255,0.05) 0%, transparent 70%)',
        borderRadius: '50%',
        filter: 'blur(3px)',
        pointerEvents: 'none',
        zIndex: 0,
      }}
    />
  );

  // Top navigation bar
  const TopNavigation = () => (
    <Box
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        height: '40px',
        background: 'rgba(0,0,0,0.8)',
        borderBottom: '1px solid rgba(255,255,255,0.2)',
        display: 'flex',
        alignItems: 'center',
        padding: '0 20px',
        zIndex: 10,
        fontFamily: 'monospace',
        fontSize: '14px',
        color: '#ffffff',
      }}
    >
      <Box
        style={{
          marginRight: '30px',
          padding: '8px 0',
          borderBottom: activeTab === 'terminal' ? '2px solid #ffffff' : 'none',
          cursor: 'pointer',
        }}
        onClick={() => setActiveTab('terminal')}
      >
        TERMINAL
      </Box>
      <Box
        style={{
          marginRight: '30px',
          padding: '8px 0',
          borderBottom: activeTab === 'facility' ? '2px solid #ffffff' : 'none',
          cursor: 'pointer',
        }}
        onClick={() => setActiveTab('facility')}
      >
        FACILITY
      </Box>
      <Box
        style={{
          marginRight: '30px',
          padding: '8px 0',
          borderBottom: activeTab === 'scp' ? '2px solid #ffffff' : 'none',
          cursor: 'pointer',
        }}
        onClick={() => setActiveTab('scp')}
      >
        SCP CONTAINMENT
      </Box>
      <Box
        style={{
          marginRight: '30px',
          padding: '8px 0',
          borderBottom:
            activeTab === 'technology' ? '2px solid #ffffff' : 'none',
          cursor: 'pointer',
        }}
        onClick={() => setActiveTab('technology')}
      >
        TECHNOLOGY
      </Box>
      <Box
        style={{
          marginRight: '30px',
          padding: '8px 0',
          borderBottom: activeTab === 'medical' ? '2px solid #ffffff' : 'none',
          cursor: 'pointer',
        }}
        onClick={() => setActiveTab('medical')}
      >
        MEDICAL
      </Box>
      <Box
        style={{
          marginRight: '30px',
          padding: '8px 0',
          borderBottom: activeTab === 'security' ? '2px solid #ffffff' : 'none',
          cursor: 'pointer',
        }}
        onClick={() => setActiveTab('security')}
      >
        SECURITY
      </Box>
      <Box
        style={{
          marginRight: '30px',
          padding: '8px 0',
          borderBottom: activeTab === 'research' ? '2px solid #ffffff' : 'none',
          cursor: 'pointer',
        }}
        onClick={() => setActiveTab('research')}
      >
        RESEARCH
      </Box>
      <Box
        style={{
          marginRight: '30px',
          padding: '8px 0',
          borderBottom:
            activeTab === 'personnel' ? '2px solid #ffffff' : 'none',
          cursor: 'pointer',
        }}
        onClick={() => setActiveTab('personnel')}
      >
        PERSONNEL
      </Box>
      <Box
        style={{
          padding: '8px 0',
          borderBottom: activeTab === 'players' ? '2px solid #ffffff' : 'none',
          cursor: 'pointer',
        }}
        onClick={() => setActiveTab('players')}
      >
        PLAYER DATA
      </Box>
    </Box>
  );

  // Terminal interface
  const TerminalInterface = () => (
    <Box
      style={{
        background: 'rgba(0,0,0,0.7)',
        border: '1px solid rgba(255,255,255,0.2)',
        borderRadius: '5px',
        padding: '20px',
        fontFamily: 'monospace',
        fontSize: '14px',
        color: '#ffffff',
        minHeight: '100%',
      }}
    >
      {/* Welcome Section */}
      <Box style={{ marginBottom: '20px' }}>
        <Box
          style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '5px' }}
        >
          WELCOME
        </Box>
        <Box style={{ fontSize: '16px', opacity: 0.8 }}>RESEARCHER</Box>
      </Box>

      {/* Terminal Tabs */}
      <Box style={{ marginBottom: '20px' }}>
        <Flex align="center" style={{ marginBottom: '10px' }}>
          <Box
            style={{
              padding: '8px 16px',
              background: 'rgba(255,255,255,0.1)',
              borderBottom: '2px solid #ffffff',
              marginRight: '10px',
            }}
          >
            TERMINAL 1
          </Box>
          <Box style={{ cursor: 'pointer', opacity: 0.7 }}>×</Box>
          <Box
            style={{
              padding: '8px 16px',
              background: 'rgba(255,255,255,0.05)',
              marginLeft: '10px',
              cursor: 'pointer',
            }}
          >
            TERMINAL 2
          </Box>
          <Box style={{ marginLeft: '10px', cursor: 'pointer' }}>+</Box>
        </Flex>
      </Box>

      {/* Terminal Content */}
      <Box style={{ marginBottom: '20px' }}>
        <Box style={{ marginBottom: '15px' }}>
          {Array(50).fill('─').join('')}
        </Box>
        <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
          SCIPNET TERMINAL v4.1.3
        </Box>
        <Box style={{ marginBottom: '15px' }}>
          {Array(50).fill('─').join('')}
        </Box>
      </Box>

      {/* Terminal Output */}
      <Box style={{ marginBottom: '20px', lineHeight: '1.6' }}>
        <Box>SECURE, CONTAIN, PROTECT</Box>
        <Box>SCP FOUNDATION DATABASE NETWORK</Box>
        <Box>Access Time: {new Date().toLocaleString()}</Box>
        <Box style={{ marginTop: '10px' }}>
          Enter &apos;help&apos; for available commands or &apos;access&apos; to
          quickly access SCP files.
        </Box>
        <Box>Example: &apos;access 173&apos; to access SCP-173.</Box>
      </Box>

      {/* Command Prompt */}
      <Box style={{ display: 'flex', alignItems: 'center' }}>
        <Box style={{ marginRight: '10px' }}>admin@scipnet:~$</Box>
        <Box
          style={{
            width: '8px',
            height: '16px',
            background: '#00ff00',
            animation: 'blink 1s infinite',
          }}
        />
      </Box>
    </Box>
  );

  // Facility Management Interface
  const FacilityInterface = () => {
    const [facilityActiveTab, setFacilityActiveTab] =
      React.useState('overview');
    const [selectedRoom, setSelectedRoom] = useLocalState(
      context,
      'facilitySelectedRoom',
      null,
    );
    const [selectedEquipment, setSelectedEquipment] = useLocalState(
      context,
      'facilitySelectedEquipment',
      null,
    );
    const [selectedSystem, setSelectedSystem] = useLocalState(
      context,
      'facilitySelectedSystem',
      null,
    );
    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'facilitySearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'facilityFilterType',
      'all',
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
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
            FACILITY MANAGEMENT
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            ENGINEERING CONTROL
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            FACILITY PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Facility Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            SYSTEM CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <Button
              onClick={() => act('facility_view_status')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              VIEW STATUS
            </Button>
            <Button
              onClick={() => act('facility_save_data')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              SAVE DATA
            </Button>
            <Button
              onClick={() => act('facility_load_data')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              LOAD DATA
            </Button>
            <Button
              onClick={() => act('facility_reset_data')}
              style={{
                background: 'rgba(255,0,0,0.2)',
                border: '1px solid rgba(255,0,0,0.5)',
                color: '#ff6666',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              RESET DATA
            </Button>
            <Button
              onClick={() => act('test_systems')}
              style={{
                background: 'rgba(255,0,255,0.2)',
                border: '1px solid rgba(255,0,255,0.5)',
                color: '#ff66ff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              TEST SYSTEMS
            </Button>
          </Flex>
        </Box>

        {/* Facility Status */}
        <Box style={{ lineHeight: '1.6' }}>
          <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
            FACILITY STATUS:
            <DataStatusIndicator data={facility_data} label="FACILITY" />
          </Box>
          <Box>ROOM STATES: {facility_data?.room_states_count || 0}/50</Box>
          <Box>EQUIPMENT: {facility_data?.equipment_operational || 0}/45</Box>
          <Box>SECURITY: {facility_data?.security_systems_count || 0}/15</Box>
          <Box>
            POWER EFFICIENCY:{' '}
            {facility_data?.power_efficiency
              ? Math.round(facility_data.power_efficiency * 100)
              : 0}
            %
          </Box>
          <Box>
            CONTAINMENT STABILITY: {facility_data?.containment_stability || 0}%
          </Box>
          <Box>FACILITY HEALTH: {facility_data?.facility_health || 0}%</Box>
          <Box>MAINTENANCE LEVEL: {facility_data?.maintenance_level || 0}%</Box>
          <Box>SECURITY LEVEL: {facility_data?.security_level || 0}</Box>
        </Box>

        {/* Facility Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
          }}
        >
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                facilityActiveTab === 'overview' ? '2px solid #66ff66' : 'none',
              color: facilityActiveTab === 'overview' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => setFacilityActiveTab('overview')}
          >
            OVERVIEW
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                facilityActiveTab === 'rooms' ? '2px solid #66ff66' : 'none',
              color: facilityActiveTab === 'rooms' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => setFacilityActiveTab('rooms')}
          >
            ROOMS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                facilityActiveTab === 'equipment'
                  ? '2px solid #66ff66'
                  : 'none',
              color: facilityActiveTab === 'equipment' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => setFacilityActiveTab('equipment')}
          >
            EQUIPMENT
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                facilityActiveTab === 'systems' ? '2px solid #66ff66' : 'none',
              color: facilityActiveTab === 'systems' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => setFacilityActiveTab('systems')}
          >
            SYSTEMS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                facilityActiveTab === 'maintenance'
                  ? '2px solid #66ff66'
                  : 'none',
              color:
                facilityActiveTab === 'maintenance' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => setFacilityActiveTab('maintenance')}
          >
            MAINTENANCE
          </Box>
        </Flex>

        {/* Overview Tab */}
        {facilityActiveTab === 'overview' && (
          <Box>
            <Section title="Facility System Overview">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      FACILITY HEALTH
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {facility_data?.facility_health || 0}%
                    </Box>
                    <ProgressBar
                      value={facility_data?.facility_health || 0}
                      maxValue={100}
                      color={
                        facility_data?.facility_health >= 80
                          ? 'good'
                          : facility_data?.facility_health >= 60
                            ? 'average'
                            : 'bad'
                      }
                    />
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff6666',
                      }}
                    >
                      CONTAINMENT STABILITY
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {facility_data?.containment_stability || 0}%
                    </Box>
                    <ProgressBar
                      value={facility_data?.containment_stability || 0}
                      maxValue={100}
                      color={
                        facility_data?.containment_stability >= 90
                          ? 'good'
                          : facility_data?.containment_stability >= 70
                            ? 'average'
                            : 'bad'
                      }
                    />
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ffff',
                      }}
                    >
                      POWER EFFICIENCY
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {facility_data?.power_efficiency
                        ? Math.round(facility_data.power_efficiency * 100)
                        : 0}
                      %
                    </Box>
                    <ProgressBar
                      value={
                        facility_data?.power_efficiency
                          ? facility_data.power_efficiency * 100
                          : 0
                      }
                      maxValue={100}
                      color={
                        facility_data?.power_efficiency >= 0.8
                          ? 'good'
                          : facility_data?.power_efficiency >= 0.6
                            ? 'average'
                            : 'bad'
                      }
                    />
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ffff66',
                      }}
                    >
                      MAINTENANCE LEVEL
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {facility_data?.maintenance_level || 0}%
                    </Box>
                    <ProgressBar
                      value={facility_data?.maintenance_level || 0}
                      maxValue={100}
                      color={
                        facility_data?.maintenance_level >= 80
                          ? 'good'
                          : facility_data?.maintenance_level >= 60
                            ? 'average'
                            : 'bad'
                      }
                    />
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* Rooms Tab */}
        {facilityActiveTab === 'rooms' && (
          <Box>
            <Section title="Room Management">
              <Table>
                <Table.Row header>
                  <Table.Cell>Room ID</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Security Level</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>ROOM-001</Table.Cell>
                  <Table.Cell>Containment Cell</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      OPERATIONAL
                    </Box>
                  </Table.Cell>
                  <Table.Cell>Level 5</Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      onClick={() => setSelectedRoom('ROOM-001')}
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Equipment Tab */}
        {facilityActiveTab === 'equipment' && (
          <Box>
            <Section title="Equipment Management">
              <Table>
                <Table.Row header>
                  <Table.Cell>Equipment ID</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Efficiency</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>EQ-001</Table.Cell>
                  <Table.Cell>Power Generator</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      OPERATIONAL
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <ProgressBar value={95} maxValue={100} color="good" />
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      onClick={() => setSelectedEquipment('EQ-001')}
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Systems Tab */}
        {facilityActiveTab === 'systems' && (
          <Box>
            <Section title="System Management">
              <Table>
                <Table.Row header>
                  <Table.Cell>System</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Priority</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>Containment Field Generator</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ONLINE
                    </Box>
                  </Table.Cell>
                  <Table.Cell>CRITICAL</Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      color="red"
                      onClick={() =>
                        act('facility_shutdown_system', {
                          system: 'containment',
                        })
                      }
                    >
                      Shutdown
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Maintenance Tab */}
        {facilityActiveTab === 'maintenance' && (
          <Box>
            <Section title="Maintenance Schedule">
              <Table>
                <Table.Row header>
                  <Table.Cell>Task</Table.Cell>
                  <Table.Cell>Priority</Table.Cell>
                  <Table.Cell>Assigned To</Table.Cell>
                  <Table.Cell>Due Date</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>Power Grid Maintenance</Table.Cell>
                  <Table.Cell>HIGH</Table.Cell>
                  <Table.Cell>Engineering Team</Table.Cell>
                  <Table.Cell>2024-01-20</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#ffaa00', fontWeight: 'bold' }}>
                      IN PROGRESS
                    </Box>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Modals */}
        {selectedRoom && (
          <Modal>
            <Section title={`Room Details: ${selectedRoom}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Room:</strong> {selectedRoom}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Operational
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Type:</strong> Facility Room
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Room details will be populated from facility data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedRoom(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedEquipment && (
          <Modal>
            <Section title={`Equipment Details: ${selectedEquipment}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Equipment:</strong> {selectedEquipment}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Operational
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Type:</strong> Facility Equipment
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Equipment details will be populated from facility data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedEquipment(null)}>Close</Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // SCP Management Interface
  const SCPInterface = () => {
    const [scpActiveTab, setScpActiveTab] = React.useState('overview');
    const [selectedSCP, setSelectedSCP] = useLocalState(
      context,
      'scpSelectedSCP',
      null,
    );
    const [selectedBreach, setSelectedBreach] = useLocalState(
      context,
      'scpSelectedBreach',
      null,
    );
    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'scpSearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'scpFilterType',
      'all',
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
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
            SCP CONTAINMENT
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>SECURITY CONTROL</Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            SCP PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* SCP Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            CONTAINMENT CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <Button
              onClick={() => act('scp_view_status')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              VIEW STATUS
            </Button>
            <Button
              onClick={() => act('scp_add_instance')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              ADD SCP
            </Button>
            <Button
              onClick={() => act('scp_add_research')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              ADD RESEARCH
            </Button>
            <Button
              onClick={() => act('scp_save_data')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              SAVE DATA
            </Button>
          </Flex>
        </Box>

        {/* SCP Status */}
        <Box style={{ lineHeight: '1.6' }}>
          <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
            CONTAINMENT STATUS:{' '}
            {scp_data?.active_breaches > 0 ? 'BREACH DETECTED' : 'SECURE'}
            <DataStatusIndicator data={scp_data} label="SCP" />
          </Box>
          {scp_data?.active_breaches > 0 && (
            <Box
              style={{
                color: '#ff6666',
                marginBottom: '10px',
                fontWeight: 'bold',
              }}
            >
              WARNING: {scp_data.active_breaches} ACTIVE BREACH(ES) DETECTED
            </Box>
          )}
          <Box>
            GLOBAL STABILITY: {scp_data?.global_containment_stability || 0}%
          </Box>
          <Box>RESEARCH PROGRESS: {scp_data?.research_progress || 0}%</Box>
          <Box>SCP INSTANCES: {scp_data?.scp_instances_count || 0}</Box>
          <Box>
            CONTAINMENT EFFECTIVENESS:{' '}
            {scp_data?.containment_effectiveness
              ? Math.round(scp_data.containment_effectiveness * 100)
              : 0}
            %
          </Box>
        </Box>

        {/* SCP Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
          }}
        >
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                scpActiveTab === 'overview' ? '2px solid #ff6666' : 'none',
              color: scpActiveTab === 'overview' ? '#ff6666' : '#ffffff',
            }}
            onClick={() => setScpActiveTab('overview')}
          >
            OVERVIEW
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                scpActiveTab === 'instances' ? '2px solid #ff6666' : 'none',
              color: scpActiveTab === 'instances' ? '#ff6666' : '#ffffff',
            }}
            onClick={() => setScpActiveTab('instances')}
          >
            INSTANCES
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                scpActiveTab === 'breaches' ? '2px solid #ff6666' : 'none',
              color: scpActiveTab === 'breaches' ? '#ff6666' : '#ffffff',
            }}
            onClick={() => setScpActiveTab('breaches')}
          >
            BREACHES
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                scpActiveTab === 'research' ? '2px solid #ff6666' : 'none',
              color: scpActiveTab === 'research' ? '#ff6666' : '#ffffff',
            }}
            onClick={() => setScpActiveTab('research')}
          >
            RESEARCH
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                scpActiveTab === 'protocols' ? '2px solid #ff6666' : 'none',
              color: scpActiveTab === 'protocols' ? '#ff6666' : '#ffffff',
            }}
            onClick={() => setScpActiveTab('protocols')}
          >
            PROTOCOLS
          </Box>
        </Flex>

        {/* Overview Tab */}
        {scpActiveTab === 'overview' && (
          <Box>
            <Section title="SCP Containment Overview">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff6666',
                      }}
                    >
                      CONTAINMENT STABILITY
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {scp_data?.global_containment_stability || 0}%
                    </Box>
                    <ProgressBar
                      value={scp_data?.global_containment_stability || 0}
                      maxValue={100}
                      color={
                        scp_data?.global_containment_stability >= 90
                          ? 'good'
                          : scp_data?.global_containment_stability >= 70
                            ? 'average'
                            : 'bad'
                      }
                    />
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff6666',
                      }}
                    >
                      ACTIVE BREACHES
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {scp_data?.active_breaches || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      {scp_data?.active_breaches > 0 ? 'CRITICAL' : 'SECURE'}
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ffff',
                      }}
                    >
                      SCP INSTANCES
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {scp_data?.scp_instances_count || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Contained
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ffff66',
                      }}
                    >
                      RESEARCH PROGRESS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {scp_data?.research_progress || 0}%
                    </Box>
                    <ProgressBar
                      value={scp_data?.research_progress || 0}
                      maxValue={100}
                      color={
                        scp_data?.research_progress >= 80
                          ? 'good'
                          : scp_data?.research_progress >= 50
                            ? 'average'
                            : 'bad'
                      }
                    />
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* Instances Tab */}
        {scpActiveTab === 'instances' && (
          <Box>
            <Section title="SCP Instances">
              <Box style={{ marginBottom: '15px' }}>
                <Flex style={{ gap: '10px', marginBottom: '10px' }}>
                  <Box style={{ flex: 1 }}>
                    <input
                      type="text"
                      placeholder="Search SCPs..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    />
                  </Box>
                  <Box>
                    <select
                      value={filterType}
                      onChange={(e) => setFilterType(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="all">All SCPs</option>
                      <option value="safe">Safe</option>
                      <option value="euclid">Euclid</option>
                      <option value="keter">Keter</option>
                      <option value="thaumiel">Thaumiel</option>
                    </select>
                  </Box>
                  <Button
                    onClick={() => act('scp_add_instance')}
                    icon="plus"
                    size="small"
                    color="green"
                  >
                    Add SCP
                  </Button>
                </Flex>
              </Box>

              <Table>
                <Table.Row header>
                  <Table.Cell>SCP ID</Table.Cell>
                  <Table.Cell>Object Class</Table.Cell>
                  <Table.Cell>Containment Status</Table.Cell>
                  <Table.Cell>Location</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>SCP-173</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#ffaa00', fontWeight: 'bold' }}>
                      EUCLID
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      CONTAINED
                    </Box>
                  </Table.Cell>
                  <Table.Cell>Containment Cell A-1</Table.Cell>
                  <Table.Cell>
                    <Flex style={{ gap: '5px' }}>
                      <Button
                        size="small"
                        onClick={() => setSelectedSCP('SCP-173')}
                      >
                        View
                      </Button>
                      <Button
                        size="small"
                        color="blue"
                        onClick={() =>
                          act('scp_edit_instance', { scp: 'SCP-173' })
                        }
                      >
                        Edit
                      </Button>
                    </Flex>
                  </Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>SCP-096</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#ff6666', fontWeight: 'bold' }}>
                      KETER
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      CONTAINED
                    </Box>
                  </Table.Cell>
                  <Table.Cell>Containment Cell B-3</Table.Cell>
                  <Table.Cell>
                    <Flex style={{ gap: '5px' }}>
                      <Button
                        size="small"
                        onClick={() => setSelectedSCP('SCP-096')}
                      >
                        View
                      </Button>
                      <Button
                        size="small"
                        color="blue"
                        onClick={() =>
                          act('scp_edit_instance', { scp: 'SCP-096' })
                        }
                      >
                        Edit
                      </Button>
                    </Flex>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Breaches Tab */}
        {scpActiveTab === 'breaches' && (
          <Box>
            <Section title="Containment Breaches">
              <Table>
                <Table.Row header>
                  <Table.Cell>Breach ID</Table.Cell>
                  <Table.Cell>SCP Involved</Table.Cell>
                  <Table.Cell>Severity</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {scp_data?.active_breaches > 0 ? (
                  <Table.Row>
                    <Table.Cell>BR-001</Table.Cell>
                    <Table.Cell>SCP-173</Table.Cell>
                    <Table.Cell>
                      <Box style={{ color: '#ff6666', fontWeight: 'bold' }}>
                        CRITICAL
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box style={{ color: '#ffaa00', fontWeight: 'bold' }}>
                        ACTIVE
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        size="small"
                        color="red"
                        onClick={() => setSelectedBreach('BR-001')}
                      >
                        Respond
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={5}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No active breaches detected. All SCPs are properly
                      contained.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Research Tab */}
        {scpActiveTab === 'research' && (
          <Box>
            <Section title="SCP Research Projects">
              <Table>
                <Table.Row header>
                  <Table.Cell>Project ID</Table.Cell>
                  <Table.Cell>SCP Subject</Table.Cell>
                  <Table.Cell>Research Type</Table.Cell>
                  <Table.Cell>Progress</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>RES-001</Table.Cell>
                  <Table.Cell>SCP-173</Table.Cell>
                  <Table.Cell>Behavioral Analysis</Table.Cell>
                  <Table.Cell>
                    <ProgressBar value={75} maxValue={100} color="good" />
                  </Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ONGOING
                    </Box>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Protocols Tab */}
        {scpActiveTab === 'protocols' && (
          <Box>
            <Section title="Containment Protocols">
              <Table>
                <Table.Row header>
                  <Table.Cell>Protocol ID</Table.Cell>
                  <Table.Cell>SCP Target</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>PROT-173</Table.Cell>
                  <Table.Cell>SCP-173</Table.Cell>
                  <Table.Cell>Standard Containment</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ACTIVE
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      color="blue"
                      onClick={() =>
                        act('scp_view_protocol', { protocol: 'PROT-173' })
                      }
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Modals */}
        {selectedSCP && (
          <Modal>
            <Section title={`SCP Details: ${selectedSCP}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>SCP:</strong> {selectedSCP}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Contained
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Class:</strong> Safe
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  SCP details will be populated from containment data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedSCP(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedBreach && (
          <Modal>
            <Section title={`Breach Response: ${selectedBreach}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Breach:</strong> {selectedBreach}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Contained
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Response Time:</strong> Immediate
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Breach response details will be populated from SCP data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedBreach(null)}>Close</Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // Technology Management Interface
  const TechnologyInterface = () => {
    const [techActiveTab, setTechActiveTab] = React.useState('overview');
    const [selectedProject, setSelectedProject] = useLocalState(
      context,
      'techSelectedProject',
      null,
    );
    const [selectedTechnology, setSelectedTechnology] = useLocalState(
      context,
      'techSelectedTechnology',
      null,
    );
    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'techSearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'techFilterType',
      'all',
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
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
            TECHNOLOGY RESEARCH
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>RESEARCH CONTROL</Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            TECHNOLOGY PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Technology Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            RESEARCH CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <Button
              onClick={() => act('technology_view_status')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              VIEW STATUS
            </Button>
            <Button
              onClick={() => act('technology_add_project')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              ADD PROJECT
            </Button>
            <Button
              onClick={() => act('technology_add_tech')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              ADD TECHNOLOGY
            </Button>
            <Button
              onClick={() => act('technology_save_data')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              SAVE DATA
            </Button>
          </Flex>
        </Box>

        {/* Technology Status */}
        <Box style={{ lineHeight: '1.6' }}>
          <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
            TECHNOLOGY STATUS:
            <DataStatusIndicator data={technology_data} label="TECH" />
          </Box>
          <Box>TECHNOLOGY LEVEL: {technology_data?.technology_level || 0}</Box>
          <Box>
            RESEARCH PROGRESS: {technology_data?.research_progress || 0}%
          </Box>
          <Box>INNOVATION SCORE: {technology_data?.innovation_score || 0}</Box>
          <Box>
            RESEARCH BUDGET: $
            {technology_data?.research_budget
              ? technology_data.research_budget.toLocaleString()
              : '0'}
          </Box>
          <Box>
            RESEARCH EFFICIENCY:{' '}
            {technology_data?.research_efficiency
              ? Math.round(technology_data.research_efficiency * 100)
              : 0}
            %
          </Box>
        </Box>

        {/* Technology Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
          }}
        >
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                techActiveTab === 'overview' ? '2px solid #66ffff' : 'none',
              color: techActiveTab === 'overview' ? '#66ffff' : '#ffffff',
            }}
            onClick={() => setTechActiveTab('overview')}
          >
            OVERVIEW
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                techActiveTab === 'projects' ? '2px solid #66ffff' : 'none',
              color: techActiveTab === 'projects' ? '#66ffff' : '#ffffff',
            }}
            onClick={() => setTechActiveTab('projects')}
          >
            PROJECTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                techActiveTab === 'technologies' ? '2px solid #66ffff' : 'none',
              color: techActiveTab === 'technologies' ? '#66ffff' : '#ffffff',
            }}
            onClick={() => setTechActiveTab('technologies')}
          >
            TECHNOLOGIES
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                techActiveTab === 'patents' ? '2px solid #66ffff' : 'none',
              color: techActiveTab === 'patents' ? '#66ffff' : '#ffffff',
            }}
            onClick={() => setTechActiveTab('patents')}
          >
            PATENTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                techActiveTab === 'budget' ? '2px solid #66ffff' : 'none',
              color: techActiveTab === 'budget' ? '#66ffff' : '#ffffff',
            }}
            onClick={() => setTechActiveTab('budget')}
          >
            BUDGET
          </Box>
        </Flex>

        {/* Overview Tab */}
        {techActiveTab === 'overview' && (
          <Box>
            <Section title="Technology Research Overview">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ffff',
                      }}
                    >
                      RESEARCH PROGRESS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {technology_data?.research_progress || 0}%
                    </Box>
                    <ProgressBar
                      value={technology_data?.research_progress || 0}
                      maxValue={100}
                      color={
                        technology_data?.research_progress >= 80
                          ? 'good'
                          : technology_data?.research_progress >= 50
                            ? 'average'
                            : 'bad'
                      }
                    />
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ffff66',
                      }}
                    >
                      INNOVATION SCORE
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {technology_data?.innovation_score || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>Points</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      RESEARCH BUDGET
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      $
                      {technology_data?.research_budget
                        ? technology_data.research_budget.toLocaleString()
                        : '0'}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Available
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff66ff',
                      }}
                    >
                      TECHNOLOGY LEVEL
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {technology_data?.technology_level || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Current Tier
                    </Box>
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* Projects Tab */}
        {techActiveTab === 'projects' && (
          <Box>
            <Section title="Research Projects">
              <Box style={{ marginBottom: '15px' }}>
                <Flex style={{ gap: '10px', marginBottom: '10px' }}>
                  <Box style={{ flex: 1 }}>
                    <input
                      type="text"
                      placeholder="Search projects..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    />
                  </Box>
                  <Box>
                    <select
                      value={filterType}
                      onChange={(e) => setFilterType(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="all">All Projects</option>
                      <option value="active">Active</option>
                      <option value="completed">Completed</option>
                      <option value="paused">Paused</option>
                    </select>
                  </Box>
                  <Button
                    onClick={() => act('technology_add_project')}
                    icon="plus"
                    size="small"
                    color="green"
                  >
                    Add Project
                  </Button>
                </Flex>
              </Box>

              <Table>
                <Table.Row header>
                  <Table.Cell>Project ID</Table.Cell>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Category</Table.Cell>
                  <Table.Cell>Progress</Table.Cell>
                  <Table.Cell>Budget</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>PROJ-001</Table.Cell>
                  <Table.Cell>Advanced Containment Field</Table.Cell>
                  <Table.Cell>Containment Tech</Table.Cell>
                  <Table.Cell>
                    <ProgressBar value={65} maxValue={100} color="good" />
                  </Table.Cell>
                  <Table.Cell>$250,000</Table.Cell>
                  <Table.Cell>
                    <Flex style={{ gap: '5px' }}>
                      <Button
                        size="small"
                        onClick={() => setSelectedProject('PROJ-001')}
                      >
                        View
                      </Button>
                      <Button
                        size="small"
                        color="blue"
                        onClick={() =>
                          act('technology_edit_project', {
                            project: 'PROJ-001',
                          })
                        }
                      >
                        Edit
                      </Button>
                    </Flex>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Technologies Tab */}
        {techActiveTab === 'technologies' && (
          <Box>
            <Section title="Developed Technologies">
              <Table>
                <Table.Row header>
                  <Table.Cell>Technology ID</Table.Cell>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>TECH-001</Table.Cell>
                  <Table.Cell>Quantum Containment Field</Table.Cell>
                  <Table.Cell>Containment</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      DEPLOYED
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      onClick={() => setSelectedTechnology('TECH-001')}
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Patents Tab */}
        {techActiveTab === 'patents' && (
          <Box>
            <Section title="Patent Portfolio">
              <Table>
                <Table.Row header>
                  <Table.Cell>Patent ID</Table.Cell>
                  <Table.Cell>Title</Table.Cell>
                  <Table.Cell>Filing Date</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>PAT-001</Table.Cell>
                  <Table.Cell>Quantum Containment Method</Table.Cell>
                  <Table.Cell>2024-01-15</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      APPROVED
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      color="blue"
                      onClick={() =>
                        act('technology_view_patent', { patent: 'PAT-001' })
                      }
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Budget Tab */}
        {techActiveTab === 'budget' && (
          <Box>
            <Section title="Research Budget Management">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      TOTAL BUDGET
                    </Box>
                    <Box style={{ fontSize: '20px' }}>
                      $
                      {technology_data?.research_budget
                        ? technology_data.research_budget.toLocaleString()
                        : '0'}
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        color: '#ff6666',
                      }}
                    >
                      SPENT THIS MONTH
                    </Box>
                    <Box style={{ fontSize: '20px' }}>$125,000</Box>
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* Modals */}
        {selectedProject && (
          <Modal>
            <Section title={`Project Details: ${selectedProject}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Project:</strong> {selectedProject}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Active
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Progress:</strong> 0%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Project details will be populated from technology data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedProject(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedTechnology && (
          <Modal>
            <Section title={`Technology Details: ${selectedTechnology}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Technology:</strong> {selectedTechnology}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Active
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Level:</strong> 1
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Technology details will be populated from technology data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedTechnology(null)}>Close</Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // Player Data Management Interface
  const PlayerInterface = () => {
    const [playerActiveTab, setPlayerActiveTab] = React.useState('overview');
    const [selectedPlayer, setSelectedPlayer] = useLocalState(
      context,
      'playerSelectedPlayer',
      null,
    );
    const [selectedFaction, setSelectedFaction] = useLocalState(
      context,
      'playerSelectedFaction',
      null,
    );
    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'playerSearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'playerFilterType',
      'all',
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
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
            PLAYER DATA
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            PROGRESSION CONTROL
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            PLAYER PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Player Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            PLAYER CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <Button
              onClick={() => act('player_view_data')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              VIEW DATA
            </Button>
            <Button
              onClick={() => act('player_export_data')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              EXPORT DATA
            </Button>
            <Button
              onClick={() => act('player_reset_progress')}
              style={{
                background: 'rgba(255,0,0,0.2)',
                border: '1px solid rgba(255,0,0,0.5)',
                color: '#ff6666',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              RESET PROGRESS
            </Button>
          </Flex>
        </Box>

        {/* Player Status */}
        <Box style={{ lineHeight: '1.6' }}>
          <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
            PLAYER STATUS:
            <DataStatusIndicator data={player_data} label="PLAYER" />
          </Box>
          <Box>ACTIVE PLAYERS: {player_data?.active_players || 0}</Box>
          <Box>TOTAL EXPERIENCE: {player_data?.total_experience || 0}</Box>
          <Box>
            AVERAGE RANK:{' '}
            {player_data?.average_rank
              ? player_data.average_rank.toFixed(1)
              : '0.0'}
          </Box>
          <Box>
            ACHIEVEMENTS UNLOCKED: {player_data?.achievements_unlocked || 0}
          </Box>
          <Box>
            DATABASE STATUS:{' '}
            {system_status === 'operational' ? 'CONNECTED' : 'DISCONNECTED'}
          </Box>
        </Box>

        {/* Player Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
          }}
        >
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                playerActiveTab === 'overview' ? '2px solid #ffff66' : 'none',
              color: playerActiveTab === 'overview' ? '#ffff66' : '#ffffff',
            }}
            onClick={() => setPlayerActiveTab('overview')}
          >
            OVERVIEW
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                playerActiveTab === 'players' ? '2px solid #ffff66' : 'none',
              color: playerActiveTab === 'players' ? '#ffff66' : '#ffffff',
            }}
            onClick={() => setPlayerActiveTab('players')}
          >
            PLAYERS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                playerActiveTab === 'factions' ? '2px solid #ffff66' : 'none',
              color: playerActiveTab === 'factions' ? '#ffff66' : '#ffffff',
            }}
            onClick={() => setPlayerActiveTab('factions')}
          >
            FACTIONS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                playerActiveTab === 'achievements'
                  ? '2px solid #ffff66'
                  : 'none',
              color: playerActiveTab === 'achievements' ? '#ffff66' : '#ffffff',
            }}
            onClick={() => setPlayerActiveTab('achievements')}
          >
            ACHIEVEMENTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                playerActiveTab === 'analytics' ? '2px solid #ffff66' : 'none',
              color: playerActiveTab === 'analytics' ? '#ffff66' : '#ffffff',
            }}
            onClick={() => setPlayerActiveTab('analytics')}
          >
            ANALYTICS
          </Box>
        </Flex>

        {/* Overview Tab */}
        {playerActiveTab === 'overview' && (
          <Box>
            <Section title="Player Progression Overview">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ffff66',
                      }}
                    >
                      ACTIVE PLAYERS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {player_data?.active_players || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>Online</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ffff',
                      }}
                    >
                      TOTAL EXPERIENCE
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {player_data?.total_experience || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>Points</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff66ff',
                      }}
                    >
                      AVERAGE RANK
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {player_data?.average_rank
                        ? player_data.average_rank.toFixed(1)
                        : '0.0'}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>Level</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      ACHIEVEMENTS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {player_data?.achievements_unlocked || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Unlocked
                    </Box>
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* Players Tab */}
        {playerActiveTab === 'players' && (
          <Box>
            <Section title="Player Management">
              <Box style={{ marginBottom: '15px' }}>
                <Flex style={{ gap: '10px', marginBottom: '10px' }}>
                  <Box style={{ flex: 1 }}>
                    <input
                      type="text"
                      placeholder="Search players..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    />
                  </Box>
                  <Box>
                    <select
                      value={filterType}
                      onChange={(e) => setFilterType(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="all">All Players</option>
                      <option value="online">Online</option>
                      <option value="offline">Offline</option>
                      <option value="admin">Administrators</option>
                    </select>
                  </Box>
                  <Button
                    onClick={() => act('player_add_player')}
                    icon="plus"
                    size="small"
                    color="green"
                  >
                    Add Player
                  </Button>
                </Flex>
              </Box>

              <Table>
                <Table.Row header>
                  <Table.Cell>Player ID</Table.Cell>
                  <Table.Cell>Username</Table.Cell>
                  <Table.Cell>Rank</Table.Cell>
                  <Table.Cell>Faction</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>PLAYER-001</Table.Cell>
                  <Table.Cell>DrSmith</Table.Cell>
                  <Table.Cell>Senior Researcher</Table.Cell>
                  <Table.Cell>Foundation</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ONLINE
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Flex style={{ gap: '5px' }}>
                      <Button
                        size="small"
                        onClick={() => setSelectedPlayer('PLAYER-001')}
                      >
                        View
                      </Button>
                      <Button
                        size="small"
                        color="blue"
                        onClick={() =>
                          act('player_edit_player', { player: 'PLAYER-001' })
                        }
                      >
                        Edit
                      </Button>
                    </Flex>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Factions Tab */}
        {playerActiveTab === 'factions' && (
          <Box>
            <Section title="Faction Management">
              <Table>
                <Table.Row header>
                  <Table.Cell>Faction ID</Table.Cell>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Members</Table.Cell>
                  <Table.Cell>Influence</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>FAC-001</Table.Cell>
                  <Table.Cell>SCP Foundation</Table.Cell>
                  <Table.Cell>45</Table.Cell>
                  <Table.Cell>
                    <ProgressBar value={85} maxValue={100} color="good" />
                  </Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ACTIVE
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      onClick={() => setSelectedFaction('FAC-001')}
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Achievements Tab */}
        {playerActiveTab === 'achievements' && (
          <Box>
            <Section title="Achievement System">
              <Table>
                <Table.Row header>
                  <Table.Cell>Achievement ID</Table.Cell>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Description</Table.Cell>
                  <Table.Cell>Unlocked By</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>ACH-001</Table.Cell>
                  <Table.Cell>First Containment</Table.Cell>
                  <Table.Cell>
                    Successfully contain an SCP for the first time
                  </Table.Cell>
                  <Table.Cell>12 players</Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      color="blue"
                      onClick={() =>
                        act('player_view_achievement', {
                          achievement: 'ACH-001',
                        })
                      }
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Analytics Tab */}
        {playerActiveTab === 'analytics' && (
          <Box>
            <Section title="Player Analytics">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        color: '#ff6666',
                      }}
                    >
                      DAILY ACTIVE USERS
                    </Box>
                    <Box style={{ fontSize: '20px' }}>23</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      MONTHLY RETENTION
                    </Box>
                    <Box style={{ fontSize: '20px' }}>78%</Box>
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* Modals */}
        {selectedPlayer && (
          <Modal>
            <Section title={`Player Details: ${selectedPlayer}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Player:</strong> {selectedPlayer}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Online
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Rank:</strong> Staff
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Player details will be populated from player data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedPlayer(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedFaction && (
          <Modal>
            <Section title={`Faction Details: ${selectedFaction}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Faction:</strong> {selectedFaction}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Active
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Members:</strong> 0
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Faction details will be populated from player data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedFaction(null)}>Close</Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // Medical Management Interface
  const MedicalInterface = () => {
    console.log('MedicalInterface: Component is being rendered');
    console.log('MedicalInterface: selectedOutbreak =', selectedOutbreak);

    const [medicalActiveTab, setMedicalActiveTab] = React.useState('overview');
    const [selectedPatient, setSelectedPatient] = React.useState(null);
    const [selectedTreatment, setSelectedTreatment] = React.useState(null);
    const [selectedOutbreak, setSelectedOutbreak] = React.useState(null);
    console.log(
      'MedicalInterface: After useState, selectedOutbreak =',
      selectedOutbreak,
    );
    const [selectedProject, setSelectedProject] = React.useState(null);

    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'medicalSearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'medicalFilterType',
      'all',
    );
    const [sortBy, setSortBy] = useLocalState(context, 'medicalSortBy', 'name');
    const [sortOrder, setSortOrder] = useLocalState(
      context,
      'medicalSortOrder',
      'asc',
    );

    // Don't render the modal if selectedOutbreak is "medical"
    const shouldShowOutbreakModal =
      selectedOutbreak && selectedOutbreak !== 'medical';
    console.log(
      'MedicalInterface: shouldShowOutbreakModal =',
      shouldShowOutbreakModal,
    );
    console.log('MedicalInterface: selectedTreatment =', selectedTreatment);
    console.log('MedicalInterface: selectedPatient =', selectedPatient);
    console.log('MedicalInterface: medicalActiveTab =', medicalActiveTab);

    // Use raw state values directly - no effective value logic
    const effectiveActiveTab = medicalActiveTab;
    const effectiveSelectedOutbreak = selectedOutbreak;
    const effectiveSelectedTreatment = selectedTreatment;
    const effectiveSelectedPatient = selectedPatient;
    const effectiveSelectedProject = selectedProject;

    // Debug logging for sub-tab issues
    console.log('MedicalInterface: effectiveActiveTab =', effectiveActiveTab);
    console.log('MedicalInterface: medicalActiveTab =', medicalActiveTab);

    // No useEffect - handle "medical" values gracefully in render logic

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
        }}
      >
        {/* Debug: Simple test to see if component renders */}
        <Box
          style={{ color: 'yellow', fontSize: '12px', marginBottom: '10px' }}
        >
          MedicalInterface: Component is rendering
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            MEDICAL MANAGEMENT
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            HEALTHCARE CONTROL
          </Box>
        </Box>

        {/* Medical Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
          }}
        >
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                effectiveActiveTab === 'overview'
                  ? '2px solid #66ff66'
                  : 'none',
              color: effectiveActiveTab === 'overview' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => {
              console.log('MedicalInterface: Clicking overview tab');
              setMedicalActiveTab('overview');
            }}
          >
            OVERVIEW
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                effectiveActiveTab === 'patients'
                  ? '2px solid #66ff66'
                  : 'none',
              color: effectiveActiveTab === 'patients' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => {
              console.log('MedicalInterface: Clicking patients tab');
              setMedicalActiveTab('patients');
            }}
          >
            PATIENTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                effectiveActiveTab === 'treatments'
                  ? '2px solid #66ff66'
                  : 'none',
              color:
                effectiveActiveTab === 'treatments' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => {
              console.log('MedicalInterface: Clicking treatments tab');
              setMedicalActiveTab('treatments');
            }}
          >
            TREATMENTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                effectiveActiveTab === 'outbreaks'
                  ? '2px solid #66ff66'
                  : 'none',
              color: effectiveActiveTab === 'outbreaks' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => {
              console.log('MedicalInterface: Clicking outbreaks tab');
              setMedicalActiveTab('outbreaks');
            }}
          >
            OUTBREAKS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                effectiveActiveTab === 'research'
                  ? '2px solid #66ff66'
                  : 'none',
              color: effectiveActiveTab === 'research' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => {
              console.log('MedicalInterface: Clicking research tab');
              setMedicalActiveTab('research');
            }}
          >
            RESEARCH
          </Box>
        </Flex>

        {/* Overview Tab */}
        {effectiveActiveTab === 'overview' && (
          <Box>
            {/* Debug: Overview tab content is rendering */}
            <Box
              style={{
                color: 'yellow',
                fontSize: '12px',
                marginBottom: '10px',
              }}
            >
              MedicalInterface: Overview tab content is rendering
            </Box>
            <Section title="Medical System Overview">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      PATIENTS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {medical_data?.total_patients || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Total Records
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff6666',
                      }}
                    >
                      OUTBREAKS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {medical_data?.active_outbreaks || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>Active</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ffff',
                      }}
                    >
                      TREATMENTS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {medical_data?.total_treatments || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Total Administered
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ffff66',
                      }}
                    >
                      PROJECTS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {medical_data?.research_projects?.length || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Active Research
                    </Box>
                  </Box>
                </Grid.Column>
              </Grid>

              <Box style={{ marginTop: '20px' }}>
                <Box
                  style={{
                    fontSize: '16px',
                    fontWeight: 'bold',
                    marginBottom: '10px',
                  }}
                >
                  System Metrics
                </Box>
                <ProgressBar
                  value={medical_data?.containment_effectiveness || 0}
                  maxValue={1}
                  color="good"
                  style={{ marginBottom: '10px' }}
                >
                  Containment Effectiveness:{' '}
                  {(medical_data?.containment_effectiveness || 0) * 100}%
                </ProgressBar>
                <Box style={{ fontSize: '14px', marginBottom: '5px' }}>
                  Medical Budget: $
                  {medical_data?.medical_budget?.toLocaleString() || 0}
                </Box>
              </Box>

              {/* Advanced Analytics Dashboard */}
              <Box style={{ marginTop: '30px' }}>
                <Box
                  style={{
                    fontSize: '18px',
                    fontWeight: 'bold',
                    marginBottom: '15px',
                    color: '#66ffff',
                  }}
                >
                  📊 ADVANCED ANALYTICS
                </Box>
                <Grid>
                  <Grid.Column size={6}>
                    <Box
                      style={{
                        background: 'rgba(0,255,255,0.1)',
                        padding: '15px',
                        borderRadius: '5px',
                        marginBottom: '10px',
                        border: '1px solid rgba(0,255,255,0.3)',
                      }}
                    >
                      <Box
                        style={{
                          fontSize: '14px',
                          fontWeight: 'bold',
                          color: '#66ffff',
                        }}
                      >
                        PATIENT TRENDS
                      </Box>
                      <Box style={{ fontSize: '12px', marginTop: '5px' }}>
                        <Box>
                          📈 New Patients:{' '}
                          {analytics?.patient_trends?.new_patients || '0%'}
                        </Box>
                        <Box>
                          📉 Discharges:{' '}
                          {analytics?.patient_trends?.discharges || '0%'}
                        </Box>
                        <Box>
                          ⚠️ Critical Cases:{' '}
                          {analytics?.patient_trends?.critical_cases || 0}
                        </Box>
                        <Box>
                          ✅ Recovery Rate:{' '}
                          {analytics?.patient_trends?.recovery_rate || '0%'}
                        </Box>
                      </Box>
                    </Box>
                  </Grid.Column>
                  <Grid.Column size={6}>
                    <Box
                      style={{
                        background: 'rgba(255,0,0,0.1)',
                        padding: '15px',
                        borderRadius: '5px',
                        marginBottom: '10px',
                        border: '1px solid rgba(255,0,0,0.3)',
                      }}
                    >
                      <Box
                        style={{
                          fontSize: '14px',
                          fontWeight: 'bold',
                          color: '#ff6666',
                        }}
                      >
                        OUTBREAK ANALYSIS
                      </Box>
                      <Box style={{ fontSize: '12px', marginTop: '5px' }}>
                        <Box>
                          🦠 Active Outbreaks:{' '}
                          {analytics?.outbreak_analysis?.active_outbreaks || 0}
                        </Box>
                        <Box>
                          🔬 Containment:{' '}
                          {analytics?.outbreak_analysis?.containment_rate ||
                            '0%'}
                        </Box>
                        <Box>
                          💉 Vaccination:{' '}
                          {analytics?.outbreak_analysis?.vaccination_rate ||
                            '0%'}
                        </Box>
                        <Box>
                          🚨 Alert Level:{' '}
                          {analytics?.outbreak_analysis?.alert_level || 'LOW'}
                        </Box>
                      </Box>
                    </Box>
                  </Grid.Column>
                  <Grid.Column size={6}>
                    <Box
                      style={{
                        background: 'rgba(0,255,0,0.1)',
                        padding: '15px',
                        borderRadius: '5px',
                        marginBottom: '10px',
                        border: '1px solid rgba(0,255,0,0.3)',
                      }}
                    >
                      <Box
                        style={{
                          fontSize: '14px',
                          fontWeight: 'bold',
                          color: '#66ff66',
                        }}
                      >
                        TREATMENT EFFICIENCY
                      </Box>
                      <Box style={{ fontSize: '12px', marginTop: '5px' }}>
                        <Box>
                          ⚡ Success Rate:{' '}
                          {analytics?.treatment_efficiency?.success_rate ||
                            '0%'}
                        </Box>
                        <Box>
                          ⏱️ Avg. Response:{' '}
                          {analytics?.treatment_efficiency?.avg_response ||
                            '0min'}
                        </Box>
                        <Box>
                          🏥 Bed Utilization:{' '}
                          {analytics?.treatment_efficiency?.bed_utilization ||
                            '0%'}
                        </Box>
                        <Box>
                          👨‍⚕️ Staff Efficiency:{' '}
                          {analytics?.treatment_efficiency?.staff_efficiency ||
                            '89%'}
                        </Box>
                      </Box>
                    </Box>
                  </Grid.Column>
                  <Grid.Column size={6}>
                    <Box
                      style={{
                        background: 'rgba(255,255,0,0.1)',
                        padding: '15px',
                        borderRadius: '5px',
                        marginBottom: '10px',
                        border: '1px solid rgba(255,255,0,0.3)',
                      }}
                    >
                      <Box
                        style={{
                          fontSize: '14px',
                          fontWeight: 'bold',
                          color: '#ffff66',
                        }}
                      >
                        RESEARCH PROGRESS
                      </Box>
                      <Box style={{ fontSize: '12px', marginTop: '5px' }}>
                        <Box>
                          🔬 Active Projects:{' '}
                          {analytics?.research_progress?.active_projects || 8}
                        </Box>
                        <Box>
                          📊 Completion:{' '}
                          {analytics?.research_progress?.completion_rate ||
                            '67%'}
                        </Box>
                        <Box>
                          💡 Breakthroughs:{' '}
                          {analytics?.research_progress?.breakthroughs || 2}
                        </Box>
                        <Box>
                          📈 Funding:{' '}
                          {analytics?.research_progress?.funding || '$2.4M'}
                        </Box>
                      </Box>
                    </Box>
                  </Grid.Column>
                </Grid>
              </Box>
            </Section>

            <Section title="Quick Actions">
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                <Button
                  onClick={() => act('medical_add_record')}
                  icon="user-plus"
                  color="good"
                >
                  Add Patient
                </Button>
                <Button
                  onClick={() => act('medical_add_treatment')}
                  icon="stethoscope"
                  color="blue"
                >
                  Add Treatment
                </Button>
                <Button
                  onClick={() => act('medical_add_outbreak')}
                  icon="virus"
                  color="bad"
                >
                  Report Outbreak
                </Button>
                <Button
                  onClick={() => act('medical_add_research')}
                  icon="flask"
                  color="purple"
                >
                  New Research
                </Button>
                <Button
                  onClick={() => act('medical_save_data')}
                  icon="save"
                  color="default"
                >
                  Save Data
                </Button>
                <Button
                  onClick={() => act('medical_load_data')}
                  icon="download"
                  color="default"
                >
                  Load Data
                </Button>
              </Flex>
            </Section>
          </Box>
        )}

        {/* Patients Tab */}
        {effectiveActiveTab === 'patients' && (
          <Box>
            {/* Debug: Check patient data */}
            <Box
              style={{
                color: 'yellow',
                fontSize: '12px',
                marginBottom: '10px',
              }}
            >
              Debug: patient_records count ={' '}
              {medical_data?.patient_records?.length || 0}
            </Box>
            <Section title="Patient Records">
              {/* Search and Filter Controls */}
              <Box style={{ marginBottom: '15px' }}>
                <Flex style={{ gap: '10px', marginBottom: '10px' }}>
                  <Box style={{ flex: 1 }}>
                    <input
                      type="text"
                      placeholder="Search patients..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    />
                  </Box>
                  <Box>
                    <select
                      value={filterType}
                      onChange={(e) => setFilterType(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="all">All Patients</option>
                      <option value="active">Active</option>
                      <option value="critical">Critical</option>
                      <option value="recovered">Recovered</option>
                    </select>
                  </Box>
                  <Box>
                    <select
                      value={sortBy}
                      onChange={(e) => setSortBy(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="name">Name</option>
                      <option value="health">Health Rating</option>
                      <option value="date">Last Updated</option>
                    </select>
                  </Box>
                  <Button
                    onClick={() =>
                      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
                    }
                    icon={sortOrder === 'asc' ? 'sort-up' : 'sort-down'}
                    size="small"
                  >
                    {sortOrder.toUpperCase()}
                  </Button>
                </Flex>
                <Flex style={{ gap: '10px' }}>
                  <Button
                    onClick={() => act('medical_export_patients')}
                    icon="download"
                    size="small"
                    color="blue"
                  >
                    Export Data
                  </Button>
                  <Button
                    onClick={() => act('medical_import_patients')}
                    icon="upload"
                    size="small"
                    color="green"
                  >
                    Import Data
                  </Button>
                  <Button
                    onClick={() => act('medical_bulk_actions')}
                    icon="tasks"
                    size="small"
                    color="purple"
                  >
                    Bulk Actions
                  </Button>
                </Flex>
              </Box>

              <Box className="scrollable-table">
                <Table>
                  <Table.Row header>
                    <Table.Cell>
                      <input type="checkbox" style={{ marginRight: '5px' }} />
                    </Table.Cell>
                    <Table.Cell>Name</Table.Cell>
                    <Table.Cell>Blood Type</Table.Cell>
                    <Table.Cell>Health Rating</Table.Cell>
                    <Table.Cell>Status</Table.Cell>
                    <Table.Cell>Last Updated</Table.Cell>
                    <Table.Cell>Actions</Table.Cell>
                  </Table.Row>
                  {/* Real patient data from backend */}
                  {medical_data?.patient_records &&
                  medical_data.patient_records.length > 0 ? (
                    medical_data.patient_records.map((patient, index) => (
                      <Table.Row key={index}>
                        <Table.Cell>
                          <input type="checkbox" />
                        </Table.Cell>
                        <Table.Cell>{patient.name}</Table.Cell>
                        <Table.Cell>{patient.blood_type}</Table.Cell>
                        <Table.Cell>
                          <ProgressBar
                            value={patient.health_rating}
                            maxValue={100}
                            color={
                              patient.health_rating >= 80
                                ? 'good'
                                : patient.health_rating >= 60
                                  ? 'average'
                                  : 'bad'
                            }
                          />
                        </Table.Cell>
                        <Table.Cell>
                          <Box
                            style={{
                              color:
                                patient.health_rating >= 80
                                  ? '#66ff66'
                                  : patient.health_rating >= 60
                                    ? '#ffaa00'
                                    : '#ff6666',
                              fontWeight: 'bold',
                            }}
                          >
                            {patient.health_rating >= 80
                              ? 'ACTIVE'
                              : patient.health_rating >= 60
                                ? 'MONITORING'
                                : 'CRITICAL'}
                          </Box>
                        </Table.Cell>
                        <Table.Cell>{patient.last_updated}</Table.Cell>
                        <Table.Cell>
                          <Flex style={{ gap: '5px' }}>
                            <Button
                              size="small"
                              onClick={() => setSelectedPatient(patient.name)}
                            >
                              View
                            </Button>
                            <Button
                              size="small"
                              color="blue"
                              onClick={() =>
                                act('medical_edit_patient', {
                                  patient: patient.name,
                                })
                              }
                            >
                              Edit
                            </Button>
                          </Flex>
                        </Table.Cell>
                      </Table.Row>
                    ))
                  ) : (
                    <Table.Row>
                      <Table.Cell
                        colSpan={7}
                        style={{ textAlign: 'center', padding: '20px' }}
                      >
                        No patient records found. Add some patients to get
                        started.
                      </Table.Cell>
                    </Table.Row>
                  )}
                </Table>
              </Box>
            </Section>
          </Box>
        )}

        {/* Treatments Tab */}
        {effectiveActiveTab === 'treatments' && (
          <Box>
            <Section title="Treatment Logs">
              <Table>
                <Table.Row header>
                  <Table.Cell>Patient</Table.Cell>
                  <Table.Cell>Treatment Type</Table.Cell>
                  <Table.Cell>Doctor</Table.Cell>
                  <Table.Cell>Success</Table.Cell>
                  <Table.Cell>Date</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real treatment data from backend */}
                {medical_data?.treatment_logs &&
                medical_data.treatment_logs.length > 0 ? (
                  medical_data.treatment_logs.map((treatment, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{treatment.patient}</Table.Cell>
                      <Table.Cell>{treatment.treatment_type}</Table.Cell>
                      <Table.Cell>{treatment.doctor}</Table.Cell>
                      <Table.Cell>
                        <Icon
                          name={treatment.success ? 'check' : 'times'}
                          color={treatment.success ? 'good' : 'bad'}
                        />
                      </Table.Cell>
                      <Table.Cell>{treatment.timestamp}</Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() =>
                            setSelectedTreatment(treatment.patient)
                          }
                        >
                          Details
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No treatment logs found. Add some treatments to get
                      started.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Outbreaks Tab */}
        {effectiveActiveTab === 'outbreaks' && (
          <Box>
            <Section title="Disease Outbreaks">
              <Table>
                <Table.Row header>
                  <Table.Cell>Disease</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Severity</Table.Cell>
                  <Table.Cell>Affected</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real outbreak data from backend */}
                {medical_data?.outbreak_records &&
                medical_data.outbreak_records.length > 0 ? (
                  medical_data.outbreak_records.map((outbreak, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{outbreak.disease_name}</Table.Cell>
                      <Table.Cell>{outbreak.disease_type}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={outbreak.severity}
                          maxValue={5}
                          color={
                            outbreak.severity >= 4
                              ? 'bad'
                              : outbreak.severity >= 2
                                ? 'average'
                                : 'good'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>{outbreak.affected_count || 0}</Table.Cell>
                      <Table.Cell>
                        <Box
                          style={{
                            color:
                              outbreak.status === 'ACTIVE'
                                ? '#ff6666'
                                : '#66ff66',
                            fontWeight: 'bold',
                          }}
                        >
                          {outbreak.status}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() =>
                            setSelectedOutbreak(outbreak.disease_name)
                          }
                        >
                          Manage
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No outbreak records found. Add some outbreaks to get
                      started.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Research Tab */}
        {effectiveActiveTab === 'research' && (
          <Box>
            {/* Debug: Check research data */}
            <Box
              style={{
                color: 'yellow',
                fontSize: '12px',
                marginBottom: '10px',
              }}
            >
              Debug: research_projects count ={' '}
              {medical_data?.research_projects?.length || 0}
            </Box>
            <Section title="Medical Research Projects">
              <Table>
                <Table.Row header>
                  <Table.Cell>Project Name</Table.Cell>
                  <Table.Cell>Field</Table.Cell>
                  <Table.Cell>Lead Researcher</Table.Cell>
                  <Table.Cell>Progress</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real research data from backend */}
                {medical_data?.research_projects &&
                medical_data.research_projects.length > 0 ? (
                  medical_data.research_projects.map((project, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{project.project_name}</Table.Cell>
                      <Table.Cell>{project.research_field}</Table.Cell>
                      <Table.Cell>{project.lead_researcher}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={project.progress || 0}
                          maxValue={100}
                          color="blue"
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                          {project.status || 'ACTIVE'}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => {
                            console.log(
                              'Setting selectedProject to:',
                              project.project_name,
                            );
                            setSelectedProject(project.project_name);
                          }}
                        >
                          Details
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No research projects found. Add some projects to get
                      started.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Detail Modals */}
        {selectedPatient && selectedPatient !== 'medical' && (
          <Modal>
            <Section title={`Patient Details: ${selectedPatient}`}>
              <Box>
                {medical_data?.patient_records?.find(
                  (patient) => patient.name === selectedPatient,
                ) ? (
                  <Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Name:</strong> {selectedPatient}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Blood Type:</strong>{' '}
                      {medical_data.patient_records.find(
                        (patient) => patient.name === selectedPatient,
                      )?.blood_type || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Health Rating:</strong>{' '}
                      {medical_data.patient_records.find(
                        (patient) => patient.name === selectedPatient,
                      )?.health_rating || 0}
                      /100
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Current Conditions:</strong>{' '}
                      {medical_data.patient_records
                        .find((patient) => patient.name === selectedPatient)
                        ?.conditions?.join(', ') || 'None'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Last Updated:</strong>{' '}
                      {medical_data.patient_records.find(
                        (patient) => patient.name === selectedPatient,
                      )?.last_updated || 'Unknown'}
                    </Box>
                  </Box>
                ) : (
                  <Box>Patient information not available.</Box>
                )}
              </Box>
              <Button onClick={() => setSelectedPatient(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedTreatment && selectedTreatment !== 'medical' && (
          <Modal>
            <Section title={`Treatment Details: ${selectedTreatment}`}>
              <Box>
                {medical_data?.treatment_logs?.find(
                  (treatment) => treatment.patient === selectedTreatment,
                ) ? (
                  <Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Patient:</strong> {selectedTreatment}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Treatment Type:</strong>{' '}
                      {medical_data.treatment_logs.find(
                        (treatment) => treatment.patient === selectedTreatment,
                      )?.treatment_type || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Doctor:</strong>{' '}
                      {medical_data.treatment_logs.find(
                        (treatment) => treatment.patient === selectedTreatment,
                      )?.doctor || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Success:</strong>{' '}
                      {medical_data.treatment_logs.find(
                        (treatment) => treatment.patient === selectedTreatment,
                      )?.success
                        ? 'Yes'
                        : 'No'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Notes:</strong>{' '}
                      {medical_data.treatment_logs.find(
                        (treatment) => treatment.patient === selectedTreatment,
                      )?.notes || 'No notes available'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Timestamp:</strong>{' '}
                      {medical_data.treatment_logs.find(
                        (treatment) => treatment.patient === selectedTreatment,
                      )?.timestamp || 'Unknown'}
                    </Box>
                  </Box>
                ) : (
                  <Box>Treatment information not available.</Box>
                )}
              </Box>
              <Button onClick={() => setSelectedTreatment(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {shouldShowOutbreakModal && (
          <Modal>
            <Section title={`Outbreak Management: ${selectedOutbreak}`}>
              {/* Debug info */}
              <Box
                style={{
                  color: 'yellow',
                  fontSize: '12px',
                  marginBottom: '10px',
                }}
              >
                Debug: selectedOutbreak = &quot;{selectedOutbreak}&quot;
              </Box>
              <Box>
                {medical_data?.outbreak_records?.find(
                  (outbreak) => outbreak.disease_name === selectedOutbreak,
                ) ? (
                  <Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Disease:</strong> {selectedOutbreak}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Type:</strong>{' '}
                      {medical_data.outbreak_records.find(
                        (outbreak) =>
                          outbreak.disease_name === selectedOutbreak,
                      )?.disease_type || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Severity:</strong>{' '}
                      {medical_data.outbreak_records.find(
                        (outbreak) =>
                          outbreak.disease_name === selectedOutbreak,
                      )?.severity || 0}
                      /5
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Status:</strong>{' '}
                      {medical_data.outbreak_records.find(
                        (outbreak) =>
                          outbreak.disease_name === selectedOutbreak,
                      )?.status || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Start Time:</strong>{' '}
                      {medical_data.outbreak_records.find(
                        (outbreak) =>
                          outbreak.disease_name === selectedOutbreak,
                      )?.start_time || 'Unknown'}
                    </Box>
                  </Box>
                ) : (
                  <Box>Outbreak information not available.</Box>
                )}
              </Box>
              <Button onClick={() => setSelectedOutbreak(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedProject && selectedProject !== 'medical' && (
          <Modal>
            <Section title={`Research Project: ${selectedProject}`}>
              <Box>
                {/* Debug info */}
                <Box
                  style={{
                    color: 'yellow',
                    fontSize: '12px',
                    marginBottom: '10px',
                  }}
                >
                  Debug: selectedProject = &quot;{selectedProject}&quot;
                </Box>
                <Box
                  style={{
                    color: 'yellow',
                    fontSize: '12px',
                    marginBottom: '10px',
                  }}
                >
                  Debug: research_projects count ={' '}
                  {medical_data?.research_projects?.length || 0}
                </Box>
                {medical_data?.research_projects?.map((project, index) => (
                  <Box
                    key={index}
                    style={{ color: 'yellow', fontSize: '12px' }}
                  >
                    Debug: project[{index}] = &quot;{project.project_name}&quot;
                  </Box>
                ))}
                {medical_data?.research_projects?.find(
                  (project) => project.project_name === selectedProject,
                ) ? (
                  <Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Project:</strong> {selectedProject}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Description:</strong>{' '}
                      {medical_data.research_projects.find(
                        (project) => project.project_name === selectedProject,
                      )?.project_description || 'No description available'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Field:</strong>{' '}
                      {medical_data.research_projects.find(
                        (project) => project.project_name === selectedProject,
                      )?.research_field || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Lead Researcher:</strong>{' '}
                      {medical_data.research_projects.find(
                        (project) => project.project_name === selectedProject,
                      )?.lead_researcher || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Status:</strong>{' '}
                      {medical_data.research_projects.find(
                        (project) => project.project_name === selectedProject,
                      )?.status || 'Unknown'}
                    </Box>
                  </Box>
                ) : (
                  <Box>Research project information not available.</Box>
                )}
              </Box>
              <Button onClick={() => setSelectedProject(null)}>Close</Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // Security Management Interface
  const SecurityInterface = () => {
    const [securityActiveTab, setSecurityActiveTab] =
      React.useState('overview');
    const [selectedIncident, setSelectedIncident] = useLocalState(
      context,
      'selectedIncident',
      null,
    );
    const [selectedPersonnel, setSelectedPersonnel] = useLocalState(
      context,
      'selectedPersonnel',
      null,
    );
    const [selectedProtocol, setSelectedProtocol] = useLocalState(
      context,
      'selectedProtocol',
      null,
    );
    const [selectedAccess, setSelectedAccess] = useLocalState(
      context,
      'selectedAccess',
      null,
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
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
            SECURITY MANAGEMENT
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>SECURITY CONTROL</Box>
        </Box>

        {/* Security Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
          }}
        >
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                securityActiveTab === 'overview' ? '2px solid #ff6666' : 'none',
              color: securityActiveTab === 'overview' ? '#ff6666' : '#ffffff',
            }}
            onClick={() => setSecurityActiveTab('overview')}
          >
            OVERVIEW
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                securityActiveTab === 'incidents'
                  ? '2px solid #ff6666'
                  : 'none',
              color: securityActiveTab === 'incidents' ? '#ff6666' : '#ffffff',
            }}
            onClick={() => setSecurityActiveTab('incidents')}
          >
            INCIDENTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                securityActiveTab === 'personnel'
                  ? '2px solid #ff6666'
                  : 'none',
              color: securityActiveTab === 'personnel' ? '#ff6666' : '#ffffff',
            }}
            onClick={() => setSecurityActiveTab('personnel')}
          >
            PERSONNEL
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                securityActiveTab === 'protocols'
                  ? '2px solid #ff6666'
                  : 'none',
              color: securityActiveTab === 'protocols' ? '#ff6666' : '#ffffff',
            }}
            onClick={() => setSecurityActiveTab('protocols')}
          >
            PROTOCOLS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                securityActiveTab === 'access' ? '2px solid #ff6666' : 'none',
              color: securityActiveTab === 'access' ? '#ff6666' : '#ffffff',
            }}
            onClick={() => setSecurityActiveTab('access')}
          >
            ACCESS LOGS
          </Box>
        </Flex>

        {/* Overview Tab */}
        {securityActiveTab === 'overview' && (
          <Box>
            <Section title="Security System Overview">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff6666',
                      }}
                    >
                      THREATS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {security_data?.active_threats || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>Active</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff6666',
                      }}
                    >
                      BREACHES
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {security_data?.containment_breaches || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Containment
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ffff66',
                      }}
                    >
                      PERSONNEL
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {security_data?.total_personnel || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Security Staff
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff66ff',
                      }}
                    >
                      INCIDENTS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {security_data?.total_incidents || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Total Reported
                    </Box>
                  </Box>
                </Grid.Column>
              </Grid>

              <Box style={{ marginTop: '20px' }}>
                <Box
                  style={{
                    fontSize: '16px',
                    fontWeight: 'bold',
                    marginBottom: '10px',
                  }}
                >
                  Security Metrics
                </Box>
                <Box style={{ fontSize: '14px', marginBottom: '5px' }}>
                  Unauthorized Access Attempts:{' '}
                  {security_data?.unauthorized_access || 0}
                </Box>
                <Box style={{ fontSize: '14px', marginBottom: '5px' }}>
                  Security Budget: $
                  {security_data?.security_budget?.toLocaleString() || 0}
                </Box>
              </Box>
            </Section>

            <Section title="Quick Actions">
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                <Button
                  onClick={() => act('security_add_incident')}
                  icon="exclamation-triangle"
                  color="bad"
                >
                  Report Incident
                </Button>
                <Button
                  onClick={() => act('security_add_personnel')}
                  icon="user-shield"
                  color="blue"
                >
                  Add Personnel
                </Button>
                <Button
                  onClick={() => act('security_add_protocol')}
                  icon="shield-alt"
                  color="purple"
                >
                  New Protocol
                </Button>
                <Button
                  onClick={() => act('security_add_clearance')}
                  icon="key"
                  color="orange"
                >
                  Clearance Request
                </Button>
                <Button
                  onClick={() => act('security_save_data')}
                  icon="save"
                  color="default"
                >
                  Save Data
                </Button>
                <Button
                  onClick={() => act('security_load_data')}
                  icon="download"
                  color="default"
                >
                  Load Data
                </Button>
              </Flex>
            </Section>
          </Box>
        )}

        {/* Incidents Tab */}
        {securityActiveTab === 'incidents' && (
          <Box>
            <Section title="Security Incidents">
              <Box className="scrollable-table">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Type</Table.Cell>
                    <Table.Cell>Description</Table.Cell>
                    <Table.Cell>Severity</Table.Cell>
                    <Table.Cell>Location</Table.Cell>
                    <Table.Cell>Status</Table.Cell>
                    <Table.Cell>Actions</Table.Cell>
                  </Table.Row>
                  {/* Real incident data from backend */}
                  {security_data?.security_incidents &&
                  security_data.security_incidents.length > 0 ? (
                    security_data.security_incidents.map((incident, index) => (
                      <Table.Row key={index}>
                        <Table.Cell>{incident.type}</Table.Cell>
                        <Table.Cell>{incident.description}</Table.Cell>
                        <Table.Cell>
                          <ProgressBar
                            value={incident.severity}
                            maxValue={5}
                            color={
                              incident.severity >= 4
                                ? 'bad'
                                : incident.severity >= 2
                                  ? 'average'
                                  : 'good'
                            }
                          />
                        </Table.Cell>
                        <Table.Cell>{incident.location}</Table.Cell>
                        <Table.Cell>
                          <Box
                            style={{
                              color:
                                incident.status === 'ACTIVE'
                                  ? '#ff6666'
                                  : incident.status === 'RESOLVED'
                                    ? '#66ff66'
                                    : '#ffaa00',
                              fontWeight: 'bold',
                            }}
                          >
                            {incident.status}
                          </Box>
                        </Table.Cell>
                        <Table.Cell>
                          <Button
                            size="small"
                            onClick={() => setSelectedIncident(incident.type)}
                          >
                            {incident.status === 'ACTIVE' ? 'Manage' : 'View'}
                          </Button>
                        </Table.Cell>
                      </Table.Row>
                    ))
                  ) : (
                    <Table.Row>
                      <Table.Cell
                        colSpan={6}
                        style={{ textAlign: 'center', padding: '20px' }}
                      >
                        No security incidents recorded. All systems secure.
                      </Table.Cell>
                    </Table.Row>
                  )}
                </Table>
              </Box>
            </Section>
          </Box>
        )}

        {/* Personnel Tab */}
        {securityActiveTab === 'personnel' && (
          <Box>
            <Section title="Security Personnel">
              <Table>
                <Table.Row header>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Clearance Level</Table.Cell>
                  <Table.Cell>Security Rating</Table.Cell>
                  <Table.Cell>Incidents</Table.Cell>
                  <Table.Cell>Last Updated</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real security personnel data from backend */}
                {security_data?.security_personnel &&
                security_data.security_personnel.length > 0 ? (
                  security_data.security_personnel.map((personnel, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{personnel.name}</Table.Cell>
                      <Table.Cell>Level {personnel.clearance_level}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={personnel.security_rating}
                          maxValue={100}
                          color={
                            personnel.security_rating >= 80
                              ? 'good'
                              : personnel.security_rating >= 60
                                ? 'average'
                                : 'bad'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>{personnel.incidents_handled}</Table.Cell>
                      <Table.Cell>{personnel.last_updated}</Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => setSelectedPersonnel(personnel.name)}
                        >
                          View
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No security personnel records found.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Protocols Tab */}
        {securityActiveTab === 'protocols' && (
          <Box>
            <Section title="Security Protocols">
              <Table>
                <Table.Row header>
                  <Table.Cell>Protocol Name</Table.Cell>
                  <Table.Cell>Clearance Required</Table.Cell>
                  <Table.Cell>Effectiveness</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real security incidents data from backend */}
                {security_data?.security_incidents &&
                security_data.security_incidents.length > 0 ? (
                  security_data.security_incidents.map((incident, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{incident.type}</Table.Cell>
                      <Table.Cell>Level {incident.severity}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={incident.severity}
                          maxValue={5}
                          color={
                            incident.severity >= 4
                              ? 'bad'
                              : incident.severity >= 2
                                ? 'average'
                                : 'good'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Box
                          style={{
                            color:
                              incident.status === 'RESOLVED'
                                ? '#66ff66'
                                : '#ff6666',
                            fontWeight: 'bold',
                          }}
                        >
                          {incident.status}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => setSelectedProtocol(incident.type)}
                        >
                          Edit
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={5}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No security incidents found.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Access Logs Tab */}
        {securityActiveTab === 'access' && (
          <Box>
            <Section title="Access Logs">
              <Table>
                <Table.Row header>
                  <Table.Cell>Personnel</Table.Cell>
                  <Table.Cell>Access Point</Table.Cell>
                  <Table.Cell>Clearance</Table.Cell>
                  <Table.Cell>Granted</Table.Cell>
                  <Table.Cell>Time</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real access logs data from backend */}
                {security_data?.access_logs &&
                security_data.access_logs.length > 0 ? (
                  security_data.access_logs.map((log, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{log.user}</Table.Cell>
                      <Table.Cell>{log.location}</Table.Cell>
                      <Table.Cell>Level {log.access_type}</Table.Cell>
                      <Table.Cell>
                        <Icon
                          name={log.success ? 'check' : 'times'}
                          color={log.success ? 'good' : 'bad'}
                        />
                      </Table.Cell>
                      <Table.Cell>{log.timestamp}</Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => setSelectedAccess(log.user)}
                        >
                          Details
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No access logs found.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Detail Modals */}
        {selectedIncident && (
          <Modal>
            <Section title={`Incident Details: ${selectedIncident}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Type:</strong> {selectedIncident}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Description:</strong> No description available
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Severity:</strong> 0/5
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Location:</strong> Unknown
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Resolved
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Timestamp:</strong> Never
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Incident details will be populated from security data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedIncident(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedPersonnel && (
          <Modal>
            <Section title={`Personnel Details: ${selectedPersonnel}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Name:</strong> {selectedPersonnel}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Clearance Level:</strong> Level 1
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Security Rating:</strong> 100/100
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Incidents Handled:</strong> 0
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Last Updated:</strong> Never
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Personnel details will be populated from security data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedPersonnel(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedProtocol && (
          <Modal>
            <Section title={`Protocol Details: ${selectedProtocol}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Protocol:</strong> {selectedProtocol}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Active
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Clearance Required:</strong> Level 3
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Description:</strong> Standard security protocol for
                  containment and response procedures.
                </Box>
              </Box>
              <Button onClick={() => setSelectedProtocol(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedAccess && (
          <Modal>
            <Section title={`Access Details: ${selectedAccess}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>User:</strong> {selectedAccess}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> No Access Logs
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Last Activity:</strong> Never
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Access logs will appear here when users interact with security
                  systems.
                </Box>
              </Box>
              <Button
                onClick={() => {
                  console.log(
                    'Closing access modal, setting selectedAccess to null',
                  );
                  setSelectedAccess(null);
                }}
              >
                Close
              </Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // Research Management Interface
  const ResearchInterface = () => {
    const [researchActiveTab, setResearchActiveTab] =
      React.useState('overview');
    const [selectedProject, setSelectedProject] = useLocalState(
      context,
      'researchSelectedProject',
      null,
    );
    const [selectedDiscovery, setSelectedDiscovery] = useLocalState(
      context,
      'researchSelectedDiscovery',
      null,
    );
    const [selectedPublication, setSelectedPublication] = useLocalState(
      context,
      'researchSelectedPublication',
      null,
    );
    const [selectedFacility, setSelectedFacility] = useLocalState(
      context,
      'researchSelectedFacility',
      null,
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
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
            RESEARCH MANAGEMENT
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>RESEARCH CONTROL</Box>
        </Box>

        {/* Research Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
          }}
        >
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                researchActiveTab === 'overview' ? '2px solid #66ffff' : 'none',
              color: researchActiveTab === 'overview' ? '#66ffff' : '#ffffff',
            }}
            onClick={() => setResearchActiveTab('overview')}
          >
            OVERVIEW
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                researchActiveTab === 'projects' ? '2px solid #66ffff' : 'none',
              color: researchActiveTab === 'projects' ? '#66ffff' : '#ffffff',
            }}
            onClick={() => setResearchActiveTab('projects')}
          >
            PROJECTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                researchActiveTab === 'discoveries'
                  ? '2px solid #66ffff'
                  : 'none',
              color:
                researchActiveTab === 'discoveries' ? '#66ffff' : '#ffffff',
            }}
            onClick={() => setResearchActiveTab('discoveries')}
          >
            DISCOVERIES
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                researchActiveTab === 'publications'
                  ? '2px solid #66ffff'
                  : 'none',
              color:
                researchActiveTab === 'publications' ? '#66ffff' : '#ffffff',
            }}
            onClick={() => setResearchActiveTab('publications')}
          >
            PUBLICATIONS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                researchActiveTab === 'facilities'
                  ? '2px solid #66ffff'
                  : 'none',
              color: researchActiveTab === 'facilities' ? '#66ffff' : '#ffffff',
            }}
            onClick={() => setResearchActiveTab('facilities')}
          >
            FACILITIES
          </Box>
        </Flex>

        {/* Overview Tab */}
        {researchActiveTab === 'overview' && (
          <Box>
            <Section title="Research System Overview">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ffff',
                      }}
                    >
                      PROJECTS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {research_data?.total_projects || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>Total</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      COMPLETED
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {research_data?.completed_projects || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Successfully
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ffff66',
                      }}
                    >
                      DISCOVERIES
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {research_data?.discoveries || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Scientific
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff66ff',
                      }}
                    >
                      PUBLICATIONS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {research_data?.publications || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Published
                    </Box>
                  </Box>
                </Grid.Column>
              </Grid>

              <Box style={{ marginTop: '20px' }}>
                <Box
                  style={{
                    fontSize: '16px',
                    fontWeight: 'bold',
                    marginBottom: '10px',
                  }}
                >
                  Research Metrics
                </Box>
                <ProgressBar
                  value={research_data?.research_efficiency || 0}
                  maxValue={1}
                  color="good"
                  style={{ marginBottom: '10px' }}
                >
                  Research Efficiency:{' '}
                  {(research_data?.research_efficiency || 0) * 100}%
                </ProgressBar>
                <Box style={{ fontSize: '14px', marginBottom: '5px' }}>
                  Research Budget: $
                  {research_data?.research_budget?.toLocaleString() || 0}
                </Box>
                <Box style={{ fontSize: '14px', marginBottom: '5px' }}>
                  Active Projects: {research_data?.active_projects || 0}
                </Box>
              </Box>
            </Section>

            <Section title="Quick Actions">
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                <Button
                  onClick={() => act('research_add_project')}
                  icon="flask"
                  color="blue"
                >
                  New Project
                </Button>
                <Button
                  onClick={() => act('research_add_discovery')}
                  icon="lightbulb"
                  color="yellow"
                >
                  Record Discovery
                </Button>
                <Button
                  onClick={() => act('research_add_publication')}
                  icon="book"
                  color="purple"
                >
                  Publish Paper
                </Button>
                <Button
                  onClick={() => act('research_add_facility')}
                  icon="building"
                  color="orange"
                >
                  New Facility
                </Button>
                <Button
                  onClick={() => act('research_save_data')}
                  icon="save"
                  color="default"
                >
                  Save Data
                </Button>
                <Button
                  onClick={() => act('research_load_data')}
                  icon="download"
                  color="default"
                >
                  Load Data
                </Button>
              </Flex>
            </Section>
          </Box>
        )}

        {/* Projects Tab */}
        {researchActiveTab === 'projects' && (
          <Box>
            <Section title="Research Projects">
              <Box className="scrollable-table">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Project Name</Table.Cell>
                    <Table.Cell>Field</Table.Cell>
                    <Table.Cell>Lead Researcher</Table.Cell>
                    <Table.Cell>Progress</Table.Cell>
                    <Table.Cell>Status</Table.Cell>
                    <Table.Cell>Actions</Table.Cell>
                  </Table.Row>
                  {/* Real project data from backend */}
                  {research_data?.research_projects &&
                  research_data.research_projects.length > 0 ? (
                    research_data.research_projects.map((project, index) => (
                      <Table.Row key={index}>
                        <Table.Cell>{project.project_name}</Table.Cell>
                        <Table.Cell>{project.field}</Table.Cell>
                        <Table.Cell>{project.lead_researcher}</Table.Cell>
                        <Table.Cell>
                          <ProgressBar
                            value={project.progress}
                            maxValue={100}
                            color={
                              project.progress >= 80
                                ? 'good'
                                : project.progress >= 50
                                  ? 'blue'
                                  : 'bad'
                            }
                          />
                        </Table.Cell>
                        <Table.Cell>
                          <Box
                            style={{
                              color:
                                project.status === 'COMPLETED'
                                  ? '#66ff66'
                                  : project.status === 'ACTIVE'
                                    ? '#66ffff'
                                    : '#ffaa00',
                              fontWeight: 'bold',
                            }}
                          >
                            {project.status}
                          </Box>
                        </Table.Cell>
                        <Table.Cell>
                          <Button
                            size="small"
                            onClick={() =>
                              setSelectedProject(project.project_name)
                            }
                          >
                            {project.status === 'COMPLETED'
                              ? 'View'
                              : 'Details'}
                          </Button>
                        </Table.Cell>
                      </Table.Row>
                    ))
                  ) : (
                    <Table.Row>
                      <Table.Cell
                        colSpan={6}
                        style={{ textAlign: 'center', padding: '20px' }}
                      >
                        No research projects found. Add some projects to get
                        started.
                      </Table.Cell>
                    </Table.Row>
                  )}
                </Table>
              </Box>
            </Section>
          </Box>
        )}

        {/* Discoveries Tab */}
        {researchActiveTab === 'discoveries' && (
          <Box>
            <Section title="Scientific Discoveries">
              <Table>
                <Table.Row header>
                  <Table.Cell>Discovery Name</Table.Cell>
                  <Table.Cell>Field</Table.Cell>
                  <Table.Cell>Significance</Table.Cell>
                  <Table.Cell>Discoverer</Table.Cell>
                  <Table.Cell>Date</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real scientific discoveries data from backend */}
                {research_data?.scientific_discoveries &&
                research_data.scientific_discoveries.length > 0 ? (
                  research_data.scientific_discoveries.map(
                    (discovery, index) => (
                      <Table.Row key={index}>
                        <Table.Cell>{discovery.discovery_name}</Table.Cell>
                        <Table.Cell>{discovery.field}</Table.Cell>
                        <Table.Cell>
                          <ProgressBar
                            value={discovery.significance}
                            maxValue={5}
                            color={
                              discovery.significance >= 4
                                ? 'bad'
                                : discovery.significance >= 2
                                  ? 'average'
                                  : 'good'
                            }
                          />
                        </Table.Cell>
                        <Table.Cell>{discovery.discoverer}</Table.Cell>
                        <Table.Cell>{discovery.date}</Table.Cell>
                        <Table.Cell>
                          <Button
                            size="small"
                            onClick={() =>
                              setSelectedDiscovery(discovery.discovery_name)
                            }
                          >
                            Details
                          </Button>
                        </Table.Cell>
                      </Table.Row>
                    ),
                  )
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No scientific discoveries found.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Publications Tab */}
        {researchActiveTab === 'publications' && (
          <Box>
            <Section title="Research Publications">
              <Table>
                <Table.Row header>
                  <Table.Cell>Title</Table.Cell>
                  <Table.Cell>Authors</Table.Cell>
                  <Table.Cell>Journal</Table.Cell>
                  <Table.Cell>Impact Factor</Table.Cell>
                  <Table.Cell>Date</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real publications data from backend */}
                {research_data?.publications &&
                research_data.publications.length > 0 ? (
                  research_data.publications.map((publication, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{publication.title}</Table.Cell>
                      <Table.Cell>{publication.authors}</Table.Cell>
                      <Table.Cell>{publication.journal}</Table.Cell>
                      <Table.Cell>{publication.impact_factor}</Table.Cell>
                      <Table.Cell>{publication.date}</Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() =>
                            setSelectedPublication(publication.title)
                          }
                        >
                          View
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No publications found.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Facilities Tab */}
        {researchActiveTab === 'facilities' && (
          <Box>
            <Section title="Research Facilities">
              <Table>
                <Table.Row header>
                  <Table.Cell>Facility Name</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Capacity</Table.Cell>
                  <Table.Cell>Utilization</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real facility data from backend */}
                {facility_data && Object.keys(facility_data).length > 0 ? (
                  <Table.Row>
                    <Table.Cell>Main Facility</Table.Cell>
                    <Table.Cell>Research Complex</Table.Cell>
                    <Table.Cell>
                      {facility_data.room_states_count || 0} Rooms
                    </Table.Cell>
                    <Table.Cell>
                      <ProgressBar
                        value={facility_data.facility_health || 0}
                        maxValue={100}
                        color={
                          (facility_data.facility_health || 0) >= 80
                            ? 'good'
                            : (facility_data.facility_health || 0) >= 60
                              ? 'average'
                              : 'bad'
                        }
                      />
                    </Table.Cell>
                    <Table.Cell>
                      <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                        OPERATIONAL
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        size="small"
                        onClick={() => setSelectedFacility('main_facility')}
                      >
                        Manage
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No facility data available.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Detail Modals */}
        {selectedProject && (
          <Modal>
            <Section title={`Project Details: ${selectedProject}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Project:</strong> {selectedProject}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Active
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Progress:</strong> 0%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Project details will be populated from research data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedProject(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedDiscovery && (
          <Modal>
            <Section title={`Discovery Details: ${selectedDiscovery}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Discovery:</strong> {selectedDiscovery}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Verified
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Date:</strong> {new Date().toLocaleDateString()}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Discovery details will be populated from research data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedDiscovery(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedPublication && (
          <Modal>
            <Section title={`Publication Details: ${selectedPublication}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Publication:</strong> {selectedPublication}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Published
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Date:</strong> {new Date().toLocaleDateString()}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Publication details will be populated from research data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedPublication(null)}>
                Close
              </Button>
            </Section>
          </Modal>
        )}

        {selectedFacility && selectedFacility !== 'research' && (
          <Modal>
            <Section title={`Facility Details: ${selectedFacility}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Facility:</strong> {selectedFacility}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Operational
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Type:</strong> Research Facility
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Facility details will be populated from facility data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedFacility(null)}>Close</Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // Personnel Management Interface
  const PersonnelInterface = () => {
    const [personnelActiveTab, setPersonnelActiveTab] =
      React.useState('overview');
    const [selectedEmployee, setSelectedEmployee] = useLocalState(
      context,
      'personnelSelectedEmployee',
      null,
    );
    const [selectedDepartment, setSelectedDepartment] = useLocalState(
      context,
      'personnelSelectedDepartment',
      null,
    );
    const [selectedTraining, setSelectedTraining] = useLocalState(
      context,
      'personnelSelectedTraining',
      null,
    );
    const [selectedPerformance, setSelectedPerformance] = useLocalState(
      context,
      'personnelSelectedPerformance',
      null,
    );
    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'personnelSearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'personnelFilterType',
      'all',
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
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
            PERSONNEL MANAGEMENT
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            PERSONNEL CONTROL
          </Box>
        </Box>

        {/* Personnel Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
          }}
        >
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                personnelActiveTab === 'overview'
                  ? '2px solid #ffff66'
                  : 'none',
              color: personnelActiveTab === 'overview' ? '#ffff66' : '#ffffff',
            }}
            onClick={() => setPersonnelActiveTab('overview')}
          >
            OVERVIEW
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                personnelActiveTab === 'employees'
                  ? '2px solid #ffff66'
                  : 'none',
              color: personnelActiveTab === 'employees' ? '#ffff66' : '#ffffff',
            }}
            onClick={() => setPersonnelActiveTab('employees')}
          >
            EMPLOYEES
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                personnelActiveTab === 'departments'
                  ? '2px solid #ffff66'
                  : 'none',
              color:
                personnelActiveTab === 'departments' ? '#ffff66' : '#ffffff',
            }}
            onClick={() => setPersonnelActiveTab('departments')}
          >
            DEPARTMENTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                personnelActiveTab === 'training'
                  ? '2px solid #ffff66'
                  : 'none',
              color: personnelActiveTab === 'training' ? '#ffff66' : '#ffffff',
            }}
            onClick={() => setPersonnelActiveTab('training')}
          >
            TRAINING
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                personnelActiveTab === 'performance'
                  ? '2px solid #ffff66'
                  : 'none',
              color:
                personnelActiveTab === 'performance' ? '#ffff66' : '#ffffff',
            }}
            onClick={() => setPersonnelActiveTab('performance')}
          >
            PERFORMANCE
          </Box>
        </Flex>

        {/* Overview Tab */}
        {personnelActiveTab === 'overview' && (
          <Box>
            <Section title="Personnel System Overview">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ffff66',
                      }}
                    >
                      TOTAL STAFF
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {personnel_data?.total_staff || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      All Personnel
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      ACTIVE STAFF
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {personnel_data?.active_staff || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Currently Employed
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff66ff',
                      }}
                    >
                      SATISFACTION
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {personnel_data?.staff_satisfaction || 0}%
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Staff Happiness
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ffff',
                      }}
                    >
                      PERFORMANCE
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {personnel_data?.average_performance || 0}%
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Average Rating
                    </Box>
                  </Box>
                </Grid.Column>
              </Grid>

              <Box style={{ marginTop: '20px' }}>
                <Box
                  style={{
                    fontSize: '16px',
                    fontWeight: 'bold',
                    marginBottom: '10px',
                  }}
                >
                  Personnel Metrics
                </Box>
                <ProgressBar
                  value={personnel_data?.training_completion_rate || 0}
                  maxValue={1}
                  color="good"
                  style={{ marginBottom: '10px' }}
                >
                  Training Completion:{' '}
                  {(personnel_data?.training_completion_rate || 0) * 100}%
                </ProgressBar>
                <Box style={{ fontSize: '14px', marginBottom: '5px' }}>
                  Personnel Budget: $
                  {personnel_data?.personnel_budget?.toLocaleString() || 0}
                </Box>
                <Box style={{ fontSize: '14px', marginBottom: '5px' }}>
                  Turnover Rate: {(personnel_data?.turnover_rate || 0) * 100}%
                </Box>
              </Box>
            </Section>

            <Section title="Quick Actions">
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                <Button
                  onClick={() => act('personnel_add_record')}
                  icon="user-plus"
                  color="good"
                >
                  Add Employee
                </Button>
                <Button
                  onClick={() => act('personnel_add_department')}
                  icon="building"
                  color="blue"
                >
                  New Department
                </Button>
                <Button
                  onClick={() => act('personnel_add_training')}
                  icon="graduation-cap"
                  color="purple"
                >
                  Schedule Training
                </Button>
                <Button
                  onClick={() => act('personnel_add_performance')}
                  icon="chart-line"
                  color="orange"
                >
                  Performance Review
                </Button>
                <Button
                  onClick={() => act('personnel_save_data')}
                  icon="save"
                  color="default"
                >
                  Save Data
                </Button>
                <Button
                  onClick={() => act('personnel_load_data')}
                  icon="download"
                  color="default"
                >
                  Load Data
                </Button>
              </Flex>
            </Section>
          </Box>
        )}

        {/* Employees Tab */}
        {personnelActiveTab === 'employees' && (
          <Box>
            <Section title="Employee Records">
              {/* Search and Filter Controls */}
              <Box style={{ marginBottom: '15px' }}>
                <Flex style={{ gap: '10px', marginBottom: '10px' }}>
                  <Box style={{ flex: 1 }}>
                    <input
                      type="text"
                      placeholder="Search employees..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    />
                  </Box>
                  <Box>
                    <select
                      value={filterType}
                      onChange={(e) => setFilterType(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="all">All Employees</option>
                      <option value="active">Active</option>
                      <option value="resigned">Resigned</option>
                      <option value="promoted">Recently Promoted</option>
                    </select>
                  </Box>
                  <Button
                    onClick={() => act('personnel_export_employees')}
                    icon="download"
                    size="small"
                    color="blue"
                  >
                    Export
                  </Button>
                  <Button
                    onClick={() => act('personnel_bulk_actions')}
                    icon="tasks"
                    size="small"
                    color="purple"
                  >
                    Bulk Actions
                  </Button>
                </Flex>
              </Box>

              <Box className="scrollable-table">
                <Table>
                  <Table.Row header>
                    <Table.Cell>
                      <input type="checkbox" style={{ marginRight: '5px' }} />
                    </Table.Cell>
                    <Table.Cell>Name</Table.Cell>
                    <Table.Cell>Department</Table.Cell>
                    <Table.Cell>Position</Table.Cell>
                    <Table.Cell>Performance</Table.Cell>
                    <Table.Cell>Clearance</Table.Cell>
                    <Table.Cell>Status</Table.Cell>
                    <Table.Cell>Actions</Table.Cell>
                  </Table.Row>
                  {/* Real-time employee data */}
                  {personnel_details?.employees &&
                  personnel_details.employees.length > 0 ? (
                    personnel_details.employees.map((employee, index) => (
                      <Table.Row key={index}>
                        <Table.Cell>
                          <input type="checkbox" />
                        </Table.Cell>
                        <Table.Cell>{employee.name}</Table.Cell>
                        <Table.Cell>{employee.department}</Table.Cell>
                        <Table.Cell>{employee.position}</Table.Cell>
                        <Table.Cell>
                          <ProgressBar
                            value={employee.performance}
                            maxValue={100}
                            color={
                              employee.performance >= 80
                                ? 'good'
                                : employee.performance >= 60
                                  ? 'average'
                                  : 'bad'
                            }
                          />
                        </Table.Cell>
                        <Table.Cell>{employee.clearance}</Table.Cell>
                        <Table.Cell>
                          <Box
                            style={{
                              color:
                                employee.status === 'ACTIVE'
                                  ? '#66ff66'
                                  : employee.status === 'RESIGNED'
                                    ? '#ff6666'
                                    : '#ffaa00',
                              fontWeight: 'bold',
                            }}
                          >
                            {employee.status}
                          </Box>
                        </Table.Cell>
                        <Table.Cell>
                          <Flex style={{ gap: '5px' }}>
                            <Button
                              size="small"
                              onClick={() => setSelectedEmployee(employee.name)}
                            >
                              View
                            </Button>
                            <Button
                              size="small"
                              color="blue"
                              onClick={() =>
                                act('personnel_edit_employee', {
                                  employee: employee.name,
                                })
                              }
                            >
                              Edit
                            </Button>
                            <Button
                              size="small"
                              color="green"
                              onClick={() =>
                                act('personnel_promote_employee', {
                                  employee: employee.name,
                                })
                              }
                            >
                              Promote
                            </Button>
                          </Flex>
                        </Table.Cell>
                      </Table.Row>
                    ))
                  ) : (
                    <Table.Row>
                      <Table.Cell
                        colSpan={8}
                        style={{ textAlign: 'center', padding: '20px' }}
                      >
                        No employee records found. Add some employees to get
                        started.
                      </Table.Cell>
                    </Table.Row>
                  )}
                </Table>
              </Box>
            </Section>
          </Box>
        )}

        {/* Departments Tab */}
        {personnelActiveTab === 'departments' && (
          <Box>
            <Section title="Department Management">
              <Table>
                <Table.Row header>
                  <Table.Cell>Department</Table.Cell>
                  <Table.Cell>Head</Table.Cell>
                  <Table.Cell>Staff Count</Table.Cell>
                  <Table.Cell>Budget</Table.Cell>
                  <Table.Cell>Efficiency</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real department data from backend */}
                {personnel_details?.departments &&
                personnel_details.departments.length > 0 ? (
                  personnel_details.departments.map((dept, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{dept.name}</Table.Cell>
                      <Table.Cell>{dept.head}</Table.Cell>
                      <Table.Cell>{dept.staff_count}</Table.Cell>
                      <Table.Cell>{dept.budget}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={dept.efficiency}
                          maxValue={100}
                          color={
                            dept.efficiency >= 80
                              ? 'good'
                              : dept.efficiency >= 60
                                ? 'average'
                                : 'bad'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => setSelectedDepartment(dept.name)}
                        >
                          Manage
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No department data found. Departments will appear here
                      when created.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Training Tab */}
        {personnelActiveTab === 'training' && (
          <Box>
            <Section title="Training Programs">
              <Table>
                <Table.Row header>
                  <Table.Cell>Program</Table.Cell>
                  <Table.Cell>Instructor</Table.Cell>
                  <Table.Cell>Duration</Table.Cell>
                  <Table.Cell>Completion</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real training data from backend */}
                {personnel_details?.training &&
                personnel_details.training.length > 0 ? (
                  personnel_details.training.map((training, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{training.program}</Table.Cell>
                      <Table.Cell>{training.instructor}</Table.Cell>
                      <Table.Cell>{training.duration}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={training.completion}
                          maxValue={100}
                          color={
                            training.completion >= 80
                              ? 'good'
                              : training.completion >= 60
                                ? 'blue'
                                : 'bad'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Box
                          style={{
                            color:
                              training.status === 'COMPLETED'
                                ? '#66ff66'
                                : training.status === 'IN_PROGRESS'
                                  ? '#66ffff'
                                  : '#ffaa00',
                            fontWeight: 'bold',
                          }}
                        >
                          {training.status}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => setSelectedTraining(training.program)}
                        >
                          Details
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No training programs found. Training programs will appear
                      here when scheduled.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Performance Tab */}
        {personnelActiveTab === 'performance' && (
          <Box>
            <Section title="Performance Reviews">
              <Table>
                <Table.Row header>
                  <Table.Cell>Employee</Table.Cell>
                  <Table.Cell>Reviewer</Table.Cell>
                  <Table.Cell>Rating</Table.Cell>
                  <Table.Cell>Date</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real performance data from backend */}
                {personnel_details?.performance &&
                personnel_details.performance.length > 0 ? (
                  personnel_details.performance.map((review, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{review.employee}</Table.Cell>
                      <Table.Cell>{review.reviewer}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={review.rating}
                          maxValue={100}
                          color={
                            review.rating >= 80
                              ? 'good'
                              : review.rating >= 60
                                ? 'average'
                                : 'bad'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>{review.date}</Table.Cell>
                      <Table.Cell>
                        <Box
                          style={{
                            color:
                              review.status === 'COMPLETED'
                                ? '#66ff66'
                                : review.status === 'PENDING'
                                  ? '#ffaa00'
                                  : '#ff6666',
                            fontWeight: 'bold',
                          }}
                        >
                          {review.status}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() =>
                            setSelectedPerformance(review.employee)
                          }
                        >
                          View
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No performance reviews found. Performance reviews will
                      appear here when conducted.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Detail Modals */}
        {selectedEmployee && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0,0,0,0.8)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Box
              style={{
                background: 'rgba(0,0,0,0.9)',
                border: '1px solid rgba(255,255,255,0.3)',
                borderRadius: '5px',
                padding: '20px',
                minWidth: '400px',
                maxWidth: '600px',
              }}
            >
              <Section title={`Employee Details: ${selectedEmployee}`}>
                <Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Name:</strong> {selectedEmployee}
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Department:</strong> General
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Position:</strong> Staff
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Performance Rating:</strong> 80/100
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Clearance Level:</strong> Level 1
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Status:</strong> Active
                  </Box>
                  <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                    Employee details will be populated from personnel data.
                  </Box>
                </Box>
                <Button
                  onClick={() => {
                    console.log(
                      'Closing employee modal, setting selectedEmployee to null',
                    );
                    console.log('activeTab before close:', activeTab);
                    setSelectedEmployee(null);
                    console.log('activeTab after close:', activeTab);
                  }}
                >
                  Close
                </Button>
              </Section>
            </Box>
          </Box>
        )}

        {selectedDepartment && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0,0,0,0.8)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Box
              style={{
                background: 'rgba(0,0,0,0.9)',
                border: '1px solid rgba(255,255,255,0.3)',
                borderRadius: '5px',
                padding: '20px',
                minWidth: '400px',
                maxWidth: '600px',
              }}
            >
              <Section title={`Department Details: ${selectedDepartment}`}>
                <Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Department:</strong> {selectedDepartment}
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Head:</strong> Department Head
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Staff Count:</strong> 0
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Budget:</strong> $100,000
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Efficiency:</strong> 85%
                  </Box>
                  <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                    Department details will be populated from personnel data.
                  </Box>
                </Box>
                <Button
                  onClick={() => {
                    console.log(
                      'Closing department modal, setting selectedDepartment to null',
                    );
                    setSelectedDepartment(null);
                  }}
                >
                  Close
                </Button>
              </Section>
            </Box>
          </Box>
        )}

        {selectedTraining && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0,0,0,0.8)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Box
              style={{
                background: 'rgba(0,0,0,0.9)',
                border: '1px solid rgba(255,255,255,0.3)',
                borderRadius: '5px',
                padding: '20px',
                minWidth: '400px',
                maxWidth: '600px',
              }}
            >
              <Section title={`Training Details: ${selectedTraining}`}>
                <Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Program:</strong> {selectedTraining}
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Instructor:</strong> Training Instructor
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Duration:</strong> 8 weeks
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Completion:</strong> 0%
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Status:</strong> Not Started
                  </Box>
                  <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                    Training details will be populated from personnel data.
                  </Box>
                </Box>
                <Button
                  onClick={() => {
                    console.log(
                      'Closing training modal, setting selectedTraining to null',
                    );
                    setSelectedTraining(null);
                  }}
                >
                  Close
                </Button>
              </Section>
            </Box>
          </Box>
        )}

        {selectedPerformance && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0,0,0,0.8)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Box
              style={{
                background: 'rgba(0,0,0,0.9)',
                border: '1px solid rgba(255,255,255,0.3)',
                borderRadius: '5px',
                padding: '20px',
                minWidth: '400px',
                maxWidth: '600px',
              }}
            >
              <Section title={`Performance Review: ${selectedPerformance}`}>
                <Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Employee:</strong> {selectedPerformance}
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Reviewer:</strong> Supervisor
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Rating:</strong> 85/100
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Date:</strong> Never
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Status:</strong> Pending
                  </Box>
                  <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                    Performance review details will be populated from personnel
                    data.
                  </Box>
                </Box>
                <Button
                  onClick={() => {
                    console.log(
                      'Closing performance modal, setting selectedPerformance to null',
                    );
                    setSelectedPerformance(null);
                  }}
                >
                  Close
                </Button>
              </Section>
            </Box>
          </Box>
        )}
      </Box>
    );
  };

  // Right side panel
  const SidePanel = () => (
    <Box
      style={{
        position: 'absolute',
        top: '50px',
        right: '20px',
        width: '360px',
        bottom: '20px',
        background: 'rgba(0,0,0,0.7)',
        border: '1px solid rgba(255,255,255,0.2)',
        borderRadius: '5px',
        padding: '20px',
        fontFamily: 'monospace',
        fontSize: '12px',
        color: '#ffffff',
        zIndex: 5,
      }}
    >
      {/* Redacted Information */}
      <Box style={{ marginBottom: '20px' }}>
        <Box style={{ marginBottom: '5px' }}>
          COUNTRY: <span style={{ color: '#ff0000' }}>[REDACTED]</span>
        </Box>
        <Box style={{ marginBottom: '5px' }}>
          REGION: <span style={{ color: '#ff0000' }}>[REDACTED]</span>
        </Box>
        <Box>
          IP ADDRESS: <span style={{ color: '#ff0000' }}>[REDACTED]</span>
        </Box>
      </Box>

      {/* Network Map Placeholder */}
      <Box
        style={{
          width: '100%',
          height: '120px',
          background:
            'linear-gradient(45deg, rgba(255,255,255,0.1) 25%, transparent 25%), linear-gradient(-45deg, rgba(255,255,255,0.1) 25%, transparent 25%), linear-gradient(45deg, transparent 75%, rgba(255,255,255,0.1) 75%), linear-gradient(-45deg, transparent 75%, rgba(255,255,255,0.1) 75%)',
          backgroundSize: '20px 20px',
          backgroundPosition: '0 0, 0 10px, 10px -10px, -10px 0px',
          marginBottom: '20px',
          border: '1px solid rgba(255,255,255,0.2)',
        }}
      />

      {/* SCIPNET Title */}
      <Box
        style={{
          fontSize: '24px',
          fontWeight: 'bold',
          textAlign: 'center',
          marginBottom: '20px',
        }}
      >
        SCIPNET
      </Box>

      {/* System Overview */}
      <Box style={{ marginBottom: '20px' }}>
        <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
          SYSTEM OVERVIEW
        </Box>
        <Box style={{ fontSize: '10px', lineHeight: '1.4' }}>
          <Box>
            FACILITY:{' '}
            <DataStatusIndicator data={facility_data} label="FACILITY" />
          </Box>
          <Box>
            SCP: <DataStatusIndicator data={scp_data} label="SCP" />
          </Box>
          <Box>
            TECHNOLOGY:{' '}
            <DataStatusIndicator data={technology_data} label="TECH" />
          </Box>
          <Box>
            MEDICAL: <DataStatusIndicator data={medical_data} label="MEDICAL" />
          </Box>
          <Box>
            SECURITY:{' '}
            <DataStatusIndicator data={security_data} label="SECURITY" />
          </Box>
          <Box>
            RESEARCH:{' '}
            <DataStatusIndicator data={research_data} label="RESEARCH" />
          </Box>
          <Box>
            PERSONNEL:{' '}
            <DataStatusIndicator data={personnel_data} label="PERSONNEL" />
          </Box>
          <Box>
            PLAYER: <DataStatusIndicator data={player_data} label="PLAYER" />
          </Box>
        </Box>

        {/* Key Metrics Summary */}
        <Box style={{ marginTop: '10px', fontSize: '9px', opacity: 0.8 }}>
          <Box style={{ marginBottom: '5px', fontWeight: 'bold' }}>
            KEY METRICS:
          </Box>
          <Box>ACTIVE THREATS: {security_data?.active_threats || 0}</Box>
          <Box>OUTBREAKS: {medical_data?.active_outbreaks || 0}</Box>
          <Box>BREACHES: {security_data?.containment_breaches || 0}</Box>
          <Box>STAFF: {personnel_data?.active_staff || 0}</Box>
          <Box>PROJECTS: {research_data?.active_projects || 0}</Box>
          <Box>PLAYERS: {player_data?.active_players || 0}</Box>
        </Box>

        {/* Real-time Notifications */}
        <Box style={{ marginTop: '20px' }}>
          <Box
            style={{
              marginBottom: '10px',
              fontWeight: 'bold',
              color: '#ff6666',
            }}
          >
            🚨 LIVE ALERTS
          </Box>
          <Box style={{ fontSize: '8px', lineHeight: '1.3' }}>
            {notifications && notifications.length > 0 ? (
              notifications.map((notification, index) => (
                <Box
                  key={index}
                  style={{
                    background:
                      notification.type === 'CRITICAL'
                        ? 'rgba(255,0,0,0.2)'
                        : notification.type === 'WARNING'
                          ? 'rgba(255,255,0,0.2)'
                          : 'rgba(0,255,0,0.2)',
                    padding: '5px',
                    marginBottom: '5px',
                    border:
                      notification.type === 'CRITICAL'
                        ? '1px solid rgba(255,0,0,0.5)'
                        : notification.type === 'WARNING'
                          ? '1px solid rgba(255,255,0,0.5)'
                          : '1px solid rgba(0,255,0,0.5)',
                    borderRadius: '3px',
                  }}
                >
                  <Box
                    style={{
                      color:
                        notification.type === 'CRITICAL'
                          ? '#ff6666'
                          : notification.type === 'WARNING'
                            ? '#ffff66'
                            : '#66ff66',
                      fontWeight: 'bold',
                    }}
                  >
                    {notification.type === 'CRITICAL'
                      ? '⚠️ CRITICAL'
                      : notification.type === 'WARNING'
                        ? '⚠️ WARNING'
                        : '✅ INFO'}
                  </Box>
                  <Box>{notification.message}</Box>
                  <Box style={{ fontSize: '7px', opacity: '0.7' }}>
                    {notification.time}
                  </Box>
                </Box>
              ))
            ) : (
              <Box
                style={{
                  background: 'rgba(0,255,0,0.2)',
                  padding: '5px',
                  marginBottom: '5px',
                  border: '1px solid rgba(0,255,0,0.5)',
                  borderRadius: '3px',
                }}
              >
                <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                  ✅ INFO
                </Box>
                <Box>All systems operational</Box>
                <Box style={{ fontSize: '7px', opacity: '0.7' }}>
                  No recent alerts
                </Box>
              </Box>
            )}
          </Box>
        </Box>
      </Box>

      {/* Hume Meter */}
      <Box style={{ marginBottom: '20px' }}>
        <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
          HUME METER
        </Box>
        <Flex align="flex-end" style={{ height: '40px' }}>
          {Array(20)
            .fill(0)
            .map((_, i) => (
              <Box
                key={i}
                style={{
                  width: '3px',
                  height: `${Math.random() * 30 + 10}px`,
                  background: '#ffffff',
                  margin: '0 1px',
                  opacity: 0.8,
                }}
              />
            ))}
        </Flex>
      </Box>

      {/* Threat Detection */}
      <Box style={{ marginBottom: '20px' }}>
        <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
          THREAT DETECTION
        </Box>
        <Flex align="center" style={{ marginBottom: '10px' }}>
          <Box
            style={{
              width: '60px',
              height: '60px',
              border: '2px solid #ffffff',
              borderRadius: '50%',
              position: 'relative',
              marginRight: '15px',
            }}
          >
            <Box
              style={{
                position: 'absolute',
                top: '50%',
                left: '50%',
                width: '2px',
                height: '25px',
                background: '#ffffff',
                transform: 'translate(-50%, -50%) rotate(45deg)',
                transformOrigin: 'center',
                animation: 'rotate 2s linear infinite',
              }}
            />
          </Box>
          <Box>
            <Box>SYSTEM.STATUS</Box>
            <Box>CRITICAL.EVENT</Box>
            <Box>ANOMALY.DETECTED</Box>
          </Box>
        </Flex>
        <Box style={{ marginBottom: '10px' }}>
          <Box style={{ marginBottom: '5px' }}>HKG</Box>
          <Box
            style={{
              width: '100%',
              height: '20px',
              background:
                'linear-gradient(90deg, #ffffff 0%, #ffffff 30%, transparent 30%, transparent 100%)',
              border: '1px solid rgba(255,255,255,0.3)',
            }}
          />
        </Box>
      </Box>

      {/* Antimemetic Interface */}
      <Box style={{ marginBottom: '20px' }}>
        <Box>ANTIMEMETIC INTERFACE...</Box>
        <Box>SCAN COMPLETE</Box>
        <Box>DEF MODE OFF</Box>
      </Box>

      {/* Displaying File */}
      <Box style={{ marginBottom: '20px' }}>
        <Box>DISPLAYING FILE</Box>
        <Box>VISIT COUNT / 86723</Box>
      </Box>

      {/* Event Log */}
      <Box>
        <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
          EVENT LOG
        </Box>
        <Box style={{ fontSize: '10px', lineHeight: '1.4' }}>
          <Box>◆ 16:46 - ACCESSED DOCUMENT</Box>
          <Box>◆ 16:46 - EXECUTED: ACCESS</Box>
          <Box>◆ 16:45 - EXECUTED: ACCESS</Box>
          <Box>◆ 16:44 - EXECUTED: HELP</Box>
          <Box>◆ 16:44 - EXECUTED: LOGIN</Box>
          <Box>◆ 16:32 - ALL SYSTEMS OPERATIONAL</Box>
          <Box>◆ 16:32 - LOADING DATABASE.</Box>
          <Box>◆ 16:32 - LOADING SITE OVERVIEW.</Box>
          <Box>◆ 16:32 - SETTING UP EVENT.</Box>
          <Box>◆ 16:32 - LOADING ADDITIONAL...</Box>
        </Box>
      </Box>

      {/* Scroll indicator */}
      <Box
        style={{
          position: 'absolute',
          bottom: '20px',
          right: '20px',
          width: '8px',
          height: '60px',
          background: 'rgba(255,255,255,0.3)',
          borderRadius: '4px',
        }}
      >
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '0',
            fontSize: '10px',
            transform: 'rotate(90deg)',
          }}
        >
          78
        </Box>
      </Box>
    </Box>
  );

  return (
    <Window
      width={1200}
      height={800}
      theme="scp_terminal"
      style={{
        background: '#000000',
        fontFamily: 'monospace',
        fontSize: '14px',
        color: '#ffffff',
        margin: '0',
        padding: '0',
        overflow: 'hidden',
      }}
    >
      <Window.Content
        style={{
          background: 'transparent',
          padding: '0',
          fontFamily: 'monospace',
          position: 'relative',
          width: '100%',
          height: '100%',
          overflow: 'hidden',
        }}
      >
        <GridBackground />
        <WatermarkLogo />
        <TopNavigation />
        <Box
          style={{
            position: 'absolute',
            top: '50px',
            left: '20px',
            right: '400px',
            bottom: '20px',
            overflow: 'auto',
            zIndex: 5,
          }}
        >
          {(() => {
            console.log(
              'Rendering main interface, activeTab:',
              activeTab,
              'type:',
              typeof activeTab,
            );

            if (activeTab === 'terminal') return <TerminalInterface />;
            if (activeTab === 'facility') return <FacilityInterface />;
            if (activeTab === 'scp') return <SCPInterface />;
            if (activeTab === 'technology') return <TechnologyInterface />;
            if (activeTab === 'medical') return <MedicalInterface />;
            if (activeTab === 'security') return <SecurityInterface />;
            if (activeTab === 'research') return <ResearchInterface />;
            if (activeTab === 'personnel') return <PersonnelInterface />;
            if (activeTab === 'players') return <PlayerInterface />;

            return (
              <Box style={{ color: 'red', fontSize: '16px', padding: '20px' }}>
                No interface found for tab: &quot;{activeTab}&quot; (type:{' '}
                {typeof activeTab})
                <br />
                Available tabs: terminal, facility, scp, technology, medical,
                security, research, personnel, players
              </Box>
            );
          })()}
        </Box>
        <SidePanel />

        <style>
          {`
            @keyframes blink {
              0%, 50% { opacity: 1; }
              51%, 100% { opacity: 0; }
            }
            @keyframes rotate {
              from { transform: translate(-50%, -50%) rotate(0deg); }
              to { transform: translate(-50%, -50%) rotate(360deg); }
            }
            /* Custom scrollbar styling */
            ::-webkit-scrollbar {
              width: 12px;
            }
            ::-webkit-scrollbar-track {
              background: rgba(0,0,0,0.3);
              border-radius: 6px;
            }
            ::-webkit-scrollbar-thumb {
              background: rgba(255,255,255,0.3);
              border-radius: 6px;
              border: 2px solid rgba(0,0,0,0.3);
            }
            ::-webkit-scrollbar-thumb:hover {
              background: rgba(255,255,255,0.5);
            }
            ::-webkit-scrollbar-corner {
              background: rgba(0,0,0,0.3);
            }
            /* Scrollable content areas */
            .scrollable-content {
              max-height: 400px;
              overflow-y: auto;
              padding-right: 10px;
            }
            .scrollable-table {
              max-height: 300px;
              overflow-y: auto;
            }
            .scrollable-list {
              max-height: 250px;
              overflow-y: auto;
            }
          `}
        </style>
      </Window.Content>
    </Window>
  );
};
