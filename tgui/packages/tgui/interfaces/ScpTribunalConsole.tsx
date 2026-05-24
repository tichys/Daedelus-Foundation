import { BooleanLike } from 'common/react';
import React, { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Input, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  cases: Case[];
  total_cases: number;
  active_case: BooleanLike;
};

type Case = {
  case_id: string;
  defendant: string;
  prosecutor: string;
  charges: string;
  evidence: string;
  status: string;
  status_num: number;
  sanction: string;
  time: number;
  deliberation_progress: number;
};

const STATUS_COLORS: Record<number, string> = {
  0: '#d4a017',
  1: '#ff8800',
  2: '#4488ff',
  3: '#cc2222',
  4: '#44ff44',
  5: '#6a6a70',
};

export const ScpTribunalConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { cases, total_cases, active_case } = data;
  const [tribunalDefendant, setTribunalDefendant] = useState('');
  const [tribunalCharges, setTribunalCharges] = useState('');
  const [tribunalEvidence, setTribunalEvidence] = useState('');

  return (
    <NtosWindow width={700} height={600}>
      <NtosWindow.Content scrollable>
        <Section title="INTERNAL TRIBUNAL DEPARTMENT">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            TOTAL CASES: {total_cases} | {active_case ? 'HEARING IN SESSION' : 'NO ACTIVE HEARING'}
          </Box>
        </Section>

        <Section title="FILE NEW CASE">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <Input placeholder="Defendant name..." value={tribunalDefendant} onInput={(_e, value: string) => setTribunalDefendant(value)} />
            <Input placeholder="Charges..." value={tribunalCharges} onInput={(_e, value: string) => setTribunalCharges(value)} />
            <TextArea placeholder="Evidence summary..." value={tribunalEvidence} onInput={(_e, value: string) => setTribunalEvidence(value)} rows={3} style={{ lineHeight: '1.5' }} />
            <Button
              onClick={() => {
                act('file_case', { defendant: tribunalDefendant, charges: tribunalCharges, evidence: tribunalEvidence });
                setTribunalDefendant('');
                setTribunalCharges('');
                setTribunalEvidence('');
              }}
              style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '4px 12px', alignSelf: 'flex-start' }}
            >
              FILE CASE
            </Button>
          </Box>
        </Section>

        <Section title="ACTIVE CASES">
          {cases.map((c) => (
            <Box key={c.case_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: `2px solid ${STATUS_COLORS[c.status_num] || '#6a6a70'}`, background: '#111114' }}>
              <Box style={{ color: STATUS_COLORS[c.status_num], fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                {c.case_id} — {c.defendant}
              </Box>
              <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                Charges: {c.charges} | Status: {c.status}
              </Box>
              {c.evidence && <Box style={{ fontSize: '10px', color: '#8a8a90' }}>Evidence: {c.evidence}</Box>}
              {c.sanction && <Box style={{ fontSize: '10px', color: '#cc2222' }}>Sanction: {c.sanction}</Box>}
              <Box style={{ display: 'flex', gap: '4px', marginTop: '4px' }}>
                {c.status_num === 0 && (
                  <Button
                    onClick={() => act('begin_hearing', { case_id: c.case_id })}
                    style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(212,160,23,0.2)', border: '1px solid #d4a017', color: '#d4a017', padding: '4px 10px' }}
                  >
                    BEGIN HEARING
                  </Button>
                )}
                {c.status_num === 1 && (
                  <Button
                    onClick={() => act('enter_deliberation', { case_id: c.case_id })}
                    style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,136,255,0.2)', border: '1px solid #4488ff', color: '#4488ff', padding: '4px 10px' }}
                  >
                    ENTER DELIBERATION
                  </Button>
                )}
                {c.status_num === 2 && (
                  <>
                    <Button
                      onClick={() => act('render_verdict', { case_id: c.case_id, guilty: true, sanction: 1, sanction_text: 'Formal Reprimand' })}
                      style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '4px 10px' }}
                    >
                      GUILTY
                    </Button>
                    <Button
                      onClick={() => act('render_verdict', { case_id: c.case_id, guilty: false, sanction: 0, sanction_text: '' })}
                      style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '4px 10px' }}
                    >
                      NOT GUILTY
                    </Button>
                    <Button
                      onClick={() => act('dismiss_case', { case_id: c.case_id })}
                      style={{ fontFamily: 'monospace', fontSize: '11px', background: 'rgba(106,106,112,0.2)', border: '1px solid #6a6a70', color: '#6a6a70', padding: '4px 10px' }}
                    >
                      DISMISS
                    </Button>
                  </>
                )}
              </Box>
            </Box>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
