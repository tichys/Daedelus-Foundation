import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex } from '../components';
import { Window } from '../layouts';

export const PersistenceMasterPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = useLocalState(
    context,
    'activeTab',
    'terminal',
  );

  const {
    facility_data,
    scp_data,
    technology_data,
    player_data,
    system_status,
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
        position: 'absolute',
        top: '50px',
        left: '20px',
        right: '400px',
        bottom: '20px',
        background: 'rgba(0,0,0,0.7)',
        border: '1px solid rgba(255,255,255,0.2)',
        borderRadius: '5px',
        padding: '20px',
        fontFamily: 'monospace',
        fontSize: '14px',
        color: '#ffffff',
        zIndex: 5,
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
  const FacilityInterface = () => (
    <Box
      style={{
        position: 'absolute',
        top: '50px',
        left: '20px',
        right: '400px',
        bottom: '20px',
        background: 'rgba(0,0,0,0.7)',
        border: '1px solid rgba(255,255,255,0.2)',
        borderRadius: '5px',
        padding: '20px',
        fontFamily: 'monospace',
        fontSize: '14px',
        color: '#ffffff',
        zIndex: 5,
      }}
    >
      <Box style={{ marginBottom: '20px' }}>
        <Box
          style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '5px' }}
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
    </Box>
  );

  // SCP Management Interface
  const SCPInterface = () => (
    <Box
      style={{
        position: 'absolute',
        top: '50px',
        left: '20px',
        right: '400px',
        bottom: '20px',
        background: 'rgba(0,0,0,0.7)',
        border: '1px solid rgba(255,255,255,0.2)',
        borderRadius: '5px',
        padding: '20px',
        fontFamily: 'monospace',
        fontSize: '14px',
        color: '#ffffff',
        zIndex: 5,
      }}
    >
      <Box style={{ marginBottom: '20px' }}>
        <Box
          style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '5px' }}
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
    </Box>
  );

  // Technology Management Interface
  const TechnologyInterface = () => (
    <Box
      style={{
        position: 'absolute',
        top: '50px',
        left: '20px',
        right: '400px',
        bottom: '20px',
        background: 'rgba(0,0,0,0.7)',
        border: '1px solid rgba(255,255,255,0.2)',
        borderRadius: '5px',
        padding: '20px',
        fontFamily: 'monospace',
        fontSize: '14px',
        color: '#ffffff',
        zIndex: 5,
      }}
    >
      <Box style={{ marginBottom: '20px' }}>
        <Box
          style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '5px' }}
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
        <Box>RESEARCH PROGRESS: {technology_data?.research_progress || 0}%</Box>
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
    </Box>
  );

  // Player Data Management Interface
  const PlayerInterface = () => (
    <Box
      style={{
        position: 'absolute',
        top: '50px',
        left: '20px',
        right: '400px',
        bottom: '20px',
        background: 'rgba(0,0,0,0.7)',
        border: '1px solid rgba(255,255,255,0.2)',
        borderRadius: '5px',
        padding: '20px',
        fontFamily: 'monospace',
        fontSize: '14px',
        color: '#ffffff',
        zIndex: 5,
      }}
    >
      <Box style={{ marginBottom: '20px' }}>
        <Box
          style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '5px' }}
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
    </Box>
  );

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
        }}
      >
        <GridBackground />
        <WatermarkLogo />
        <TopNavigation />
        {activeTab === 'terminal' && <TerminalInterface />}
        {activeTab === 'facility' && <FacilityInterface />}
        {activeTab === 'scp' && <SCPInterface />}
        {activeTab === 'technology' && <TechnologyInterface />}
        {activeTab === 'players' && <PlayerInterface />}
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
          `}
        </style>
      </Window.Content>
    </Window>
  );
};
