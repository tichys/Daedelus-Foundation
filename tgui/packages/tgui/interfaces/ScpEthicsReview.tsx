import { BooleanLike } from 'common/react';
import React from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Input, TextArea } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  violations: Violation[];
  test_oversights: TestOversight[];
  pending_count: number;
  total_reviews: number;
  upheld_count: number;
  dismissed_count: number;
};

type Violation = {
  violation_id: string;
  reporter: string;
  accused: string;
  type: string;
  severity: string;
  severity_num: number;
  description: string;
  status: string;
  status_num: number;
  notes: string;
  time: number;
};

type TestOversight = {
  test_id: string;
  scp_name: string;
  researcher: string;
  risk_level: number;
  approved: BooleanLike;
  denied: BooleanLike;
  time: number;
};

const SEVERITY_COLORS: Record<number, string> = {
  1: '#44ff44',
  2: '#d4a017',
  3: '#ff8800',
  4: '#cc2222',
};

export const ScpEthicsReview = (props) => {
  const { act, data } = useBackend<Data>();
  const { violations, test_oversights, pending_count, total_reviews, upheld_count, dismissed_count } = data;

  return (
    <NtosWindow width={700} height={600}>
      <NtosWindow.Content scrollable>
        <Section title="ETHICS COMMITTEE — VIOLATION REVIEW">
          <Box style={{ fontFamily: 'monospace', fontSize: '10px', color: '#6a6a70', letterSpacing: '0.1em', marginBottom: '8px' }}>
            PENDING: {pending_count} | REVIEWS: {total_reviews} | UPHELD: {upheld_count} | DISMISSED: {dismissed_count}
          </Box>
          {violations.map((v) => (
            <Box key={v.violation_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: `2px solid ${SEVERITY_COLORS[v.severity_num] || '#6a6a70'}`, background: '#111114' }}>
              <Box style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Box>
                  <Box style={{ color: SEVERITY_COLORS[v.severity_num], fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                    {v.violation_id} — {v.type}
                  </Box>
                  <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                    Reporter: {v.reporter} | Accused: {v.accused} | Status: {v.status}
                  </Box>
                  <Box style={{ fontSize: '10px', color: '#8a8a90' }}>{v.description}</Box>
                  {v.notes && <Box style={{ fontSize: '9px', color: '#6a6a70' }}>Notes: {v.notes}</Box>}
                </Box>
                {v.status_num < 2 && (
                  <Box style={{ display: 'flex', gap: '4px', alignItems: 'flex-start' }}>
                    <Button
                      onClick={() => act('review_uphold', { violation_id: v.violation_id, notes: '' })}
                      style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '2px 8px' }}
                    >
                      UPHOLD
                    </Button>
                    <Button
                      onClick={() => act('review_dismiss', { violation_id: v.violation_id, notes: '' })}
                      style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px' }}
                    >
                      DISMISS
                    </Button>
                  </Box>
                )}
              </Box>
            </Box>
          ))}
        </Section>

        <Section title="FILE VIOLATION">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <LabeledList>
              <LabeledList.Item label="Accused">
                <Input placeholder="Name of accused..." onChange={(_, value) => act('file_violation', { accused: value, violation_type: 'Unethical Conduct', description: 'Pending review', severity: 1 })} />
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </Section>

        {test_oversights.length > 0 && (
          <Section title="TEST OVERSIGHT — HIGH-RISK EXPERIMENTS">
            {test_oversights.map((t) => (
              <Box key={t.test_id} style={{ padding: '8px', marginBottom: '6px', borderLeft: '2px solid #d4a017', background: '#111114' }}>
                <Box style={{ color: '#d4a017', fontWeight: 'bold', fontFamily: 'monospace', fontSize: '12px' }}>
                  {t.test_id} — {t.scp_name}
                </Box>
                <Box style={{ fontSize: '10px', color: '#c8c8c8' }}>
                  Researcher: {t.researcher} | Risk Level: {t.risk_level}
                </Box>
                {!t.approved && !t.denied && (
                  <Box style={{ display: 'flex', gap: '4px', marginTop: '4px' }}>
                    <Button
                      onClick={() => act('approve_test', { test_id: t.test_id })}
                      style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(68,255,68,0.1)', border: '1px solid #44ff44', color: '#44ff44', padding: '2px 8px' }}
                    >
                      APPROVE
                    </Button>
                    <Button
                      onClick={() => act('deny_test', { test_id: t.test_id })}
                      style={{ fontFamily: 'monospace', fontSize: '9px', background: 'rgba(139,0,0,0.3)', border: '1px solid #8b0000', color: '#cc2222', padding: '2px 8px' }}
                    >
                      DENY
                    </Button>
                  </Box>
                )}
                {t.approved && <Box style={{ fontSize: '10px', color: '#44ff44', fontFamily: 'monospace' }}>APPROVED</Box>}
                {t.denied && <Box style={{ fontSize: '10px', color: '#cc2222', fontFamily: 'monospace' }}>DENIED</Box>}
              </Box>
            ))}
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
