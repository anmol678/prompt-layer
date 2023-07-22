import json
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import create_engine

from app.sqlite.schemas import Log

engine = create_engine('sqlite:///./sql_app.db')
session = Session(engine)

# session.query(Log).delete()
# session.commit()

# Load the JSON data from multiple files and combine into one list
data = []
file_names = ['../Data/logs_1.json', '../Data/logs_2.json', '../Data/logs_3.json']
for file_name in file_names:
    try:
        with open(file_name, 'r') as f:
            json_data = json.load(f)
            data.extend(json_data['items'])
        print(f'Loaded JSON data from {file_name}.')
    except Exception as e:
        print(f'Error loading JSON data from {file_name}: {e}')

# Sort data by time in ascending order
data.sort(key=lambda item: datetime.strptime(item['request_start_time'], "%a, %d %b %Y %H:%M:%S %Z"))

for item in data:
    try:
        log = Log(
            function_name=item['function_name'],
            prompt=item['function_args'],
            kwargs=item['function_kwargs'],
            request_start_time=datetime.strptime(item['request_start_time'], "%a, %d %b %Y %H:%M:%S %Z"),
            request_end_time=datetime.strptime(item['request_end_time'], "%a, %d %b %Y %H:%M:%S %Z"),
            response=item['request_response'],
            provider_type=item['provider_type'],
            cost=item['price'],
            tags=item['tags'],
            token_usage={"prompt_tokens": 0, "completion_tokens": 0, "total_tokens": item['tokens']},
        )
    
        session.add(log)
        session.commit()
        print(f'Added log with id: {log.id}')
    except Exception as e:
        print(f'Error adding log: {e}')
        session.rollback()

print('Migration completed.')
