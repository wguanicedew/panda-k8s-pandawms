# generate *.properties and activemq.xml

import os
import re

dstPath = os.path.join(os.environ['ACTIVEMQ_HOME'], 'conf')

# base password
basePasswd = os.environ.get('ACTIVEMQ_BASE_PASSWD', 'password')

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

# admin
u_file.write('system={}\n'.format(basePasswd))
g_file.write('admins=system\n')

# define read/write/owner users per channel
for channel in channels:
    u_file.write('{0}_w={1}_{0}_w\n'.format(channel, basePasswd))
    u_file.write('{0}_r={1}_{0}_r\n'.format(channel, basePasswd))

    g_file.write('{0}=system,{0}\n'.format(channel))
    g_file.write('{0}_w=system,{0},{0}_w\n'.format(channel))
    g_file.write('{0}_r=system,{0}_w,{0}_r\n'.format(channel))

    auth_entries += """<authorizationEntry queue="{0}.>" read="{0}_r" write="{0}_w" admin="{0}_w,{0}_r" />\n""".\
        format(channel)
    auth_entries += """<authorizationEntry topic="{0}.>" read="{0}_r" write="{0}_w" admin="{0}_w,{0}_r" />\n""".\
        format(channel)

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
