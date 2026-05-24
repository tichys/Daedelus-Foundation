import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, TextArea, Input } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  reports: IntelReport[];
  subjects: Subject[];
  breaches: InfoBreach[];
  total_reports: number;
  active_breaches: number;
  contained_breaches: number;
};

type IntelReport = {
  report_id: string;
  analyst: string;
  type: string;
  target: string;
  classification: string;
  findings: string;
  recommendations: string;
  status: string;
  time: number;
};

type Subject = {
  name: string;
  job: string;
  threat: number;
  observations: number;
  incidents: number;
  flagged: BooleanLike;
  flag_reason: string;
  last_observed: number;
};

type InfoBreach = {
  breach_id: string;
  type: string;
  source: string;
  data: string;
  severity: number;
  contained: BooleanLike;
  notes: string;
  time: number;
};

const THREAT_COLOR = (t: number) => (t > 70 ? '#cc2222' : t > 40 ? '#ff8800' : t > 15 ? '#d4a017' : '#44ff44');

export const ScpRaisaTerminal = (props) => {
  const { act, data } = useBackend<Data>();
  const { reports, subjects, breaches, total_reports, active_breaches, contained_breaches } = data;
  const [raisaTarget, setRaisaTarget] = useState('');
  const [raisaTargetJob, setRaisaTargetJob] = useState('');
  const [raisaType, setRaisaType] = useState('');
  const [raisaClass, setRaisaClass] = useState('');
  const [raisaFindings, setRaisaFindings] = useState('');
  const [raisaRecs, setRaisaRecs] = useState('');

  return (
    <NtosWindow width={700} height={650}>
      <NtosWindow.Content scrollable>
        <Section title="RAISA — RECORDS AND INFORMATION SECURITY">
          <Box style={{ fontFamily: 'monospace', fontSize: '12px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '12px', lineHeight: '1.5' }}>
            REPORTS: {total_reports} | ACTIVE BREACHES: {active_breaches} | CONTAINED: {contained_breaches}
          </Box>
        </Section>

        <Section title="FILE INTELLIGENCE REPORT" style={{ marginBottom: '8px' }}>
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <Box style={{ display: 'flex', gap: '6px' }}>
              <Input placeholder="Target name..." value={raisaTarget} onInput={(_e, value: string) => setRaisaTarget(value)} style={{ width: '200px' }} />
              <Input placeholder="Target job..." value={raisaTargetJob} onInput={(_e, value: string) => setRaisaTargetJob(value)} style={{ width: '160px' }} />
            </Box>
            <Box style={{ display: 'flex', gap: '6px' }}>
              <Input placeholder="Report type..." value={raisaType} onInput={(_e, value: string) => setRaisaType(value)} style={{ width: '160px' }} />
              <Input placeholder="Classification..." value={raisaClass} onInput={(_e, value: string) => setRaisaClass(value)} style={{ width: '160px' }} />
            </Box>
            <TextArea placeholder="Findings..." value={raisaFindings} onInput={(_e, value: string) => setRaisaFindings(value)} rows={2} />
            <TextArea placeholder="Recommendations..." value={raisaRecs} onInput={(_e, value: string) => setRaisaRecs(value)} rows={2} />
            <Button
              onClick={() => {
                act('file_report', { target: raisaTarget, target_job: raisaTargetJob, report_type: raisaType, classification: raisaClass, findings: raisaFindings, recommendations: raisaRecs });
                setRaisaTarget('');
                setRaisaTargetJob('');
                setRaisaType('');
                setRaisaClass('');
                setRaisaFindings('');
                setRaisaRecs('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '8px 12px', alignSelf: 'flex-start' }}
            >
              FILE REPORT
            </Button>
          </Box>
        </Section>

        <Section title="SURVEILLANCE SUBJECTS" style={{ marginBottom: '8px' }}>
          {subjects.map((s) => (
            <Box key={s.name} style={{ padding: '12px', marginBottom: '8px', borderLeft: `2px solid ${THREAT_COLOR(s.threat)}`, background: '#111114' }}>
              <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Box>
                  <Box style={{ color: THREAT_COLOR(s.threat), fontWeight: 'bold', fontFamily: 'monospace', fontSize: '13px' }}>
                    {s.name} {s.flagged ? '[FLAGGED]' : ''}
                  </Box>
                  <Box style={{ fontSize: '12px', color: '#c8c8c8', lineHeight: '1.5' }}>
                    {s.job} | Threat: {s.threat} | Observations: {s.observations} | Incidents: {s.incidents}
                  </Box>
                  {s.flag_reason && <Box style={{ fontSize: '12px', color: '#cc2222', lineHeight: '1.5' }}>Reason: {s.flag_reason}</Box>}
                </Box>
                <Box style={{ display: 'flex', gap: '4px' }}>
                  <Button
                    onClick={() => act('observe_person', { target: s.name })}
                    style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '6px 8px' }}
                  >
                    OBSERVE
                  </Button>
                  {!s.flagged && (
                    <Button
                      onClick={() => act('flag_person', { target: s.name, reason: 'Suspicious activity' })}
                      style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '6px 8px' }}
                    >
                      FLAG
                    </Button>
                  )}
                </Box>
              </Box>
            </Box>
          ))}
        </Section>

        {breaches.length > 0 && (
          <Section title="INFORMATION BREACHES">
            {breaches.map((b) => (
              <Box key={b.breach_id} style={{ padding: '12px', marginBottom: '8px', borderLeft: `2px solid ${b.contained ? '#44ff44' : '#cc2222'}`, background: '#111114' }}>
                <Box style={{ color: b.contained ? '#44ff44' : '#cc2222', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '13px' }}>
                  {b.breach_id} — {b.type} [Severity: {b.severity}]
                </Box>
                <Box style={{ fontSize: '12px', color: '#c8c8c8', lineHeight: '1.5' }}>
                  Source: {b.source} | Data: {b.data}
                </Box>
                {!b.contained && (
                  <Button
                    onClick={() => act('contain_breach', { breach_id: b.breach_id, notes: 'Contained by RAISA' })}
                    style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '6px 8px', marginTop: '8px' }}
                  >
                    CONTAIN
                  </Button>
                )}
                {b.contained && <Box style={{ fontSize: '12px', color: '#44ff44', fontFamily: 'monospace', marginTop: '8px', lineHeight: '1.5' }}>CONTAINED</Box>}
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
