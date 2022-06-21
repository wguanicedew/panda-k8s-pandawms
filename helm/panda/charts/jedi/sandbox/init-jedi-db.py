import time
import optparse

import pandaserver.userinterface.Client as Client

from pandaserver.taskbuffer.OraDBProxy import DBProxy
# password
from pandaserver.config import panda_config


proxyS = DBProxy()
proxyS.connect(panda_config.dbhost,panda_config.dbpasswd,panda_config.dbuser,panda_config.dbname)

sql = "INSERT INTO DOMA_PANDA.JEDI_WORK_QUEUE (QUEUE_ID,QUEUE_NAME,QUEUE_TYPE,VO,QUEUE_FUNCTION) VALUES(:queueID,:queueName,:queueType,:vo,'Resource')"

varMaps = []
varMap = {':queueID': 2,
          ':queueName': 'managed',
          ':queueType': 'managed',
          ':vo': 'wlcg'}
varMaps.append(varMap)
varMap = {':queueID': 3,
          ':queueName': 'user',
          ':queueType': 'user',
          ':vo': 'wlcg'}
varMaps.append(varMap)

res = proxyS.executemanySQL(sql, varMaps)
print(res)
