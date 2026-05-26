import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  cases: LegalCase[];
  total_cases: number;
  resolved_cases: number;
};

type LegalCase = {
  case_id: string;
  defendant: string;
  defendant_job: string;
  plaintiff: string;
  case_type: string;
  charges: string;
  defense: string;
  status: string;
  verdict: string;
  sentencing: string;
  time: number;
};

export const ScpLegalConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { cases, total_cases, resolved_cases } = data;
  const [legalDefendant, setLegalDefendant] = useState('');
  const [legalType, setLegalType] = useState('');
  const [legalCharges, setLegalCharges] = useState('');

  return (
    <NtosWindow width={700} height={600}>
      <NtosWindow.Content scrollable>
        <Section title="LEGAL RECORDS — FOUNDATION LAW">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            TOTAL CASES: {total_cases} | RESOLVED: {resolved_cases}
          </Box>
        </Section>

        <Section title="FILE CASE">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <Box style={{ display: 'flex', gap: '6px' }}>
              <Input placeholder="Defendant name..." value={legalDefendant} onInput={(_e, value: string) => setLegalDefendant(value)} style={{ width: '150px' }} />
              <Input placeholder="Case type (civil/criminal/tribunal)..." value={legalType} onInput={(_e, value: string) => setLegalType(value)} style={{ width: '180px' }} />
            </Box>
            <TextArea placeholder="Charges..." value={legalCharges} onInput={(_e, value: string) => setLegalCharges(value)} rows={2} />
            <Button
              onClick={() => {
                act('file_case', { defendant: legalDefendant, case_type: legalType, charges: legalCharges });
                setLegalDefendant('');
                setLegalType('');
                setLegalCharges('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '4px 12px', alignSelf: 'flex-start' }}
            >
              FILE CASE
            </Button>
          </Box>
        </Section>

        <Section title="CASES">
          {cases.map((c) => (
            <Box key={c.case_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: `2px solid ${c.status === 'resolved' ? '#6a6a70' : '#d4a017'}`, background: '#111114' }}>
              <Box style={{ color: c.status === 'resolved' ? '#6a6a70' : '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                {c.case_id} — {c.defendant}
              </Box>
              <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                Type: {c.case_type} | Plaintiff: {c.plaintiff} | Status: {c.status}
              </Box>
              <Box style={{ fontSize: '10px', color: '#8a8a90' }}>Charges: {c.charges}</Box>
              {c.defense && <Box style={{ fontSize: '10px', color: '#4488ff' }}>Defense: {c.defense}</Box>}
              {c.verdict && <Box style={{ fontSize: '10px', color: '#44ff44' }}>Verdict: {c.verdict}</Box>}
              {c.sentencing && <Box style={{ fontSize: '10px', color: '#cc2222' }}>Sentencing: {c.sentencing}</Box>}
              {c.status !== 'resolved' && (
                <Box style={{ display: 'flex', gap: '4px', marginTop: '4px' }}>
                  <Button
                    onClick={() => act('submit_defense', { case_id: c.case_id, defense: 'Defense submitted' })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '2px 8px' }}
                  >
                    SUBMIT DEFENSE
                  </Button>
                  <Button
                    onClick={() => act('render_verdict', { case_id: c.case_id, verdict: 'Guilty', notes: 'Evidence sufficient', sentencing: 'Reprimand' })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '2px 8px' }}
                  >
                    GUILTY
                  </Button>
                  <Button
                    onClick={() => act('render_verdict', { case_id: c.case_id, verdict: 'Not Guilty', notes: 'Insufficient evidence', sentencing: '' })}
                    style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px' }}
                  >
                    NOT GUILTY
                  </Button>
                </Box>
              )}
            </Box>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
