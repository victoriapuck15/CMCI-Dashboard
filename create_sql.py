from sqlalchemy import create_engine
import runpy

script_filename = 'run_matlab.py'
result_globals = runpy.run_path(script_filename)

final_data = result_globals['final']

# Format: "dialect+driver://username:password@host:port/database"
engine = create_engine("mysql+mysqlconnector://root:password@localhost/your_database_name")

final_data.to_sql(name='aus_data', con=engine, index=False, if_exists='append')