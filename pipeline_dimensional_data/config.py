import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
print(BASE_DIR)

input_dir = os.path.join(BASE_DIR, 'queries')
print(input_dir)

sql_server_config = os.path.join(BASE_DIR, 'sql_server_config.cfg') #SHOULD INCLUDE YOUR CFG FILE'S NAME
print(sql_server_config)
