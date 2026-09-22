#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const reminders = requireFromRoot('shell/plugins/reminders/ReminderFlowModel.js')
const flowSource = fs.readFileSync(root + '/shell/plugins/reminders/ReminderFlow.qml', 'utf8')

assertEqual(reminders.validMinutes('15'), '15', 'reminders accepts positive integer minutes')
assertEqual(reminders.validMinutes('  5  '), '5', 'reminders trims minute input')
assertEqual(reminders.validMinutes('0'), '', 'reminders rejects zero minutes')
assertEqual(reminders.validMinutes('-5'), '', 'reminders rejects negative minutes')
assertEqual(reminders.validMinutes('1.5'), '', 'reminders rejects fractional minutes')
assertEqual(reminders.validMinutes('soon'), '', 'reminders rejects non-numeric minutes')

assertDeepEqual(
  reminders.reminderArgs('10', 'Check the oven'),
  ['10', 'Check the oven'],
  'reminders builds command args with message'
)

assertDeepEqual(
  reminders.reminderArgs('10', ''),
  ['10'],
  'reminders omits empty message arg'
)

assertDeepEqual(
  reminders.reminderArgs('0', 'ignored'),
  [],
  'reminders command args are empty for invalid minutes'
)

// The typing line is a fixed one-line card: eliding must drop the head so the
// freshly typed tail stays visible while typing (#12824).
assert(/text: root\.filterText[\s\S]*?elide: Text\.ElideLeft/.test(flowSource),
  'reminders typing line elides the head, not the tail')
assert(!/elide: Text\.ElideRight/.test(flowSource),
  'reminders typing line keeps no head-hiding elide')
JS
