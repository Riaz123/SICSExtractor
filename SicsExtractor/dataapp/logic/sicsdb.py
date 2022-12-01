import pyodbc
import pandas as pd
import numpy as np
from . import cached_property as cached
from . import models

class DbConnection:

    def __init__(self, db_info: models.DatabaseInfo):
        self.db_info = db_info

    @cached.cached_property
    def connection(self) -> pyodbc.Connection:
        pwd_section = ';Trusted_Connection=yes;'
        return pyodbc.connect(
            f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={self.db_info.server};DATABASE={self.db_info._name}{pwd_section}')

class SicsReader:

    def __init__(self, conn: DbConnection):
        self.conn = conn

    def get(self, query: str) -> pd.DataFrame:
        return pd.read_sql(query, self.conn.connection)