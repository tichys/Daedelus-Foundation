import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, Modal, Tooltip } from '../components';
import { Window } from '../layouts';
import { SkillProgression } from './SkillProgression';

const C = {
  bg: '#08080a',
  panel: '#0c0c10',
  border: '#1e1e24',
  borderRed: '#6b0000',
  accent: '#c2960e',
  red: '#8b0000',
  redBright: '#cc2222',
  green: '#1a7a1a',
  greenDim: '#0d4a0d',
  text: '#b0b0b0',
  textBright: '#e0e0e0',
  textDim: '#555560',
  amber: '#d4a017',
  mono: '"Consolas", "Courier New", "Lucida Console", monospace',
};

const term = (overrides = {}) => ({
  fontFamily: C.mono,
  fontSize: '12px',
  color: C.text,
  ...overrides,
});

const TermHeader = (props) => (
  <Box
    style={term({
      fontSize: '10px',
      color: C.textDim,
      letterSpacing: '0.18em',
      textTransform: 'uppercase',
      borderBottom: `1px solid ${C.border}`,
      paddingBottom: '4px',
      marginBottom: '8px',
      ...props.style,
    })}
  >
    {props.children}
  </Box>
);

const TermLabel = (props) => (
  <Box
    as="span"
    style={term({
      color: C.textDim,
      fontSize: '10px',
      letterSpacing: '0.12em',
      textTransform: 'uppercase',
      marginRight: '8px',
    })}
  >
    {props.children}
  </Box>
);

const TermValue = (props) => (
  <Box
    as="span"
    style={term({
      color: props.color || C.textBright,
      fontWeight: props.bold ? 'bold' : undefined,
    })}
  >
    {props.children}
  </Box>
);

const TermRow = (props) => (
  <Box style={{ marginBottom: '6px', display: 'flex', alignItems: 'center' }}>
    {props.children}
  </Box>
);

const TermDivider = () => (
  <Box
    style={{
      color: C.borderRed,
      fontSize: '10px',
      letterSpacing: '0.3em',
      margin: '10px 0',
      userSelect: 'none',
      overflow: 'hidden',
      whiteSpace: 'nowrap',
    }}
  >
    {'─'.repeat(80)}
  </Box>
);

const TermButton = (props) => {
  const selected = props.selected;
  const color = props.color;
  const bg = selected
    ? color === 'red'
      ? 'rgba(139,0,0,0.35)'
      : color === 'green'
        ? 'rgba(26,122,26,0.35)'
        : color === 'yellow'
          ? 'rgba(180,160,20,0.25)'
          : 'rgba(255,255,255,0.08)'
    : 'transparent';
  const borderColor = selected
    ? color === 'red'
      ? C.red
      : color === 'green'
        ? C.green
        : color === 'yellow'
          ? '#b0a020'
          : C.border
    : C.border;

  return (
    <Button
      {...props}
      style={{
        fontFamily: C.mono,
        fontSize: '10px',
        letterSpacing: '0.1em',
        textTransform: 'uppercase',
        background: bg,
        border: `1px solid ${borderColor}`,
        borderRadius: 0,
        color: selected ? C.textBright : C.textDim,
        padding: '3px 8px',
        boxShadow: selected ? `0 0 6px ${borderColor}44` : 'none',
      }}
    >
      {props.children}
    </Button>
  );
};

const TOOLTIPS = {
  ROOMS: 'Tracked room/area states across the facility. Each room has health, power, and security level. Use the Rooms tab to inspect individual rooms.',
  EQUIPMENT: 'Operational equipment count out of total tracked. Equipment below 50% health is flagged for maintenance. Use the Equipment tab to inspect and schedule repairs.',
  SECURITY_SYSTEMS: 'Tracked security components (cameras, airlocks, consoles). Operational status and health are monitored. Use the Systems tab for details.',
  POWER_EFFICIENCY: 'Ratio of operational APCs to total APCs across the facility. Affects facility health calculation (40% weight). Low efficiency indicates power grid failures.',
  CONTAINMENT_STABILITY: 'Percentage of SCPs currently contained vs. total. Weighted 60% in facility health. Drops when SCPs breach containment.',
  HEALTH: 'Composite facility health: 40% power efficiency + 60% containment stability. Represents overall operational readiness.',
  MAINTENANCE_LEVEL: 'Mirrors facility health. Represents how well-maintained the facility infrastructure is. Low values trigger maintenance task generation.',
  SECURITY_LEVEL: 'Current facility alert level (1-5). Higher levels indicate increased threat posture. Controlled by command staff.',
  EQUIPMENT_TYPE: 'Category of tracked equipment. Type determines which maintenance team is assigned for repairs.',
  EQUIPMENT_HEALTH: 'Equipment integrity percentage. Below 50% triggers a maintenance-required flag and auto-generates a repair task.',
  EQUIPMENT_EFFICIENCY: 'Energy efficiency ratio (0-1). Lower values mean the equipment wastes more power.',
  EQUIPMENT_MAINTENANCE: 'Auto-flagged when equipment health drops below 50%. Triggers maintenance task generation with priority based on severity.',
  ROOM_TYPE: 'Functional classification of the room (e.g., Lab, Security, Medical). Determines default security level and maintenance priority.',
  ROOM_HEALTH: 'Room structural integrity (0-100). Rooms below 50% health or without power are marked OFFLINE.',
  ROOM_SECURITY: 'Room security clearance level (1-4). Determines access restrictions.',
  SYS_TYPE: 'Security component type (camera, airlock, console). Each type has a default security level.',
  SYS_HEALTH: 'Component integrity percentage. Below 50% triggers an alert status flag.',
  SYS_SECURITY: 'Component security level. Higher levels indicate more critical infrastructure.',
  SYS_ALERT: 'Triggered when component health drops below 50%. Requires immediate attention.',
  TASK_PRIORITY: 'Auto-assigned based on equipment health: Critical (<25%) = High, <50% = Medium, else Low.',
  TASK_ASSIGNED: 'Maintenance team auto-assigned based on equipment type keywords (electrical, hvac, structural, general).',
  SCP_CONTAINMENT_STABILITY: 'Global containment stability percentage. Starts at 100%, drops when SCPs breach. Affected by containment effectiveness.',
  SCP_ACTIVE_BREACHES: 'Current number of SCP containment breaches. Each active breach reduces global stability.',
  SCP_RESEARCH_PROGRESS: 'Average research progress across all SCP research projects. Tracked by the SCP persistence subsystem.',
  SCP_CONTAINMENT_EFFECTIVENESS: 'Ratio of contained SCPs to total (0-1). High effectiveness means most SCPs remain in their chambers.',
  SCP_INSTANCES: 'Number of SCP entities currently tracked by the persistence system. Each has containment status, health, and interaction history.',
  TECH_LEVEL: 'Current technology tier (starts at 1). Increases by 1 for every 1000 innovation score accumulated. Unlocks advanced research options.',
  TECH_PROGRESS: 'Average progress across all technology research projects. Reflects overall R&D momentum.',
  TECH_INNOVATION: 'Sum of all scientific discovery innovation values. Drives technology level advancement (1000 per level).',
  TECH_BUDGET: 'Budget allocated to technology research (default 500k). Spent on research projects and tech development.',
  TECH_EFFICIENCY: 'Research efficiency multiplier (0-1). Below 1.0 means research progresses slower than optimal.',
  MED_PATIENTS: 'Count of patient medical records stored in the persistence system. Includes active and discharged patients.',
  MED_TREATMENTS: 'Total treatment log entries. Each records patient, doctor, treatment type, and success/failure.',
  MED_OUTBREAKS: 'Currently active disease outbreaks. Status can be ACTIVE, CONTAINED, or ERADICATED.',
  MED_RESEARCH: 'Number of medical research projects. Can be ACTIVE, COMPLETED, CANCELLED, or ON_HOLD.',
  MED_BUDGET: 'Medical department budget (default 1M). Used for equipment, staffing, and research funding.',
  MED_PERSONNEL: 'Live count of medical staff currently online. Queried from the jobs system each time data is requested.',
  MED_CONTAINMENT: 'Disease control effectiveness (0-1). High values indicate outbreaks are being managed effectively.',
  SEC_PERSONNEL: 'Count of security personnel records. Each has clearance level, performance rating, and incident history.',
  SEC_INCIDENTS: 'Total security incidents logged. Includes breaches, unauthorized access, and threat responses.',
  SEC_THREATS: 'Currently active threat count. Threats can be containment breaches, intruders, or security violations.',
  SEC_BREACHES: 'Number of containment breaches recorded. Each breach is logged with type, severity, and location.',
  SEC_UNAUTHORIZED: 'Unauthorized access attempt count. Each attempt is logged with location and clearance used.',
  SEC_BUDGET: 'Security department budget (default 2M). Allocated from the budget system for staffing and equipment.',
  RESEARCH_TOTAL: 'Lifetime total of research projects created. Includes completed, active, and cancelled projects.',
  RESEARCH_COMPLETED: 'Projects that reached 100% progress and were marked COMPLETED.',
  RESEARCH_ACTIVE: 'Currently active research project count. These projects are ongoing and consuming budget.',
  RESEARCH_DISCOVERIES: 'Count of scientific discoveries logged. Each has significance (1-5) and discoverer info.',
  RESEARCH_PUBLICATIONS: 'Number of research publications. Each has title, authors, journal, and impact factor.',
  RESEARCH_BUDGET: 'Research budget (default 5M). Largest departmental budget. Funds projects and discoveries.',
  RESEARCH_EFFICIENCY: 'Research efficiency multiplier (0-1). Below 1.0 slows all research progress.',
  RESEARCH_PERSONNEL: 'Live count of research staff currently online. Queried from the jobs system.',
  CHEM_COMPOUNDS: 'Total chemical compounds discovered and catalogued by the chemical persistence subsystem.',
  CHEM_BREACHES: 'Active chemical containment breaches. Hazardous material release events.',
  CHEM_PROGRESS: 'Chemical research progress percentage. Tracked independently from general research.',
  CHEM_CONTAINMENT: 'Chemical containment effectiveness (0-100%). High values indicate safe storage of hazardous materials.',
  CHEM_BUDGET: 'Chemical department budget (default 500k). Funds containment and research.',
  CHEM_STAFF: 'Number of chemical research staff assigned to the department.',
  INC_TOTAL: 'Total incidents logged across all categories (security, containment, structural, medical).',
  INC_ACTIVE: 'Currently active incidents that have not been resolved. Requires response.',
  INC_RESPONSE: 'Average incident response time in minutes. Lower is better.',
  INC_CASUALTIES: 'Total casualty count across all incidents. Includes injuries and fatalities.',
  INC_DAMAGE: 'Total monetary damage cost from all incidents. Used for budget impact analysis.',
  INC_SUCCESS: 'Containment success rate (0-100%). Measures how often containment is re-established without casualties.',
  PSYCH_ASSESSED: 'Count of staff who have undergone psychological assessment. Tracks overall mental health coverage.',
  PSYCH_MENTAL: 'Average mental health score across assessed staff (0-100). Starts at 100, drops with trauma and SCP exposure.',
  PSYCH_STRESS: 'Current facility stress level. Elevated by breaches, casualties, and extended alert status.',
  PSYCH_THERAPY: 'Therapy success rate (0-100%). Measures effectiveness of psychological intervention programs.',
  PSYCH_EXPOSURE: 'Number of SCP exposure cases. Staff exposed to cognitohazardous or anomalous phenomena.',
  PSYCH_BUDGET: 'Mental health budget (default 300k). Funds assessments, therapy, and amnestic programs.',
  INFRA_TOTAL: 'Total equipment count tracked by the infrastructure subsystem. Includes all facility equipment.',
  INFRA_OPERATIONAL: 'Equipment currently in operational condition. Ratio to total indicates infrastructure health.',
  INFRA_POWER: 'Power efficiency percentage (0-100%). Measures electrical grid reliability across the facility.',
  INFRA_STRUCTURAL: 'Facility structural integrity percentage (default 100%). Drops with damage events.',
  INFRA_BUDGET: 'Maintenance budget (default 1M). Funds repairs, replacements, and scheduled maintenance.',
  INFRA_BACKLOG: 'Number of pending repair orders. High backlog indicates understaffed maintenance teams.',
  ANALYTICS_EFFICIENCY: 'Cross-system overall efficiency (0-100%). Aggregated from all subsystem efficiency metrics.',
  ANALYTICS_PERFORMANCE: 'Composite performance score (default 100). Weighted across all operational metrics.',
  ANALYTICS_TREND: 'Trend direction: IMPROVING, STABLE, or DECLINING. Based on recent metric changes.',
  ANALYTICS_QUALITY: 'Data quality score (default 100). Measures reliability and completeness of analytics data.',
  ANALYTICS_BUDGET: 'Analytics department budget (default 200k). Funds reporting and data infrastructure.',
  PERS_TOTAL: 'Total staff count in the personnel persistence system. Includes all departments.',
  PERS_ACTIVE: 'Currently active staff (not suspended, terminated, or retired).',
  PERS_BUDGET: 'Personnel department budget (default 3M). Funds salaries, training, and recruitment.',
  PERS_SATISFACTION: 'Staff satisfaction percentage (default 75%). Drops with poor conditions, rises with good management.',
  PERS_TURNOVER: 'Staff turnover rate (default 5%). Percentage of staff leaving per cycle. High turnover is costly.',
  PERS_PERFORMANCE: 'Average performance rating across all staff (0-100). Based on performance reviews.',
  PERS_TRAINING: 'Training completion rate (default 85%). Percentage of assigned training programs completed.',
  BUDGET_TOTAL: 'Total Foundation budget (default 10M). The top-level funding pool for all departments.',
  BUDGET_BALANCE: 'Current available balance. Decreases with expenses, increases with revenue. Can go negative.',
  BUDGET_EXPENSES: 'Current monthly expenses across all departments. Tracked by the budget subsystem.',
  BUDGET_REVENUE: 'Current monthly revenue. Primarily from oversight council funding allocations.',
  BUDGET_CYCLE: 'Current budget cycle/quarter number. Increments each budget period for tracking purposes.',
  BUDGET_ALLOCATED: 'Budget amount allocated to this department for the current cycle.',
  BUDGET_SPENT: 'Amount already spent from the department allocation.',
  BUDGET_REMAINING: 'Allocation minus spent. Negative means the department is over budget.',
  BUDGET_EFFICIENCY: 'Department budget efficiency rating (default 100). Lower values indicate waste or overspending.',
  BUDGET_STATUS: 'Budget health: NORMAL (on track), WARNING (approaching limit), CRITICAL (near exhausted), OVERSPENT (exceeded).',
  PLAYER_ACTIVE: 'Number of tracked players in the persistent progression system. Based on stored player data records.',
  PLAYER_EXPERIENCE: 'Total XP accumulated across all players. Earned through gameplay activities and role performance.',
  PLAYER_RANK: 'Average player rank across all tracked players. Higher ranks unlock job access.',
  PLAYER_ACHIEVEMENTS: 'Total achievements unlocked across all players. Tracked by the achievement subsystem.',
};

const TipLabel = (props) => {
  const tip = TOOLTIPS[props.tip];
  if (tip) {
    return (
      <Tooltip content={tip} position="right">
        <Box
          as="span"
          style={{
            color: C.textDim,
            fontSize: '10px',
            letterSpacing: '0.12em',
            textTransform: 'uppercase',
            marginRight: '8px',
            cursor: 'help',
            borderBottom: '1px dotted #444',
          }}
        >
          {props.children}
        </Box>
      </Tooltip>
    );
  }
  return <TermLabel>{props.children}</TermLabel>;
};

const TermProgressBar = (props) => (
  <Box style={{ marginBottom: '6px' }}>
    <Box
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        marginBottom: '2px',
      }}
    >
      {props.tip ? (
        <TipLabel tip={props.tip}>{props.label}</TipLabel>
      ) : (
        <TermLabel>{props.label}</TermLabel>
      )}
      <TermValue color={props.color || C.amber}>
        {props.value}
        {props.suffix || ''}
      </TermValue>
    </Box>
    <Box
      style={{
        height: '6px',
        background: C.panel,
        border: `1px solid ${C.border}`,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          height: '100%',
          width: `${Math.min(100, Math.max(0, (props.value / props.maxValue) * 100))}%`,
          background: props.color || C.amber,
          transition: 'width 0.3s',
        }}
      />
    </Box>
  </Box>
);

const TermModal = (props) => (
  <Modal
    {...props}
    style={{
      background: C.bg,
      border: `1px solid ${C.borderRed}`,
      borderRadius: 0,
      fontFamily: C.mono,
      color: C.text,
      padding: '16px',
    }}
  >
    {props.children}
  </Modal>
);

const StatusDot = ({ online }) => (
  <Box
    as="span"
    style={{
      display: 'inline-block',
      width: '6px',
      height: '6px',
      borderRadius: '50%',
      background: online ? C.green : C.redBright,
      marginRight: '4px',
    }}
  />
);

const NAV_ITEMS = [
  { key: 'desktop', label: 'INDEX' },
  { key: 'facility', label: 'FACILITY' },
  { key: 'scp', label: 'SCP' },
  { key: 'technology', label: 'TECH' },
  { key: 'medical', label: 'MEDICAL' },
  { key: 'security', label: 'SECURITY' },
  { key: 'research', label: 'RESEARCH' },
  { key: 'chemical', label: 'CHEMICAL' },
  { key: 'incident', label: 'INCIDENT' },
  { key: 'psychological', label: 'PSYCH' },
  { key: 'infrastructure', label: 'INFRA' },
  { key: 'analytics', label: 'ANALYTICS' },
  { key: 'personnel', label: 'PERSONNEL' },
  { key: 'players', label: 'PLAYERS' },
  { key: 'budget', label: 'BUDGET' },
  { key: 'progression', label: 'PROGRESS' },
  { key: 'skill_progression', label: 'SKILLS' },
];

const SubTabBar = ({ tabs, active, onChange }) => (
  <Box
    style={{
      display: 'flex',
      borderBottom: `1px solid ${C.border}`,
      marginBottom: '12px',
      overflowX: 'auto',
    }}
  >
    {tabs.map((t) => {
      const isActive = active === t.key;
      return (
        <Box
          key={t.key}
          style={{
            padding: '4px 10px',
            cursor: 'pointer',
            background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent',
            borderBottom: isActive
              ? `2px solid ${C.amber}`
              : '2px solid transparent',
            color: isActive ? C.textBright : C.textDim,
            fontSize: '10px',
            letterSpacing: '0.1em',
            textTransform: 'uppercase',
            fontFamily: C.mono,
            whiteSpace: 'nowrap',
          }}
          onClick={() => onChange(t.key)}
        >
          {t.label}
        </Box>
      );
    })}
  </Box>
);

const SECTION_TOOLTIPS = {
  'SCP CONTAINMENT MANAGEMENT': {
    global_containment_stability: TOOLTIPS.SCP_CONTAINMENT_STABILITY,
    active_breaches: TOOLTIPS.SCP_ACTIVE_BREACHES,
    research_progress: TOOLTIPS.SCP_RESEARCH_PROGRESS,
    containment_effectiveness: TOOLTIPS.SCP_CONTAINMENT_EFFECTIVENESS,
    scp_instances_count: TOOLTIPS.SCP_INSTANCES,
  },
  'TECHNOLOGY MANAGEMENT': {
    technology_level: TOOLTIPS.TECH_LEVEL,
    research_progress: TOOLTIPS.TECH_PROGRESS,
    innovation_score: TOOLTIPS.TECH_INNOVATION,
    research_budget: TOOLTIPS.TECH_BUDGET,
    research_efficiency: TOOLTIPS.TECH_EFFICIENCY,
  },
  'MEDICAL RECORDS MANAGEMENT': {
    total_patients: TOOLTIPS.MED_PATIENTS,
    total_treatments: TOOLTIPS.MED_TREATMENTS,
    active_outbreaks: TOOLTIPS.MED_OUTBREAKS,
    research_projects: TOOLTIPS.MED_RESEARCH,
    medical_budget: TOOLTIPS.MED_BUDGET,
    total_personnel: TOOLTIPS.MED_PERSONNEL,
    containment_effectiveness: TOOLTIPS.MED_CONTAINMENT,
  },
  'SECURITY OPERATIONS MANAGEMENT': {
    total_personnel: TOOLTIPS.SEC_PERSONNEL,
    total_incidents: TOOLTIPS.SEC_INCIDENTS,
    active_threats: TOOLTIPS.SEC_THREATS,
    containment_breaches: TOOLTIPS.SEC_BREACHES,
    unauthorized_access: TOOLTIPS.SEC_UNAUTHORIZED,
    security_budget: TOOLTIPS.SEC_BUDGET,
  },
  'CHEMICAL CONTAINMENT MANAGEMENT': {
    total_compounds_discovered: TOOLTIPS.CHEM_COMPOUNDS,
    active_containment_breaches: TOOLTIPS.CHEM_BREACHES,
    chemical_research_progress: TOOLTIPS.CHEM_PROGRESS,
    containment_effectiveness: TOOLTIPS.CHEM_CONTAINMENT,
    chemical_budget: TOOLTIPS.CHEM_BUDGET,
    research_staff_count: TOOLTIPS.CHEM_STAFF,
  },
  'INCIDENT RESPONSE MANAGEMENT': {
    total_incidents: TOOLTIPS.INC_TOTAL,
    active_incidents: TOOLTIPS.INC_ACTIVE,
    average_response_time: TOOLTIPS.INC_RESPONSE,
    total_casualties: TOOLTIPS.INC_CASUALTIES,
    total_damage_cost: TOOLTIPS.INC_DAMAGE,
    containment_success_rate: TOOLTIPS.INC_SUCCESS,
  },
  'PSYCHOLOGICAL SERVICES MANAGEMENT': {
    total_staff_assessed: TOOLTIPS.PSYCH_ASSESSED,
    average_mental_health: TOOLTIPS.PSYCH_MENTAL,
    stress_level: TOOLTIPS.PSYCH_STRESS,
    therapy_success_rate: TOOLTIPS.PSYCH_THERAPY,
    scp_exposure_cases: TOOLTIPS.PSYCH_EXPOSURE,
    mental_health_budget: TOOLTIPS.PSYCH_BUDGET,
  },
  'INFRASTRUCTURE MANAGEMENT': {
    total_equipment: TOOLTIPS.INFRA_TOTAL,
    operational_equipment: TOOLTIPS.INFRA_OPERATIONAL,
    power_efficiency: TOOLTIPS.INFRA_POWER,
    structural_health: TOOLTIPS.INFRA_STRUCTURAL,
    maintenance_budget: TOOLTIPS.INFRA_BUDGET,
    repair_backlog: TOOLTIPS.INFRA_BACKLOG,
  },
  'ANALYTICS & PERFORMANCE': {
    overall_efficiency: TOOLTIPS.ANALYTICS_EFFICIENCY,
    performance_score: TOOLTIPS.ANALYTICS_PERFORMANCE,
    trend_direction: TOOLTIPS.ANALYTICS_TREND,
    data_quality_score: TOOLTIPS.ANALYTICS_QUALITY,
    analytics_budget: TOOLTIPS.ANALYTICS_BUDGET,
  },
  'PERSONNEL MANAGEMENT': {
    total_staff: TOOLTIPS.PERS_TOTAL,
    active_staff: TOOLTIPS.PERS_ACTIVE,
    personnel_budget: TOOLTIPS.PERS_BUDGET,
    staff_satisfaction: TOOLTIPS.PERS_SATISFACTION,
    turnover_rate: TOOLTIPS.PERS_TURNOVER,
    average_performance: TOOLTIPS.PERS_PERFORMANCE,
    training_completion: TOOLTIPS.PERS_TRAINING,
  },
  'BUDGET SYSTEM': {
    total_budget: TOOLTIPS.BUDGET_TOTAL,
    current_balance: TOOLTIPS.BUDGET_BALANCE,
    monthly_expenses: TOOLTIPS.BUDGET_EXPENSES,
    monthly_revenue: TOOLTIPS.BUDGET_REVENUE,
    budget_cycle: TOOLTIPS.BUDGET_CYCLE,
  },
  'RESEARCH PROJECTS MANAGEMENT': {
    total_projects: TOOLTIPS.RESEARCH_TOTAL,
    completed_projects: TOOLTIPS.RESEARCH_COMPLETED,
    active_projects: TOOLTIPS.RESEARCH_ACTIVE,
    scientific_discoveries: TOOLTIPS.RESEARCH_DISCOVERIES,
    publications: TOOLTIPS.RESEARCH_PUBLICATIONS,
    research_budget: TOOLTIPS.RESEARCH_BUDGET,
    research_efficiency: TOOLTIPS.RESEARCH_EFFICIENCY,
    total_personnel: TOOLTIPS.RESEARCH_PERSONNEL,
  },
  'PLAYER DATA MANAGEMENT': {
    active_players: TOOLTIPS.PLAYER_ACTIVE,
    total_experience: TOOLTIPS.PLAYER_EXPERIENCE,
    average_rank: TOOLTIPS.PLAYER_RANK,
    achievements_unlocked: TOOLTIPS.PLAYER_ACHIEVEMENTS,
  },
  'PERSISTENT PROGRESSION': {
    active_players: 'Currently connected players. Live count from the server player list.',
    total_experience: 'Total XP accumulated across all players in the progression system. Earned through gameplay activities.',
    total_achievements: 'Total achievements unlocked across all tracked players.',
    scp_progression_count: 'Number of SCP-specific progression records. Tracks per-SCP interaction and containment history.',
    last_backup: 'Approximate time of the last automatic data backup.',
    active_sessions: 'Number of active client connections. Live count from the server.',
  },
};

const GenericSection = ({ title, data, act, actions }) => (
  <Box>
    <TermHeader>{title}</TermHeader>
    <Box
      style={{
        display: 'flex',
        gap: '4px',
        marginBottom: '12px',
        flexWrap: 'wrap',
      }}
    >
      {actions &&
        actions.map((a, i) => (
          <TermButton
            key={i}
            color={a.color}
            onClick={() => act(a.action, a.params || undefined)}
          >
            {a.label}
          </TermButton>
        ))}
    </Box>
    {data ? (
      <Box style={{ lineHeight: '1.6' }}>
        {Object.entries(data)
          .filter(([k, v]) => typeof v !== 'object')
          .map(([key, value]) => {
            const sectionTips = SECTION_TOOLTIPS[title] || {};
            const tip = sectionTips[key];
            return (
              <TermRow key={key}>
                {tip ? (
                  <Tooltip content={tip} position="right">
                    <Box
                      as="span"
                      style={{
                        color: C.textDim,
                        fontSize: '10px',
                        letterSpacing: '0.12em',
                        textTransform: 'uppercase',
                        marginRight: '8px',
                        cursor: 'help',
                        borderBottom: '1px dotted #444',
                      }}
                    >
                      {key.replace(/_/g, ' ')}
                    </Box>
                  </Tooltip>
                ) : (
                  <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
                )}
                <TermValue
                  color={typeof value === 'number' ? C.amber : C.textBright}
                >
                  {String(value)}
                </TermValue>
              </TermRow>
            );
          })}
      </Box>
    ) : (
      <Box style={term({ color: C.textDim, fontStyle: 'italic' })}>
        NO DATA AVAILABLE
      </Box>
    )}
  </Box>
);

export const PersistenceMasterPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = React.useState('desktop');
  const [subTabs, setSubTabs] = React.useState({});

  const getSubTab = (section, defaultValue = 'overview') =>
    subTabs[section] || defaultValue;
  const setSubTab = (section, value) =>
    setSubTabs((prev) => ({ ...prev, [section]: value }));

  const {
    facility_data,
    scp_data,
    technology_data,
    medical_data,
    security_data,
    research_data,
    chemical_data,
    incident_data,
    psychological_data,
    infrastructure_data,
    analytics_data,
    personnel_data,
    budget_data,
    player_data,
    system_status,
  } = data;

  return (
    <Window
      title="SCP FOUNDATION — PERSISTENCE CONTROL TERMINAL"
      width={1400}
      height={900}
      theme="scp_terminal"
    >
      <Window.Content scrollable>
        <Box
          style={{
            background: C.bg,
            border: `1px solid ${C.borderRed}`,
            fontFamily: C.mono,
            fontSize: '12px',
            color: C.text,
            minHeight: '100%',
          }}
        >
          {/* HEADER */}
          <Box
            style={{
              borderBottom: `2px solid ${C.borderRed}`,
              padding: '10px 14px 8px',
              background: 'linear-gradient(180deg, #0e0000 0%, #08080a 100%)',
            }}
          >
            <Box
              style={{
                fontSize: '15px',
                fontWeight: 'bold',
                color: C.amber,
                letterSpacing: '0.18em',
              }}
            >
              SCP FOUNDATION — PERSISTENCE CONTROL TERMINAL
            </Box>
            <Box
              style={{
                fontSize: '9px',
                color: C.textDim,
                letterSpacing: '0.12em',
                marginTop: '2px',
              }}
            >
              CLEARANCE LEVEL 5 | ADMINISTRATIVE OVERRIDE | ALL SYSTEMS
              MONITORED
            </Box>
          </Box>

          {/* NAV BAR */}
          <Box
            style={{
              display: 'flex',
              borderBottom: `1px solid ${C.borderRed}`,
              overflowX: 'auto',
              background: C.panel,
            }}
          >
            {NAV_ITEMS.map((t) => {
              const isActive = activeTab === t.key;
              return (
                <Box
                  key={t.key}
                  style={{
                    padding: '6px 12px',
                    cursor: 'pointer',
                    background: isActive ? 'rgba(139,0,0,0.25)' : 'transparent',
                    borderRight: `1px solid ${C.border}`,
                    borderBottom: isActive
                      ? `2px solid ${C.amber}`
                      : '2px solid transparent',
                    color: isActive ? C.textBright : C.textDim,
                    fontSize: '10px',
                    letterSpacing: '0.12em',
                    textTransform: 'uppercase',
                    fontFamily: C.mono,
                    whiteSpace: 'nowrap',
                  }}
                  onClick={() => setActiveTab(t.key)}
                >
                  {isActive && '▸ '}
                  {t.label}
                </Box>
);
            })}
          </Box>

          {/* MAIN CONTENT */}
          <Box style={{ display: 'flex' }}>
            {/* LEFT: Content */}
            <Box style={{ flex: 1, padding: '16px', minHeight: '500px' }}>
              {/* DESKTOP / INDEX */}
              {activeTab === 'desktop' && (
                <Box>
                  <TermHeader>SYSTEM INDEX</TermHeader>
                  <Box
                    style={term({
                      color: C.textDim,
                      fontSize: '11px',
                      fontStyle: 'italic',
                      marginBottom: '12px',
                      borderLeft: `2px solid ${C.amber}`,
                      paddingLeft: '8px',
                    })}
                  >
                    SCP Foundation Persistence Control System. Select a section
                    from the navigation bar above to manage subsystems.
                  </Box>
                  <TermDivider />
                  <TermHeader>SYSTEM STATUS</TermHeader>
                  <TermRow>
                    <StatusDot online={!!facility_data} />
                    <TermLabel>FACILITY</TermLabel>
                    <TermValue color={facility_data ? C.green : C.redBright}>
                      {facility_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!scp_data} />
                    <TermLabel>SCP CONTAINMENT</TermLabel>
                    <TermValue color={scp_data ? C.green : C.redBright}>
                      {scp_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!technology_data} />
                    <TermLabel>TECHNOLOGY</TermLabel>
                    <TermValue color={technology_data ? C.green : C.redBright}>
                      {technology_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!medical_data} />
                    <TermLabel>MEDICAL</TermLabel>
                    <TermValue color={medical_data ? C.green : C.redBright}>
                      {medical_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!security_data} />
                    <TermLabel>SECURITY</TermLabel>
                    <TermValue color={security_data ? C.green : C.redBright}>
                      {security_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!research_data} />
                    <TermLabel>RESEARCH</TermLabel>
                    <TermValue color={research_data ? C.green : C.redBright}>
                      {research_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!personnel_data} />
                    <TermLabel>PERSONNEL</TermLabel>
                    <TermValue color={personnel_data ? C.green : C.redBright}>
                      {personnel_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermRow>
                    <StatusDot online={!!player_data} />
                    <TermLabel>PLAYER DATA</TermLabel>
                    <TermValue color={player_data ? C.green : C.redBright}>
                      {player_data ? 'LIVE' : 'OFFLINE'}
                    </TermValue>
                  </TermRow>
                  <TermDivider />
                  <TermHeader>QUICK ACTIONS</TermHeader>
                  <Box
                    style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => act('facility_save_data')}
                    >
                      SAVE ALL
                    </TermButton>
                    <TermButton onClick={() => act('facility_load_data')}>
                      LOAD ALL
                    </TermButton>
                    <TermButton
                      color="yellow"
                      onClick={() => act('progression_export_data')}
                    >
                      DOWNLOAD ALL
                    </TermButton>
                    <TermButton
                      color="red"
                      onClick={() => act('progression_reset_data')}
                    >
                      RESET ALL
                    </TermButton>
                  </Box>
                </Box>
              )}

              {/* FACILITY */}
              {activeTab === 'facility' && (
                <Box>
                  <SubTabBar
                    tabs={[
                      { key: 'overview', label: 'OVERVIEW' },
                      { key: 'rooms', label: 'ROOMS' },
                      { key: 'equipment', label: 'EQUIPMENT' },
                      { key: 'systems', label: 'SYSTEMS' },
                    ]}
                    active={getSubTab('facility')}
                    onChange={(v) => setSubTab('facility', v)}
                  />
                  <TermHeader>FACILITY MANAGEMENT</TermHeader>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '4px',
                      marginBottom: '12px',
                      flexWrap: 'wrap',
                    }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => act('facility_save_data')}
                    >
                      SAVE
                    </TermButton>
                    <TermButton onClick={() => act('facility_load_data')}>
                      LOAD
                    </TermButton>
                    <TermButton
                      color="red"
                      onClick={() => act('facility_reset_data')}
                    >
                      RESET
                    </TermButton>
                    <TermButton onClick={() => act('test_systems')}>
                      TEST SYSTEMS
                    </TermButton>
                    <TermButton
                      onClick={() => act('facility_power_grid_status')}
                    >
                      POWER GRID
                    </TermButton>
                  </Box>
                  {facility_data ? (
                    <>
                      {getSubTab('facility') === 'overview' && (
                        <Box style={{ lineHeight: '1.6' }}>
                          <TermRow>
                            <TipLabel tip="ROOMS">ROOMS</TipLabel>
                            <TermValue>
                              {facility_data.room_states_count || 0}/50
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TipLabel tip="EQUIPMENT">EQUIPMENT</TipLabel>
                            <TermValue>
                              {facility_data.equipment_operational || 0}/45
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TipLabel tip="SECURITY_SYSTEMS">SECURITY SYSTEMS</TipLabel>
                            <TermValue>
                              {facility_data.security_systems_count || 0}/15
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TipLabel tip="POWER_EFFICIENCY">POWER EFFICIENCY</TipLabel>
                            <TermValue color={C.amber}>
                              {facility_data.power_efficiency
                                ? Math.round(facility_data.power_efficiency * 100)
                                : 0}
                              %
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TipLabel tip="CONTAINMENT_STABILITY">CONTAINMENT STABILITY</TipLabel>
                            <TermValue>
                              {facility_data.containment_stability || 0}%
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TipLabel tip="HEALTH">HEALTH</TipLabel>
                            <TermValue color={C.green}>
                              {facility_data.facility_health || 0}%
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TipLabel tip="MAINTENANCE_LEVEL">MAINTENANCE</TipLabel>
                            <TermValue>
                              {facility_data.maintenance_level || 0}%
                            </TermValue>
                          </TermRow>
                          <TermRow>
                            <TipLabel tip="SECURITY_LEVEL">SECURITY LEVEL</TipLabel>
                            <TermValue color={C.redBright}>
                              {facility_data.security_level || 0}
                            </TermValue>
                          </TermRow>
                        </Box>
                      )}
                      {getSubTab('facility') === 'rooms' && (
                        <Box>
                          {facility_data.rooms &&
                          facility_data.rooms.length > 0 ? (
                            facility_data.rooms.map((room, idx) => (
                              <Box
                                key={idx}
                                style={{
                                  marginBottom: '4px',
                                  padding: '6px 8px',
                                  borderLeft: `2px solid ${
                                    room.status === 'OPERATIONAL'
                                      ? C.green
                                      : C.redBright
                                  }`,
                                  background: C.panel,
                                }}
                              >
                                <TermRow>
                                  <Tooltip content="Room functional classification. Determines default security level and maintenance priority." position="right">
                                    <TermValue bold color={C.amber} style={{ cursor: 'help', borderBottom: '1px dotted #444' }}>
                                      {(room.room_type || 'UNKNOWN').toUpperCase()}
                                    </TermValue>
                                  </Tooltip>
                                  <TermLabel style={{ marginLeft: '8px' }}>
                                    ID
                                  </TermLabel>
                                  <TermValue color={C.textDim}>
                                    {room.room_id}
                                  </TermValue>
                                </TermRow>
                                <TermRow>
                                  <TipLabel tip="ROOM_HEALTH">HEALTH</TipLabel>
                                  <TermValue color={C.amber}>
                                    {room.health}%
                                  </TermValue>
                                  <TipLabel tip="ROOM_SECURITY" style={{ marginLeft: '8px' }}>SECURITY</TipLabel>
                                  <TermValue>
                                    LVL {room.security_level}
                                  </TermValue>
                                </TermRow>
                              </Box>
                            ))
                          ) : (
                            <Box
                              style={term({
                                color: C.textDim,
                                fontStyle: 'italic',
                              })}
                            >
                              NO ROOM DATA
                            </Box>
                          )}
                        </Box>
                      )}
                      {getSubTab('facility') === 'equipment' && (
                        <Box>
                           {facility_data.equipment_status &&
                           Object.keys(facility_data.equipment_status).length >
                             0 ? (
                             Object.entries(facility_data.equipment_status).map(
                               ([eqId, eq]) => (
                                 <Box
                                   key={eqId}
                                   style={{
                                     marginBottom: '8px',
                                     padding: '8px 10px',
                                     borderLeft: `3px solid ${
                                       eq.operational ? C.green : C.redBright
                                     }`,
                                     background: C.panel,
                                   }}
                                 >
                                   <Box
                                     style={{
                                       display: 'flex',
                                       justifyContent: 'space-between',
                                       alignItems: 'center',
                                       marginBottom: '6px',
                                     }}
                                   >
                                      <Tooltip content="Equipment category. Type determines which maintenance team is assigned for repairs." position="right">
                                        <TermValue bold color={C.amber} style={{ cursor: 'help', borderBottom: '1px dotted #444' }}>
                                          {(
                                            eq.equipment_type ||
                                            eqId
                                          ).toUpperCase()}
                                        </TermValue>
                                      </Tooltip>
                                     <TermValue
                                       color={
                                         eq.operational
                                           ? C.green
                                           : C.redBright
                                       }
                                       bold
                                     >
                                       {eq.operational
                                        ? 'OPERATIONAL'
                                        : 'OFFLINE'}
                                     </TermValue>
                                   </Box>
                                    <TermProgressBar
                                      label="HEALTH"
                                      tip="EQUIPMENT_HEALTH"
                                      value={Math.round(eq.health || 0)}
                                     maxValue={100}
                                     color={
                                       (eq.health || 0) > 60
                                        ? C.green
                                        : (eq.health || 0) > 30
                                          ? C.amber
                                          : C.redBright
                                     }
                                     suffix="%"
                                   />
                                   <Box
                                     style={{
                                       display: 'flex',
                                       justifyContent: 'space-between',
                                       marginTop: '4px',
                                     }}
                                   >
                                      <Box>
                                        <TipLabel tip="EQUIPMENT_EFFICIENCY">EFFICIENCY</TipLabel>
                                       <TermValue color={C.amber}>
                                         {Math.round(
                                           (eq.efficiency || 0) * 100,
                                         )}
                                         %
                                       </TermValue>
                                     </Box>
                                   </Box>
                                    {eq.maintenance_required && (
                                      <Tooltip content="Auto-flagged when equipment health drops below 50%. Triggers maintenance task generation with priority based on severity." position="right">
                                        <Box
                                          style={{
                                            marginTop: '6px',
                                            padding: '4px 8px',
                                            background: 'rgba(139,0,0,0.25)',
                                            border: `1px solid ${C.redBright}`,
                                            color: C.redBright,
                                            fontFamily: C.mono,
                                            fontSize: '10px',
                                            letterSpacing: '0.1em',
                                            textTransform: 'uppercase',
                                            cursor: 'help',
                                          }}
                                        >
                                          MAINTENANCE REQUIRED
                                        </Box>
                                      </Tooltip>
                                   )}
                                 </Box>
                               ),
                             )
                           ) : (
                             <Box
                               style={term({
                                 color: C.textDim,
                                 fontStyle: 'italic',
                               })}
                             >
                               NO EQUIPMENT DATA
                             </Box>
                           )}
                           {facility_data.maintenance_tasks &&
                             facility_data.maintenance_tasks.length > 0 && (
                               <Box>
                                 <TermDivider />
                                 <TermHeader>MAINTENANCE SCHEDULE</TermHeader>
                                 {facility_data.maintenance_tasks.map(
                                   (task, idx) => (
                                     <Box
                                       key={idx}
                                       style={{
                                         marginBottom: '8px',
                                         padding: '8px 10px',
                                         borderLeft: `3px solid ${
                                           task.priority === 'high'
                                             ? C.redBright
                                             : task.priority === 'medium'
                                               ? C.amber
                                               : C.border
                                         }`,
                                         background: C.panel,
                                       }}
                                     >
                                       <Box
                                         style={{
                                           display: 'flex',
                                           justifyContent: 'space-between',
                                           alignItems: 'center',
                                           marginBottom: '4px',
                                         }}
                                       >
                                         <TermValue bold color={C.amber}>
                                           {task.task_name || task.task_id}
                                         </TermValue>
                                         <TermValue
                                           color={
                                             task.priority === 'high'
                                               ? C.redBright
                                               : C.amber
                                           }
                                         >
                                           {(task.priority || 'LOW').toUpperCase()}
                                         </TermValue>
                                       </Box>
                                       <Box
                                         style={{
                                           display: 'flex',
                                           gap: '16px',
                                           fontSize: '10px',
                                           color: C.textDim,
                                           fontFamily: C.mono,
                                         }}
                                       >
                                         <Box>
                                           ASSIGNED:{' '}
                                           <Box as="span" style={{ color: C.text }}>
                                             {task.assigned_to || 'UNASSIGNED'}
                                           </Box>
                                         </Box>
                                         <Box>
                                           DUE:{' '}
                                           <Box as="span" style={{ color: C.text }}>
                                             {task.due_date || 'N/A'}
                                           </Box>
                                         </Box>
                                       </Box>
                                     </Box>
                                   ),
                                 )}
                               </Box>
                             )}
                        </Box>
                      )}
                      {getSubTab('facility') === 'systems' && (
                        <Box>
                          {facility_data.security_systems &&
                          Object.keys(facility_data.security_systems).length >
                            0 ? (
                            Object.entries(facility_data.security_systems).map(
                              ([sysId, sys]) => (
                                <Box
                                  key={sysId}
                                  style={{
                                    marginBottom: '4px',
                                    padding: '6px 8px',
                                    borderLeft: `2px solid ${
                                      sys.operational ? C.green : C.redBright
                                    }`,
                                    background: C.panel,
                                  }}
                                >
                                   <TermRow>
                                     <Tooltip content="Security component type (camera, airlock, console). Each type has a default security level." position="right">
                                       <TermValue bold color={C.amber} style={{ cursor: 'help', borderBottom: '1px dotted #444' }}>
                                         {(sys.system_type || sysId).toUpperCase()}
                                       </TermValue>
                                     </Tooltip>
                                     <TermLabel style={{ marginLeft: '8px' }}>
                                       STATUS
                                     </TermLabel>
                                     <TermValue
                                       color={
                                         sys.operational
                                           ? C.green
                                           : C.redBright
                                       }
                                     >
                                       {sys.operational
                                         ? 'OPERATIONAL'
                                         : 'OFFLINE'}
                                     </TermValue>
                                   </TermRow>
                                   <TermRow>
                                     <TipLabel tip="SYS_HEALTH">HEALTH</TipLabel>
                                     <TermValue color={C.amber}>
                                       {Math.round(sys.health || 0)}%
                                     </TermValue>
                                     <TipLabel tip="SYS_SECURITY" style={{ marginLeft: '8px' }}>SECURITY LEVEL</TipLabel>
                                     <TermValue>
                                       LVL {sys.security_level || 0}
                                     </TermValue>
                                     {sys.alert_status && (
                                       <Tooltip content="Triggered when component health drops below 50%. Requires immediate attention." position="right">
                                         <TermValue
                                           color={C.redBright}
                                           style={{ marginLeft: '8px', cursor: 'help', borderBottom: '1px dotted #8b0000' }}
                                         >
                                           ALERT: {sys.alert_status}
                                         </TermValue>
                                       </Tooltip>
                                     )}
                                   </TermRow>
                                </Box>
                              ),
                            )
                          ) : (
                            <Box
                              style={term({
                                color: C.textDim,
                                fontStyle: 'italic',
                              })}
                            >
                              NO SECURITY SYSTEM DATA
                            </Box>
                          )}
                        </Box>
                      )}
                    </>
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO FACILITY DATA
                    </Box>
                  )}
                </Box>
              )}

              {/* SCP */}
              {activeTab === 'scp' && (
                <Box>
                  <TermHeader>SCP CONTAINMENT MANAGEMENT</TermHeader>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '4px',
                      marginBottom: '12px',
                      flexWrap: 'wrap',
                    }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => act('scp_view_status')}
                    >
                      VIEW STATUS
                    </TermButton>
                    <TermButton onClick={() => act('scp_save_data')}>
                      SAVE
                    </TermButton>
                    <TermButton color="red" onClick={() => act('test_systems')}>
                      CONTAINMENT CHECK
                    </TermButton>
                  </Box>
                  {scp_data ? (
                    <Box style={{ lineHeight: '1.6' }}>
                      {Object.entries(scp_data)
                        .filter(([k, v]) => typeof v !== 'object')
                        .map(([key, value]) => {
                          const scpTips = SECTION_TOOLTIPS['SCP CONTAINMENT MANAGEMENT'] || {};
                          const tip = scpTips[key];
                          return (
                            <TermRow key={key}>
                              {tip ? (
                                <Tooltip content={tip} position="right">
                                  <Box
                                    as="span"
                                    style={{
                                      color: C.textDim,
                                      fontSize: '10px',
                                      letterSpacing: '0.12em',
                                      textTransform: 'uppercase',
                                      marginRight: '8px',
                                      cursor: 'help',
                                      borderBottom: '1px dotted #444',
                                    }}
                                  >
                                    {key.replace(/_/g, ' ')}
                                  </Box>
                                </Tooltip>
                              ) : (
                                <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
                              )}
                              <TermValue
                                color={
                                  typeof value === 'number'
                                    ? C.amber
                                    : C.textBright
                                }
                              >
                                {String(value)}
                              </TermValue>
                            </TermRow>
                          );
                        })}
                    </Box>
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO SCP DATA
                    </Box>
                  )}
                </Box>
              )}

              {/* TECHNOLOGY */}
              {activeTab === 'technology' && (
                <GenericSection
                  title="TECHNOLOGY MANAGEMENT"
                  data={technology_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'technology_save_data',
                    },
                    { label: 'VIEW', action: 'technology_view_status' },
                  ]}
                />
              )}

              {/* MEDICAL */}
              {activeTab === 'medical' && (
                <GenericSection
                  title="MEDICAL RECORDS MANAGEMENT"
                  data={medical_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'medical_save_data',
                    },
                    { label: 'LOAD', action: 'medical_load_data' },
                    { label: 'VIEW', action: 'medical_view_status' },
                  ]}
                />
              )}

              {/* SECURITY */}
              {activeTab === 'security' && (
                <GenericSection
                  title="SECURITY OPERATIONS MANAGEMENT"
                  data={security_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'security_save_data',
                    },
                    { label: 'LOAD', action: 'security_load_data' },
                    {
                      label: 'SCAN',
                      color: 'yellow',
                      action: 'security_scan',
                      params: {
                        scan_data: {
                          scan_type: 'comprehensive',
                          target_systems: {
                            access_control: true,
                            surveillance: true,
                            communications: true,
                            databases: true,
                            networks: true,
                            physical_security: true,
                          },
                        },
                      },
                    },
                  ]}
                />
              )}

              {/* RESEARCH */}
              {activeTab === 'research' && (
                <Box>
                  <TermHeader>RESEARCH PROJECTS MANAGEMENT</TermHeader>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '4px',
                      marginBottom: '12px',
                      flexWrap: 'wrap',
                    }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => act('research_save_data')}
                    >
                      SAVE
                    </TermButton>
                    <TermButton onClick={() => act('research_load_data')}>
                      LOAD
                    </TermButton>
                    <TermButton onClick={() => act('research_view_status')}>
                      VIEW
                    </TermButton>
                  </Box>
                  {research_data ? (
                    <Box style={{ lineHeight: '1.6' }}>
                      {Object.entries(research_data)
                        .filter(([k, v]) => typeof v !== 'object')
                        .map(([key, value]) => {
                          const resTips = SECTION_TOOLTIPS['RESEARCH PROJECTS MANAGEMENT'] || {
                            total_projects: TOOLTIPS.RESEARCH_TOTAL,
                            completed_projects: TOOLTIPS.RESEARCH_COMPLETED,
                            active_projects: TOOLTIPS.RESEARCH_ACTIVE,
                            scientific_discoveries: TOOLTIPS.RESEARCH_DISCOVERIES,
                            publications: TOOLTIPS.RESEARCH_PUBLICATIONS,
                            research_budget: TOOLTIPS.RESEARCH_BUDGET,
                            research_efficiency: TOOLTIPS.RESEARCH_EFFICIENCY,
                            total_personnel: TOOLTIPS.RESEARCH_PERSONNEL,
                          };
                          const tip = resTips[key];
                          return (
                            <TermRow key={key}>
                              {tip ? (
                                <Tooltip content={tip} position="right">
                                  <Box
                                    as="span"
                                    style={{
                                      color: C.textDim,
                                      fontSize: '10px',
                                      letterSpacing: '0.12em',
                                      textTransform: 'uppercase',
                                      marginRight: '8px',
                                      cursor: 'help',
                                      borderBottom: '1px dotted #444',
                                    }}
                                  >
                                    {key.replace(/_/g, ' ')}
                                  </Box>
                                </Tooltip>
                              ) : (
                                <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
                              )}
                              <TermValue
                                color={
                                  typeof value === 'number'
                                    ? C.amber
                                    : C.textBright
                                }
                              >
                                {String(value)}
                              </TermValue>
                            </TermRow>
                          );
                        })}
                      {research_data.research_projects &&
                        research_data.research_projects.length > 0 && (
                          <Box>
                            <TermDivider />
                            <TermHeader>PROJECTS</TermHeader>
                            {research_data.research_projects.map((proj, idx) => (
                              <Box
                                key={proj.project_id || idx}
                                style={{
                                  marginBottom: '6px',
                                  padding: '6px 8px',
                                  borderLeft: `2px solid ${
                                    proj.status === 'COMPLETED'
                                      ? C.green
                                      : proj.status === 'ACTIVE'
                                        ? C.amber
                                        : proj.status === 'CANCELLED'
                                          ? C.redBright
                                          : C.border
                                  }`,
                                  background: C.panel,
                                }}
                              >
                                <TermRow>
                                  <TermValue bold color={C.amber}>
                                    {proj.project_name || 'Unknown'}
                                  </TermValue>
                                  <TermLabel style={{ marginLeft: '8px' }}>
                                    ID
                                  </TermLabel>
                                  <TermValue color={C.textDim}>
                                    {proj.project_id || 'N/A'}
                                  </TermValue>
                                </TermRow>
                                <TermRow>
                                  <TermLabel>STATUS</TermLabel>
                                  <TermValue
                                    color={
                                      proj.status === 'COMPLETED'
                                        ? C.green
                                        : proj.status === 'ACTIVE'
                                          ? C.amber
                                          : proj.status === 'CANCELLED'
                                            ? C.redBright
                                            : C.textBright
                                    }
                                  >
                                    {proj.status || 'UNKNOWN'}
                                  </TermValue>
                                  {proj.field && (
                                    <>
                                      <TermLabel style={{ marginLeft: '8px' }}>
                                        FIELD
                                      </TermLabel>
                                      <TermValue>{proj.field}</TermValue>
                                    </>
                                  )}
                                  {proj.lead_researcher && (
                                    <>
                                      <TermLabel style={{ marginLeft: '8px' }}>
                                        LEAD
                                      </TermLabel>
                                      <TermValue>{proj.lead_researcher}</TermValue>
                                    </>
                                  )}
                                </TermRow>
                                <TermRow>
                                  <TermLabel>PROGRESS</TermLabel>
                                  <TermValue color={C.amber}>
                                    {Math.round(proj.progress || 0)}%
                                  </TermValue>
                                  {proj.budget !== undefined && (
                                    <>
                                      <TermLabel style={{ marginLeft: '8px' }}>
                                        BUDGET
                                      </TermLabel>
                                      <TermValue>
                                        {proj.budget_used || 0}/{proj.budget || 0}
                                      </TermValue>
                                    </>
                                  )}
                                  <TermButton
                                    color="red"
                                    style={{ marginLeft: '8px' }}
                                    onClick={() =>
                                      act('research_delete_project', {
                                        project_id: proj.project_id,
                                      })
                                    }
                                  >
                                    DELETE
                                  </TermButton>
                                </TermRow>
                                {proj.description && (
                                  <Box
                                    style={{
                                      color: C.textDim,
                                      fontSize: '10px',
                                      marginTop: '2px',
                                      borderLeft: `1px solid ${C.border}`,
                                      paddingLeft: '6px',
                                    }}
                                  >
                                    {proj.description}
                                  </Box>
                                )}
                              </Box>
                            ))}
                          </Box>
                        )}
                    </Box>
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO RESEARCH DATA
                    </Box>
                  )}
                </Box>
              )}

              {/* CHEMICAL */}
              {activeTab === 'chemical' && (
                <GenericSection
                  title="CHEMICAL CONTAINMENT MANAGEMENT"
                  data={chemical_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'chemical_save_data',
                    },
                    { label: 'LOAD', action: 'chemical_load_data' },
                    { label: 'VIEW', action: 'chemical_view_records' },
                    {
                      label: 'RESEARCH',
                      color: 'green',
                      action: 'chemical_add_research',
                    },
                    {
                      label: 'CONTAINMENT',
                      color: 'yellow',
                      action: 'chemical_containment_status',
                    },
                  ]}
                />
              )}

              {/* INCIDENT */}
              {activeTab === 'incident' && (
                <GenericSection
                  title="INCIDENT RESPONSE MANAGEMENT"
                  data={incident_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'incident_save_data',
                    },
                    { label: 'LOAD', action: 'incident_load_data' },
                    { label: 'VIEW', action: 'incident_view_logs' },
                    {
                      label: 'BREACH',
                      color: 'red',
                      action: 'incident_add_breach',
                    },
                    {
                      label: 'TEAMS',
                      color: 'yellow',
                      action: 'incident_response_teams',
                    },
                  ]}
                />
              )}

              {/* PSYCHOLOGICAL */}
              {activeTab === 'psychological' && (
                <GenericSection
                  title="PSYCHOLOGICAL SERVICES MANAGEMENT"
                  data={psychological_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'psychological_save_data',
                    },
                    { label: 'LOAD', action: 'psychological_load_data' },
                    { label: 'VIEW', action: 'psychological_view_records' },
                    {
                      label: 'SESSION',
                      color: 'green',
                      action: 'psychological_add_session',
                    },
                    {
                      label: 'ASSESS',
                      color: 'yellow',
                      action: 'psychological_assessments',
                    },
                  ]}
                />
              )}

              {/* INFRASTRUCTURE */}
              {activeTab === 'infrastructure' && (
                <GenericSection
                  title="INFRASTRUCTURE MANAGEMENT"
                  data={infrastructure_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'infrastructure_save_data',
                    },
                    { label: 'LOAD', action: 'infrastructure_load_data' },
                    { label: 'VIEW', action: 'infrastructure_view_status' },
                    {
                      label: 'RESET',
                      color: 'red',
                      action: 'infrastructure_reset_data',
                    },
                  ]}
                />
              )}

              {/* ANALYTICS */}
              {activeTab === 'analytics' && (
                <GenericSection
                  title="ANALYTICS & PERFORMANCE"
                  data={analytics_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'analytics_save_data',
                    },
                    { label: 'LOAD', action: 'analytics_load_data' },
                    { label: 'VIEW', action: 'analytics_view_status' },
                    {
                      label: 'RESET',
                      color: 'red',
                      action: 'analytics_reset_data',
                    },
                  ]}
                />
              )}

              {/* PERSONNEL */}
              {activeTab === 'personnel' && (
                <GenericSection
                  title="PERSONNEL MANAGEMENT"
                  data={personnel_data}
                  act={act}
                  actions={[
                    {
                      label: 'SAVE',
                      color: 'green',
                      action: 'personnel_save_data',
                    },
                    { label: 'LOAD', action: 'personnel_load_data' },
                    { label: 'VIEW', action: 'personnel_view_status' },
                  ]}
                />
              )}

              {/* PLAYERS */}
              {activeTab === 'players' && (
                <Box>
                  <TermHeader>PLAYER DATA MANAGEMENT</TermHeader>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '4px',
                      marginBottom: '12px',
                    }}
                  >
                    <TermButton
                      color="green"
                      onClick={() => act('player_view_data')}
                    >
                      VIEW
                    </TermButton>
                    <TermButton
                      color="yellow"
                      onClick={() => act('player_export_data')}
                    >
                      DOWNLOAD
                    </TermButton>
                    <TermButton
                      color="red"
                      onClick={() => act('player_reset_progress')}
                    >
                      RESET ALL
                    </TermButton>
                  </Box>
                  {player_data && player_data.length > 0 ? (
                    player_data.map((player) => (
                      <Box
                        key={player.ckey || player.key}
                        style={{
                          marginBottom: '6px',
                          padding: '8px',
                          borderLeft: `2px solid ${C.borderRed}`,
                          background: C.panel,
                        }}
                      >
                        <TermRow>
                          <TermValue bold color={C.amber}>
                            {player.name || player.ckey}
                          </TermValue>
                          <TermLabel style={{ marginLeft: '8px' }}>
                            KEY
                          </TermLabel>
                          <TermValue color={C.textDim}>
                            {player.ckey || player.key}
                          </TermValue>
                        </TermRow>
                        {player.class && (
                          <TermRow>
                            <TermLabel>CLASS</TermLabel>
                            <TermValue>{player.class}</TermValue>
                          </TermRow>
                        )}
                        {player.rank && (
                          <TermRow>
                            <TermLabel>RANK</TermLabel>
                            <TermValue color={C.green}>{player.rank}</TermValue>
                          </TermRow>
                        )}
                        {player.experience !== undefined && (
                          <TermRow>
                            <TermLabel>XP</TermLabel>
                            <TermValue color={C.amber}>
                              {player.experience?.toLocaleString()}
                            </TermValue>
                          </TermRow>
                        )}
                        {player.rounds_played !== undefined && (
                          <TermRow>
                            <TermLabel>ROUNDS</TermLabel>
                            <TermValue>{player.rounds_played}</TermValue>
                          </TermRow>
                        )}
                        <Box
                          style={{
                            display: 'flex',
                            gap: '4px',
                            marginTop: '4px',
                          }}
                        >
                          <TermButton
                            onClick={() =>
                              act('view_progress', {
                                ckey: player.ckey || player.key,
                              })
                            }
                          >
                            VIEW
                          </TermButton>
                          <TermButton
                            color="red"
                            onClick={() =>
                              act('reset_progress', {
                                ckey: player.ckey || player.key,
                              })
                            }
                          >
                            RESET
                          </TermButton>
                        </Box>
                      </Box>
                    ))
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO PLAYER DATA
                    </Box>
                  )}
                </Box>
              )}

              {/* BUDGET */}
              {activeTab === 'budget' && (
                <Box>
                  <TermHeader>BUDGET MANAGEMENT</TermHeader>
                  <Box
                    style={{
                      display: 'flex',
                      gap: '4px',
                      marginBottom: '12px',
                      flexWrap: 'wrap',
                    }}
                  >
                    <TermButton
                      color="green"
                      onClick={() =>
                        act('budget_request_increase', {
                          request_data: {
                            department_id: 'general',
                            requested_amount: 50000,
                            requested_category: 'operational',
                            justification: 'Admin emergency request',
                            priority: 1,
                          },
                        })
                      }
                    >
                      REQUEST
                    </TermButton>
                    <TermButton
                      onClick={() =>
                        act('budget_add_transaction', {
                          transaction_data: {
                            department_id: 'general',
                            transaction_type: 'EXPENSE',
                            amount: 10000,
                            category: 'miscellaneous',
                            description: 'Admin logged transaction',
                          },
                        })
                      }
                    >
                      TRANSACTION
                    </TermButton>
                    <TermButton
                      color="yellow"
                      onClick={() =>
                        act('budget_transfer', {
                          transfer_data: {
                            from_department: 'general',
                            to_department: 'security',
                            amount: 25000,
                            reason: 'Admin budget transfer',
                          },
                        })
                      }
                    >
                      TRANSFER
                    </TermButton>
                  </Box>
                  {budget_data ? (
                    <Box style={{ lineHeight: '1.6' }}>
                      {Object.entries(budget_data)
                        .filter(([k, v]) => typeof v !== 'object')
                        .map(([key, value]) => {
                          const budgetTips = SECTION_TOOLTIPS['BUDGET SYSTEM'] || {};
                          const tip = budgetTips[key];
                          return (
                            <TermRow key={key}>
                              {tip ? (
                                <Tooltip content={tip} position="right">
                                  <Box
                                    as="span"
                                    style={{
                                      color: C.textDim,
                                      fontSize: '10px',
                                      letterSpacing: '0.12em',
                                      textTransform: 'uppercase',
                                      marginRight: '8px',
                                      cursor: 'help',
                                      borderBottom: '1px dotted #444',
                                    }}
                                  >
                                    {key.replace(/_/g, ' ')}
                                  </Box>
                                </Tooltip>
                              ) : (
                                <TermLabel>{key.replace(/_/g, ' ')}</TermLabel>
                              )}
                              <TermValue
                                color={
                                  typeof value === 'number'
                                    ? C.amber
                                    : C.textBright
                                }
                              >
                                {typeof value === 'number'
                                  ? String(value).replace(
                                      /\B(?=(\d{3})+(?!\d))/g,
                                      ',',
                                    )
                                  : String(value)}
                              </TermValue>
                            </TermRow>
                          );
                        })}
                      {budget_data.departments &&
                        Object.keys(budget_data.departments).length > 0 && (
                          <Box>
                            <TermDivider />
                            <TermHeader>DEPARTMENT BUDGETS</TermHeader>
                            {Object.entries(budget_data.departments).map(
                              ([deptId, dept]) => (
                                <Box
                                  key={deptId}
                                  style={{
                                    marginBottom: '6px',
                                    padding: '6px 8px',
                                    borderLeft: `2px solid ${C.borderRed}`,
                                    background: C.panel,
                                  }}
                                >
                                  <TermRow>
                                    <TermValue bold color={C.amber}>
                                      {(dept.name || deptId).toUpperCase()}
                                    </TermValue>
                                  </TermRow>
                                  <TermRow>
                                    <TipLabel tip="BUDGET_ALLOCATED">ALLOCATED</TipLabel>
                                    <TermValue color={C.amber}>
                                      {String(dept.allocated || 0).replace(
                                        /\B(?=(\d{3})+(?!\d))/g,
                                        ',',
                                      )}
                                    </TermValue>
                                    <TipLabel tip="BUDGET_SPENT" style={{ marginLeft: '8px' }}>SPENT</TipLabel>
                                    <TermValue color={C.redBright}>
                                      {String(dept.spent || 0).replace(
                                        /\B(?=(\d{3})+(?!\d))/g,
                                        ',',
                                      )}
                                    </TermValue>
                                    <TipLabel tip="BUDGET_REMAINING" style={{ marginLeft: '8px' }}>REMAINING</TipLabel>
                                    <TermValue color={C.green}>
                                      {String(dept.remaining || 0).replace(
                                        /\B(?=(\d{3})+(?!\d))/g,
                                        ',',
                                      )}
                                    </TermValue>
                                  </TermRow>
                                </Box>
                              ),
                            )}
                          </Box>
                        )}
                      {budget_data.pending_requests &&
                        budget_data.pending_requests.length > 0 && (
                          <Box>
                            <TermDivider />
                            <TermHeader>PENDING REQUESTS</TermHeader>
                            {budget_data.pending_requests.map((req, idx) => (
                              <TermRow key={idx}>
                                <TermValue bold color={C.amber}>
                                  {req.id}
                                </TermValue>
                                <TermLabel style={{ marginLeft: '8px' }}>
                                  DEPT
                                </TermLabel>
                                <TermValue>{req.department}</TermValue>
                                <TermLabel style={{ marginLeft: '8px' }}>
                                  AMOUNT
                                </TermLabel>
                                <TermValue color={C.amber}>
                                  {String(req.amount).replace(
                                    /\B(?=(\d{3})+(?!\d))/g,
                                    ',',
                                  )}
                                </TermValue>
                              </TermRow>
                            ))}
                          </Box>
                        )}
                    </Box>
                  ) : (
                    <Box
                      style={term({ color: C.textDim, fontStyle: 'italic' })}
                    >
                      NO BUDGET DATA
                    </Box>
                  )}
                </Box>
              )}

              {/* PROGRESSION */}
              {activeTab === 'progression' && (
                <GenericSection
                  title="PERSISTENT PROGRESSION"
                  data={data}
                  act={act}
                  actions={[
                    {
                      label: 'DOWNLOAD',
                      color: 'green',
                      action: 'progression_export_data',
                    },
                    { label: 'VIEW', action: 'progression_view_data' },
                    {
                      label: 'RESET',
                      color: 'red',
                      action: 'progression_reset_data',
                    },
                  ]}
                />
              )}

              {/* SKILL PROGRESSION */}
              {activeTab === 'skill_progression' && <SkillProgression />}
            </Box>

            {/* RIGHT: SCIPNET Sidebar */}
            <Box
              style={{
                width: '280px',
                borderLeft: `1px solid ${C.border}`,
                background: C.panel,
                padding: '10px',
                flexShrink: 0,
              }}
            >
              <TermHeader>SCIPNET</TermHeader>
              <Box
                style={term({
                  color: C.textDim,
                  fontSize: '10px',
                  lineHeight: '1.6',
                  marginBottom: '12px',
                })}
              >
                <Box style={{ color: C.redBright }}>COUNTRY: [REDACTED]</Box>
                <Box style={{ color: C.redBright }}>REGION: [REDACTED]</Box>
                <Box style={{ color: C.redBright }}>IP: [REDACTED]</Box>
              </Box>

              <TermDivider />

              <TermHeader>SYSTEM OVERVIEW</TermHeader>
              <Box
                style={term({
                  color: C.textDim,
                  fontSize: '10px',
                  lineHeight: '1.6',
                })}
              >
                <Box>
                  <StatusDot online={!!facility_data} /> FACILITY:{' '}
                  {facility_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!scp_data} /> SCP:{' '}
                  {scp_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!technology_data} /> TECH:{' '}
                  {technology_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!medical_data} /> MEDICAL:{' '}
                  {medical_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!security_data} /> SECURITY:{' '}
                  {security_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!research_data} /> RESEARCH:{' '}
                  {research_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!chemical_data} /> CHEMICAL:{' '}
                  {chemical_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!incident_data} /> INCIDENT:{' '}
                  {incident_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!psychological_data} /> PSYCH:{' '}
                  {psychological_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!infrastructure_data} /> INFRA:{' '}
                  {infrastructure_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!analytics_data} /> ANALYTICS:{' '}
                  {analytics_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!personnel_data} /> PERSONNEL:{' '}
                  {personnel_data ? 'LIVE' : 'OFFLINE'}
                </Box>
                <Box>
                  <StatusDot online={!!player_data} /> PLAYERS:{' '}
                  {player_data ? 'LIVE' : 'OFFLINE'}
                </Box>
              </Box>

              <TermDivider />

              <TermHeader>KEY METRICS</TermHeader>
              <Box
                style={term({
                  color: C.textDim,
                  fontSize: '10px',
                  lineHeight: '1.6',
                })}
              >
                <Box>
                  ACTIVE THREATS:{' '}
                  {security_data?.active_threats ?? 0}
                </Box>
                <Box>
                  OUTBREAKS:{' '}
                  {medical_data?.active_outbreaks ?? 0}
                </Box>
                <Box>
                  BREACHES:{' '}
                  {incident_data?.active_incidents ?? 0}
                </Box>
                <Box>
                  STAFF:{' '}
                  {personnel_data?.active_staff ?? 0}
                </Box>
                <Box>
                  PROJECTS:{' '}
                  {research_data?.total_research_projects ?? 0}
                </Box>
                <Box>
                  PLAYERS:{' '}
                  {player_data?.total_players ?? 0}
                </Box>
              </Box>

              <TermDivider />

              <TermHeader>LIVE ALERTS</TermHeader>
              <Box
                style={{
                  padding: '6px 8px',
                  borderLeft: `2px solid ${C.green}`,
                  background: 'rgba(26,122,26,0.15)',
                }}
              >
                <Box style={term({ color: C.green, fontSize: '10px' })}>
                  ALL SYSTEMS OPERATIONAL
                </Box>
              </Box>

              <TermDivider />

              <TermHeader>TERMINAL</TermHeader>
              <Box
                style={term({
                  color: C.textDim,
                  fontSize: '9px',
                  lineHeight: '1.6',
                })}
              >
                <Box>LINK: NOMINAL</Box>
                <Box>NET: SECURE</Box>
                <Box>CRYPTO: AES-512</Box>
                <Box>
                  STATUS:{' '}
                  <Box as="span" style={{ color: C.green }}>
                    ONLINE
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>

          {/* FOOTER */}
          <Box
            style={{
              borderTop: `1px solid ${C.border}`,
              padding: '4px 14px',
              background: C.panel,
            }}
          >
            <Box
              style={term({
                color: C.textDim,
                fontSize: '9px',
                letterSpacing: '0.1em',
              })}
            >
              SCP FOUNDATION | PERSISTENCE CONTROL | ALL ACTIONS LOGGED |
              UNAUTHORIZED ACCESS IS A CLASS-A INFRACTION
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
