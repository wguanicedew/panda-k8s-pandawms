#!/usr/bin/env python

import os
import argparse
import tempfile
from subprocess import Popen

all_components = ['msgsvc', 'iam', 'panda', 'harvester', 'idds', 'bigmon']

parser = argparse.ArgumentParser()
parser.add_argument('--affix', '-a', type=str, default='test-',
                    help='Prefix (blah-) or suffix (-blah) of instance names')
parser.add_argument('--experiment', '-e', type=str, help='Experiment name')
parser.add_argument('--enable', '-c', type=str, default=','.join(all_components),
                    help='Comma-separated list of components to be installed')
parser.add_argument('--disable', '-d', type=str, default='', help='Comma-separated list of disabled components'
                                                                  ' and/or sub-components')
parser.add_argument('--template', '-t', default=False, action='store_true', help='Dry-run')

options = parser.parse_args()

disabled = {}
for item in options.disable.split(','):
    if not item:
        continue
    if '.' not in item:
        main_name, sub_name = item, 'all'
    else:
        main_name, sub_name = item.split('.')
    disabled[main_name].setdefault(set())
    disabled[main_name].add(sub_name)

helm_dir = os.path.relpath('../helm', os.path.abspath(os.path.dirname( __file__ )))

for component in options.enable.split(','):
    # disabled
    if component in disabled and 'all' in disabled[component]:
        continue

    # define instant name
    if options.affix.startswith('-'):
        inst_name = options.affix + component
    else:
        inst_name = component + options.affix

    # construct command
    if options.template:
        com = com = ['helm', 'template', '--debug']
    else:
        com = ['helm', 'install', inst_name]
    com += ['-f', os.path.join(helm_dir, component, "values.yaml")]

    # add experiment yaml
    if options.experiment:
        exp_yaml = os.path.join(helm_dir, component, "values", options.experiment,
                                "values-{}.yaml".format(options.experiment))
        if os.path.exists(exp_yaml):
            com += ['-f', exp_yaml]

    # disable sub components
    tmp_yaml = None
    if component in disabled:
        data = {s: {"enabled": "false"} for s in disabled[component] if s != 'all'}
        if data:
            with tempfile.NamedTemporaryFile() as tmp:
                tmp_yaml = tmp.name
                for k, v in data.items():
                    tmp.write("{}\n".format(k))
                    for kk, vv in k.items():
                        tmp.write('  {}: {}\n'.format(kk, vv))
            com += ['-f', tmp_yaml]

    # execute
    print ('>> ', ' '.join(com))
    Popen(com).wait()
    os.remove(tmp_yaml)