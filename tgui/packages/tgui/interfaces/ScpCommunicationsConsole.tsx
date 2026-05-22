import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input, TextArea } from '../components';
import { Window } from '../layouts';

type Data = {
  dispatches: Dispatch[];
  threats: Threat[];
  facility_threat_level: number;
  active_dispatches: number;
  resolved_dispatches: number;
  total_announcements: number;
};

type Dispatch = {
  dispatch_id: string;
  type: string;
  caller: string;
  location: string;
  message: string;
  priority: number;
  responded: BooleanLike;
  responder_count: number;
  time: number;
};

type Threat = {
  threat_id: string;
  name: string;
  type: string;
  level: string;
  level_num: number;
  location: string;
  description: string;
  resolved: BooleanLike;
  resolved_by: string;
  time: number;
};

const THREAT_COLORS: Record<number, string> = {
  0: '#44ff44',
  1: '#d4a017',
  2: '#ff8800',
  3: '#cc2222',
};

export const ScpCommunicationsConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { dispatches, threats, facility_threat_level, active_dispatches, resolved_dispatches, total_announcements } = data;
  const [dispatchMessage, setDispatchMessage] = useState('');
  const [announcementText, setAnnouncementText] = useState('');

  return (
    <Window theme="scp_terminal" width={700} height={650}>
      <Window.Content scrollable>
        <Section title="COMMUNICATIONS CENTER">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            FACILITY THREAT LEVEL:
            <Box as="span" style={{ color: THREAT_COLORS[facility_threat_level] || '#c8c8c8', fontWeight: 'bold', marginLeft: '8px' }}>
              {['GREEN', 'YELLOW', 'ORANGE', 'RED'][facility_threat_level] || 'UNKNOWN'}
            </Box>
          </Box>
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70' }}>
            ACTIVE DISPATCHES: {active_dispatches} | RESOLVED: {resolved_dispatches} | ANNOUNCEMENTS: {total_announcements}
          </Box>
        </Section>

        <Section title="CREATE DISPATCH">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <Box style={{ display: 'flex', gap: '6px' }}>
              {[
                { type: 1, label: 'SECURITY', color: '#cc2222' },
                { type: 2, label: 'MEDICAL', color: '#4488ff' },
                { type: 3, label: 'ENGINEERING', color: '#d4a017' },
                { type: 4, label: 'MTF', color: '#cc2222' },
              ].map((d) => (
                <Button
                  key={d.type}
                  onClick={() => {
                    act('dispatch', { dispatch_type: d.type, message: dispatchMessage || 'Assistance required', priority: 0 });
                    setDispatchMessage('');
                  }}
                  style={{ fontFamily: 'monospace', fontSize: '9px', background: 'transparent', border: `1px solid ${d.color}`, color: d.color, padding: '2px 8px' }}
                >
                  {d.label}
                </Button>
              ))}
            </Box>
            <TextArea placeholder="Dispatch message..." value={dispatchMessage} onInput={(_e, value: string) => setDispatchMessage(value)} rows={2} />
          </Box>
        </Section>

        <Section title="MAKE ANNOUNCEMENT">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <TextArea placeholder="Announcement text..." value={announcementText} onInput={(_e, value: string) => setAnnouncementText(value)} rows={2} />
            <Box style={{ display: 'flex', gap: '6px' }}>
              <Button
                onClick={() => {
                  act('make_announcement', { message: announcementText, priority: '0' });
                  setAnnouncementText('');
                }}
                style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '2px 8px' }}
              >
                STANDARD
              </Button>
              <Button
                onClick={() => {
                  act('make_announcement', { message: announcementText, priority: '1' });
                  setAnnouncementText('');
                }}
                style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '2px 8px' }}
              >
                PRIORITY
              </Button>
            </Box>
          </Box>
        </Section>

        <Section title="ACTIVE DISPATCHES">
          {dispatches.map((d) => (
            <Box key={d.dispatch_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: `2px solid ${d.responded ? '#44ff44' : '#d4a017'}`, background: '#111114' }}>
              <Box style={{ color: d.responded ? '#44ff44' : '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                {d.dispatch_id} — {d.type}
              </Box>
              <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                Caller: {d.caller} | Location: {d.location}
              </Box>
              <Box style={{ fontSize: '10px', color: '#8a8a90' }}>{d.message}</Box>
              {!d.responded && (
                <Button
                  onClick={() => act('respond_dispatch', { dispatch_id: d.dispatch_id })}
                  style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px', marginTop: '4px' }}
                >
                  RESPOND
                </Button>
              )}
            </Box>
          ))}
        </Section>

        {threats.length > 0 && (
          <Section title="FACILITY THREATS">
            {threats.map((t) => (
              <Box key={t.threat_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: `2px solid ${THREAT_COLORS[t.level_num] || '#6a6a70'}`, background: '#111114' }}>
                <Box style={{ color: THREAT_COLORS[t.level_num], fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                  {t.name} — {t.level}
                </Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                  Type: {t.type} | Location: {t.location}
                </Box>
                <Box style={{ fontSize: '10px', color: '#8a8a90' }}>{t.description}</Box>
                {!t.resolved && (
                  <Button
                    onClick={() => act('resolve_threat', { threat_id: t.threat_id })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px', marginTop: '4px' }}
                  >
                    RESOLVE
                  </Button>
                )}
                {t.resolved && <Box style={{ fontSize: '10px', color: '#44ff44', fontFamily: 'monospace', marginTop: '4px' }}>RESOLVED by {t.resolved_by}</Box>}
              </Box>
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
