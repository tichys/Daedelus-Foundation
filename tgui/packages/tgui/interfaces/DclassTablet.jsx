import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Box,
  Stack,
  ProgressBar,
  Table,
} from '../components';
import { Window } from '../layouts';

export const DclassTablet = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    dclass_number,
    trust_name,
    trust_points,
    credits,
    level,
    experience,
    required_experience,
    status,
    tests_completed,
    tests_successful,
    escape_attempts,
    successful_escapes,
    strikes,
    warnings,
    is_informant,
    can_volunteer,
    current_work,
  } = data;

  return (
    <Window
      title={`D-Class Terminal - ${dclass_number || 'Unknown'}`}
      width={400}
      height={550}
      theme="scp_terminal"
    >
      <Window.Content scrollable>
        <Section title="Personnel Status">
          <LabeledList>
            <LabeledList.Item label="Designation">
              {dclass_number}
            </LabeledList.Item>
            <LabeledList.Item label="Status">
              {status}
            </LabeledList.Item>
            <LabeledList.Item label="Trust Level">
              <ProgressBar
                value={trust_points / 100}
                ranges={{
                  good: [0.6, 1],
                  average: [0.4, 0.6],
                  bad: [0, 0.4],
                }}
              >
                {trust_name} ({trust_points}%)
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Level">
              Level {level}
            </LabeledList.Item>
            <LabeledList.Item label="Experience">
              <ProgressBar
                value={experience / required_experience}
              >
                {experience} / {required_experience}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Credits">
              {credits} cr
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Testing Record">
          <LabeledList>
            <LabeledList.Item label="Tests Completed">
              {tests_completed}
            </LabeledList.Item>
            <LabeledList.Item label="Successful">
              {tests_successful}
            </LabeledList.Item>
            <LabeledList.Item label="Escape Attempts">
              {escape_attempts}
            </LabeledList.Item>
            <LabeledList.Item label="Successful Escapes">
              {successful_escapes}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Behavioral Record">
          <LabeledList>
            <LabeledList.Item label="Strikes">
              {strikes} / 3
            </LabeledList.Item>
            <LabeledList.Item label="Warnings">
              {warnings}
            </LabeledList.Item>
            <LabeledList.Item label="Current Work">
              {current_work || 'None'}
            </LabeledList.Item>
            <LabeledList.Item label="Informant">
              {is_informant ? 'Yes' : 'No'}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Actions">
          <Stack>
            {can_volunteer && (
              <Stack.Item>
                <Button
                  icon="flask"
                  onClick={() => act('volunteer_test')}
                >
                  Volunteer for Testing
                </Button>
              </Stack.Item>
            )}
            <Stack.Item>
              <Button
                icon="eye"
                onClick={() => act('check_status')}
              >
                Check Test Status
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
