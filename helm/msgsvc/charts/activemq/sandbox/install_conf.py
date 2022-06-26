# generate *.properties and activemq.xml

import os
import re



dstPath = os.environ['ACTIVEMQ_HOME']
basePasswd = os.environ['ACTIVEMQ_BASE_PASSWD']

channels = os.environ.get('ACTIVEMQ_CHANNELS', '').split()
channels = [i for i in channels if i]

u_file = open(os.path.join(dstPath, 'users.properties'), 'w')
g_file = open(os.path.join(dstPath, 'groups.properties'), 'w')

auth_entries = """
<authorizationEntry queue=">" read="admins" write="admins" admin="admins" />
<authorizationEntry topic=">" read="admins" write="admins" admin="admins" />
"""

# admin
u_file.write('system={}\n'.format(basePasswd))
g_file.write('admins=system\n')

# R/W users per channel
for channel in channels:
    u_file.write('{0}_w={1}_{0}_w\n'.format(channel, basePasswd))
    u_file.write('{0}_r={1}_{0}_r\n'.format(channel, basePasswd))

    g_file.write('{0}_w=system,{0}_w\n'.format(channel))
    g_file.write('{0}_r=system,{0}_w,{0}_r\n'.format(channel))

    auth_entries += """<authorizationEntry topic="{0}.>" read="{0}_r" write="{0}_w" admin="{0}_w,admins" />\n""".\
        format(channel)

script_dir = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(script_dir, 'activemq.xml')) as src_f:
    activemq_xml = src_f.read()
    m = re.search(r'(/s+)___AUTH_ENTRIES___', activemq_xml)
    auth_entries = auth_entries.replace('\n', '\n' + m.group(1)).replace('___AUTH_ENTRIES___', activemq_xml)
    with open(os.path.join(dstPath, 'activemq.xml'), 'w') as dst_f:
        dst_f.write(activemq_xml)

u_file.close()
g_file.close()
