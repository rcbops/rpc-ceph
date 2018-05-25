#!/usr/bin/python

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: ini_diff

short_description: This module produces a diff of two ini files

version_added: "2.4"

description:
    - "This module produces a diff of two ini files"

options:
    name:
        description:
            - This is the message to send to the sample module
        required: true
    first:
        description:
            - The first file to compare
        required: true
    second:
        description:
            - The second file to compare
        required: true

extends_documentation_fragment:
    - files

author:
    - Michael Vollman (@vollman)
'''
EXAMPLES = '''
# Compare two ini files
- name: Compare two ini files
  ini_diff:
    first: /tmp/my-old-config
    second: /tmp/my-new-config
'''

RETURN = '''
changes:
    description: Differences between two configs
    type: dict
'''

from ansible.module_utils.basic import AnsibleModule
from six.moves import configparser
import json
import sys


class DictDiffer(object):
  """
  Calculate the difference between two dictionaries as:
  (1) items added
  (2) items removed
  (3) keys same in both but changed values
  (4) keys same in both and unchanged values
  """
  def __init__(self, current_dict, past_dict):
    self.current_dict, self.past_dict = current_dict, past_dict
    self.set_current, self.set_past = set(current_dict.keys()), set(past_dict.keys())
    self.intersect = self.set_current.intersection(self.set_past)
  def added(self):
    return self.set_current - self.intersect
  def removed(self):
    return self.set_past - self.intersect
  def changed(self):
    return set(o for o in self.intersect if self.past_dict[o] != self.current_dict[o])
  def unchanged(self):
    return set(o for o in self.intersect if self.past_dict[o] == self.current_dict[o])


def compare_configs(a, b):

  oldconfig = configparser.RawConfigParser()
  oldconfig.read(a)
  oldconfig_dict = {s:dict(oldconfig.items(s)) for s in oldconfig.sections()}

  newconfig = configparser.RawConfigParser()
  newconfig.read(b)
  newconfig_dict = {s:dict(newconfig.items(s)) for s in newconfig.sections()}

  config = DictDiffer(oldconfig_dict, newconfig_dict)
  diffs = {'ADDED': {}, 'REMOVED': {}, 'CHANGED': {}}

  for s in sorted(config.changed()):
    changes = DictDiffer(dict(newconfig_dict[s]), dict(oldconfig_dict[s]))

    for c in changes.added():
      if s not in diffs['ADDED']:
        diffs['ADDED'][s] = {c: newconfig_dict[s][c]}
      else:
        diffs['ADDED'][s][c] = newconfig_dict[s][c]

    for c in changes.removed():
      if s not in diffs['REMOVED']:
        diffs['REMOVED'][s] = {c: oldconfig_dict[s][c]}
      else:
        diffs['REMOVED'][s][c] = oldconfig_dict[s][c]

    for c in changes.changed():
      if s not in diffs['CHANGED']:
        diffs['CHANGED'][s] = {c: {'current value': oldconfig_dict[s][c], 'new value': newconfig_dict[s][c]}}
      else:
        diffs['CHANGED'][s][c] = {'current value': oldconfig_dict[s][c], 'new value': newconfig_dict[s][c]}

  return diffs


def main():

   module = AnsibleModule(
     argument_spec=dict(
       first=dict(type='str', required=True),
       second=dict(type='str', required=True),
     ),
     supports_check_mode=False,
   )

   first = module.params['first']
   second = module.params['second']
   chg = compare_configs(first, second)

   result = dict(
     changed=False,
     changes=chg,
   )

   module.exit_json(**result)

if __name__ == '__main__':
    main()

