# generate *.properties and activemq.xml

import os
import re

dstPath = os.path.join(os.environ['ACTIVEMQ_HOME'], 'conf')

# base password
basePasswd = os.environ.get('ACTIVEMQ_BASE_PASSWD', 'password')

# accounts
accounts = os.environ.get('ACTIVEMQ_ACCOUNTS', '').split(';')

# channels
channels = os.environ.get('ACTIVEMQ_CHANNELS', '').split(';')
channels = [i for i in channels if i]

# properties files
u_file = open(os.path.join(dstPath, 'users.properties'), 'w')
g_file = open(os.path.join(dstPath, 'groups.properties'), 'w')

auth_entries = """
<authorizationEntry queue=">" read="admins" write="admins" admin="admins" />
<authorizationEntry topic=">" read="admins" write="admins" admin="admins" />
<authorizationEntry topic="ActiveMQ.Advisory.>" read="users" write="users" admin="users"/>
"""

# admin and users
u_file.write('system={}\n'.format(basePasswd))
g_file.write('admins=system\n')
g_file.write('users={}\n'.format(','.join(accounts)))


# define accounts
for account in accounts:
    u_file.write('{0}={1}_{0}\n'.format(account, basePasswd))
    g_file.write('{0}=system,{0}\n'.format(account))

# define read/write/owner users per channel
for channel_def in channels:
    channel, w_accs, r_accs = channel_def.split(':')
    a_accs = set(w_accs.split(','))
    a_accs.update(r_accs.split(','))
    a_accs = ','.join(list(a_accs))
    auth_entries += """<authorizationEntry queue="{}.>" read="{}" write="{}" admin="{}" />\n""".\
        format(channel, r_accs, w_accs, a_accs)
    auth_entries += """<authorizationEntry topic="{}.>" read="{}" write="{}" admin="{}" />\n""". \
        format(channel, r_accs, w_accs, a_accs)

# activemq.xml
script_dir = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(script_dir, 'activemq.xml')) as src_f:
    activemq_xml = src_f.read()
    m = re.search(r'(\s+)___AUTH_ENTRIES___', activemq_xml)
    if m:
        auth_entries = auth_entries.replace('\n', m.group(1))
        activemq_xml = activemq_xml.replace('___AUTH_ENTRIES___', auth_entries)
    with open(os.path.join(dstPath, 'activemq.xml'), 'w') as dst_f:
        dst_f.write(activemq_xml)

u_file.close()
g_file.close()
