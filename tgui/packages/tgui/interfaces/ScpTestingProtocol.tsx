import React, { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Input } from '../components';
import { NtosWindow } from '../layouts';

const C = {
  bg: '#0a0a0c',
  panel: '#111114',
  border: '#2a2a30',
  red: '#8b0000',
  darkRed: '#5c0000',
  amber: '#d4a017',
  green: '#0a6e0a',
  brightGreen: '#44ff44',
  text: '#c8c8c8',
  dim: '#6a6a70',
  highlight: '#e8e8e8',
};

const statusColor = (status) => {
  switch (status) {
    case 0: return C.amber;
    case 1: return C.green;
    case 2: return '#00b5b5';
    case 3: return C.dim;
    case 4: return C.red;
    default: return C.dim;
  }
};

const statusLabel = (status) => {
  switch (status) {
    case 0: return 'PENDING';
    case 1: return 'APPROVED';
    case 2: return 'IN PROGRESS';
    case 3: return 'COMPLETE';
    case 4: return 'REJECTED';
    default: return 'UNKNOWN';
  }
};

const riskColor = (risk) => {
  if (risk <= 2) return C.green;
  if (risk === 3) return C.amber;
  return C.red;
};

export const ScpTestingProtocol = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    test_proposals = [],
    active_tests = [],
    completed_tests = [],
    researcher_stats,
    total_tests_conducted,
    total_research_earned,
    total_incidents_during_tests,
    pending_count,
  } = data;

  const [scpId, setScpId] = useState('');
  const [testType, setTestType] = useState('');
  const [riskLevel, setRiskLevel] = useState(1);
  const [subjectName, setSubjectName] = useState('');
  const [description, setDescription] = useState('');

  return (
    <NtosWindow width={700} height={700}>
      <NtosWindow.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack justify="space-between" align="center">
                <Stack.Item>
                  <Box fontSize="18px" fontFamily="monospace" color={C.brightGreen} bold>
                    SCP TESTING PROTOCOL
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={2}>
                    <Box fontFamily="monospace" color={C.dim}>
                      CONDUCTED: <Box as="span" color={C.highlight}>{total_tests_conducted}</Box>
                    </Box>
                    <Box fontFamily="monospace" color={C.dim}>
                      RESEARCH: <Box as="span" color={C.amber}>{total_research_earned}</Box>
                    </Box>
                    <Box fontFamily="monospace" color={C.dim}>
                      INCIDENTS: <Box as="span" color={C.red}>{total_incidents_during_tests}</Box>
                    </Box>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.amber}>
                  PENDING PROPOSALS ({pending_count})
                </Box>
              }
            >
              {test_proposals.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO PENDING PROPOSALS
                </Box>
              )}
              {test_proposals.map((proposal) => (
                <Box key={proposal.proposal_id} py={1} borderBottom={`1px solid ${C.border}`}>
                  <Stack justify="space-between" align="center">
                    <Stack.Item grow>
                      <Stack vertical>
                        <Stack.Item>
                          <Stack gap={1} align="center">
                            <Box fontFamily="monospace" color={C.highlight} bold>
                              #{proposal.proposal_id}
                            </Box>
                            <Box fontFamily="monospace" color={C.dim}>|</Box>
                            <Box fontFamily="monospace" color={C.amber}>{proposal.scp_id}</Box>
                            <Box fontFamily="monospace" color={C.dim}>|</Box>
                            <Box fontFamily="monospace" color={C.text}>{proposal.test_type}</Box>
                            <Box fontFamily="monospace" color={C.dim}>|</Box>
                            <Box
                              fontFamily="monospace"
                              bold
                              backgroundColor={riskColor(proposal.risk_level)}
                              color={C.highlight}
                              px={1}
                            >
                              RISK-{proposal.risk_level}
                            </Box>
                            <Box
                              fontFamily="monospace"
                              backgroundColor={statusColor(proposal.status)}
                              color={C.bg}
                              px={1}
                              bold
                            >
                              {statusLabel(proposal.status)}
                            </Box>
                            {proposal.ethics_required === 1 && (
                              <Box
                                fontFamily="monospace"
                                backgroundColor={C.red}
                                color={C.highlight}
                                px={1}
                                bold
                              >
                                ETHICS REVIEW
                              </Box>
                            )}
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Box fontFamily="monospace" color={C.dim}>
                            Subject: <Box as="span" color={C.text}>{proposal.subject_name}</Box>
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box fontFamily="monospace" color={C.dim} italic>
                            {proposal.description}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box fontFamily="monospace" color={C.dim} fontSize="11px">
                            By: {proposal.researcher} | Submitted: {proposal.time_submitted}
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Stack vertical>
                        {proposal.status === 0 && (
                          <>
                            <Button
                              fontFamily="monospace"
                              backgroundColor={C.green}
                              color={C.highlight}
                              content="APPROVE"
                              onClick={() => act('approve_proposal', { proposal_id: proposal.proposal_id })}
                            />
                            <Button
                              fontFamily="monospace"
                              backgroundColor={C.red}
                              color={C.highlight}
                              content="REJECT"
                              onClick={() => act('reject_proposal', { proposal_id: proposal.proposal_id })}
                            />
                          </>
                        )}
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color="#00b5b5">
                  ACTIVE TESTS
                </Box>
              }
            >
              {active_tests.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO ACTIVE TESTS
                </Box>
              )}
              {active_tests.map((test) => (
                <Box key={test.proposal_id} py={1} borderBottom={`1px solid ${C.border}`}>
                  <Stack justify="space-between" align="center">
                    <Stack.Item grow>
                      <Stack vertical>
                        <Stack.Item>
                          <Stack gap={1} align="center">
                            <Box fontFamily="monospace" color={C.highlight} bold>
                              #{test.proposal_id}
                            </Box>
                            <Box fontFamily="monospace" color={C.dim}>|</Box>
                            <Box fontFamily="monospace" color={C.amber}>{test.scp_id}</Box>
                            <Box fontFamily="monospace" color={C.dim}>|</Box>
                            <Box fontFamily="monospace" color={C.text}>{test.test_type}</Box>
                            <Box
                              fontFamily="monospace"
                              backgroundColor={riskColor(test.risk_level)}
                              color={C.highlight}
                              px={1}
                              bold
                            >
                              RISK-{test.risk_level}
                            </Box>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Box fontFamily="monospace" color={C.dim}>
                            Subject: <Box as="span" color={C.text}>{test.subject_name}</Box>
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box fontFamily="monospace" color={C.dim} fontSize="11px">
                            Approved: {test.time_approved}
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Stack vertical>
                        {test.status === 1 && (
                          <Button
                            fontFamily="monospace"
                            backgroundColor="#00b5b5"
                            color={C.bg}
                            content="START TEST"
                            onClick={() => act('start_test', { proposal_id: test.proposal_id })}
                          />
                        )}
                        {test.status === 2 && (
                          <>
                            <Button
                              fontFamily="monospace"
                              backgroundColor={C.brightGreen}
                              color={C.bg}
                              content="EXECUTE"
                              onClick={() => act('execute_test', { proposal_id: test.proposal_id })}
                            />
                            <Button
                              fontFamily="monospace"
                              backgroundColor={C.red}
                              color={C.highlight}
                              content="CANCEL"
                              onClick={() => act('cancel_test', { proposal_id: test.proposal_id })}
                            />
                          </>
                        )}
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.dim}>
                  COMPLETED TESTS
                </Box>
              }
            >
              {completed_tests.length === 0 && (
                <Box fontFamily="monospace" color={C.dim} textAlign="center" py={2}>
                  NO COMPLETED TESTS
                </Box>
              )}
              {completed_tests.slice(0, 15).map((test) => (
                <Box key={test.proposal_id} py={1} borderBottom={`1px solid ${C.border}`}>
                  <Stack vertical>
                    <Stack.Item>
                      <Stack gap={1} align="center">
                        <Box fontFamily="monospace" color={C.dim} bold>#{test.proposal_id}</Box>
                        <Box fontFamily="monospace" color={C.dim}>|</Box>
                        <Box fontFamily="monospace" color={C.amber}>{test.scp_id}</Box>
                        <Box fontFamily="monospace" color={C.dim}>|</Box>
                        <Box fontFamily="monospace" color={C.text}>{test.test_type}</Box>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Box fontFamily="monospace" color={C.dim}>
                        Outcome: <Box as="span" color={C.highlight}>{test.outcome}</Box>
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Stack gap={2}>
                        <Box fontFamily="monospace" color={C.amber}>
                          +{test.research_points} RP
                        </Box>
                        <Box fontFamily="monospace" color={C.dim} fontSize="11px">
                          Completed: {test.time_completed}
                        </Box>
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={
                <Box fontFamily="monospace" color={C.brightGreen}>
                  SUBMIT PROPOSAL
                </Box>
              }
            >
              <Stack vertical gap={1}>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="120px">SCP ID:</Box>
                    <Input
                      fontFamily="monospace"
                      backgroundColor={C.panel}
                      borderColor={C.border}
                      color={C.text}
                      value={scpId}
                      onInput={(_e, val) => setScpId(val)}
                      fluid
                    />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="120px">TEST TYPE:</Box>
                    <Input
                      fontFamily="monospace"
                      backgroundColor={C.panel}
                      borderColor={C.border}
                      color={C.text}
                      value={testType}
                      onInput={(_e, val) => setTestType(val)}
                      fluid
                    />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="120px">RISK LEVEL:</Box>
                    <Stack gap={0.5}>
                      {[1, 2, 3, 4, 5].map((lvl) => (
                        <Button
                          key={lvl}
                          fontFamily="monospace"
                          backgroundColor={riskLevel === lvl ? riskColor(lvl) : C.panel}
                          color={riskLevel === lvl ? C.highlight : C.dim}
                          content={String(lvl)}
                          onClick={() => setRiskLevel(lvl)}
                        />
                      ))}
                    </Stack>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="120px">SUBJECT:</Box>
                    <Input
                      fontFamily="monospace"
                      backgroundColor={C.panel}
                      borderColor={C.border}
                      color={C.text}
                      value={subjectName}
                      onInput={(_e, val) => setSubjectName(val)}
                      fluid
                    />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack gap={1} align="center">
                    <Box fontFamily="monospace" color={C.dim} width="120px">DESCRIPTION:</Box>
                    <Input
                      fontFamily="monospace"
                      backgroundColor={C.panel}
                      borderColor={C.border}
                      color={C.text}
                      value={description}
                      onInput={(_e, val) => setDescription(val)}
                      fluid
                    />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fontFamily="monospace"
                    backgroundColor={C.brightGreen}
                    color={C.bg}
                    bold
                    content="SUBMIT PROPOSAL"
                    fluid
                    onClick={() => {
                      act('submit_proposal', {
                        scp_id: scpId,
                        test_type: testType,
                        risk_level: riskLevel,
                        subject_name: subjectName,
                        description: description,
                      });
                      setScpId('');
                      setTestType('');
                      setRiskLevel(1);
                      setSubjectName('');
                      setDescription('');
                    }}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          {researcher_stats && (
            <Stack.Item>
              <Section
                title={
                  <Box fontFamily="monospace" color={C.dim}>
                    RESEARCHER STATISTICS
                  </Box>
                }
              >
                <Stack gap={2} wrap>
                  <Box fontFamily="monospace" color={C.dim}>
                    Proposals: <Box as="span" color={C.text}>{researcher_stats.total_proposals}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Completed: <Box as="span" color={C.brightGreen}>{researcher_stats.total_completed}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Research: <Box as="span" color={C.amber}>{researcher_stats.total_research_earned}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Incidents: <Box as="span" color={C.red}>{researcher_stats.total_incidents}</Box>
                  </Box>
                  <Box fontFamily="monospace" color={C.dim}>
                    Last Active: <Box as="span" color={C.text}>{researcher_stats.last_active}</Box>
                  </Box>
                </Stack>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
