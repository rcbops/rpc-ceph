#!/usr/bin/env python2.7
#
# Copyright 2016, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# (c) 2016, Jesse Pretorius <jesse.pretorius@rackspace.co.uk>
#


"""Read current version from ansible-role-requirements.yml content from the CLI."""


#from __future__ import print_function

import argparse
import yaml


def main():
    """Run the main application."""

    # Setup argument parsing
    parser = argparse.ArgumentParser(
        description='ansible-role-requirements.yml CLI reader',
        epilog='Licensed "Apache 2.0"')

    parser.add_argument(
        '-f',
        '--file',
        help='<Required> ansible-role-requirements.yml file location',
        required=True
    )

    parser.add_argument(
        '-n',
        '--name',
        help='<Optional> The name of the Ansible role to edit',
        required=False
    )

    parser.add_argument(
        '-s',
        '--src',
        help='<Optional> The source URL to identify the, or set for the Ansible role',
        required=False
    )

    # Parse arguments
    args = parser.parse_args()

    # Read the ansible-role-requirements.yml file into memory
    with open(args.file, "r") as role_req_file:
        reqs = yaml.safe_load(role_req_file)

    # Loop through the list to find the applicable role
    for role_data in reqs:
        if args.name:
            if role_data['name'] == args.name:
                print role_data['version']
        elif args.src:
           if role_data['src'] == args.src:
                print role_data['version']


if __name__ == "__main__":
    main()
