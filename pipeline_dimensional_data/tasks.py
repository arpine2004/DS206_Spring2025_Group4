import pyodbc
from utils import load_query, get_sql_config, get_uuid
from logging_file import get_dimensional_logger
import os
import pandas as pd
import traceback
import numpy as np

dimensional_logger = get_dimensional_logger(get_uuid())

# Relative paths to the SQL scripts directories
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
INFRA_DIR = os.path.abspath(os.path.join(BASE_DIR, "..", "infrastructure_initiation"))
QUERY_DIR = os.path.join(BASE_DIR, "queries")

def connect_db_create_cursor(config_file, config_section):
    """
        Connects to SQL Server using credentials from config file.
        Supports both Windows Integrated and SQL Server authentication.
        Returns the connection and cursor objects.
    """
    try:
        config = get_sql_config(config_file, config_section)

        if config.get('UID') and config.get('PWD'):
            conn_str = (
                f"Driver={config['Driver']};"
                f"Server={config['Server']};"
                f"Database={config['Database']};"
                f"UID={config['UID']};"
                f"PWD={config['PWD']};"
                f"Encrypt={config['Encrypt']};"
                f"TrustServerCertificate={config['TrustServerCertificate']};"
            )
        else:
            conn_str = (
                f"Driver={config['Driver']};"
                f"Server={config['Server']};"
                f"Database={config['Database']};"
                f"Trusted_Connection=yes;"
                f"Encrypt={config['Encrypt']};"
                f"TrustServerCertificate={config['TrustServerCertificate']};"
            )

        connection = pyodbc.connect(conn_str)
        cursor = connection.cursor()

        return connection, cursor

    except Exception as e:
        dimensional_logger.error(
            msg="Failed to connect to the database.",
            extra={"execution_uuid": "N/A", "error": str(e)}
        )
        raise


def create_database(connection, cursor, execution_uuid):
    """
    Executes the database creation script.
    Uses autocommit to apply changes immediately.
    Logs success or failure.
    """
    try:
        create_database_script = load_query(INFRA_DIR, "dimensional_db_creation.sql")

        connection.autocommit = True
        cursor.execute(create_database_script)
        connection.commit()

        dimensional_logger.info(
            msg="The database has been created.",
            extra={"execution_uuid": execution_uuid}
        )

        return {'success': True}
    except Exception as e:
        connection.rollback()
        dimensional_logger.error(
            msg="Failed to create the database.",
            extra={"execution_uuid": execution_uuid, "error": str(e)}
        )
        dimensional_logger.debug(
            msg="Traceback: " + traceback.format_exc(),
            extra={"execution_uuid": execution_uuid}
        )
        return {'success': False, 'error': str(e)}
    finally:
        connection.autocommit = True

def create_tables(connection, cursor, execution_uuid):
    """
        Runs SQL scripts to create staging and dimensional tables.
        Logs successes and handles errors with rollback.
    """
    try:
        staging_tables_script = load_query(INFRA_DIR, "staging_raw_table_creation.sql")
        cursor.execute(staging_tables_script)
        connection.commit()

        dimensional_logger.info(
            msg="The staging tables in the database have been created.",
            extra={"execution_uuid": execution_uuid}
        )

        dimensional_tables_script = load_query(INFRA_DIR, "dimensional_db_table_creation.sql")
        cursor.execute(dimensional_tables_script)
        connection.commit()

        dimensional_logger.info(
            msg="The dimensional tables in the database have been created.",
            extra={"execution_uuid": execution_uuid}
        )

        return {'success': True}
    except Exception as e:
        connection.rollback()
        dimensional_logger.error(
            msg="Failed to create tables in the database.",
            extra={"execution_uuid": execution_uuid, "error": str(e)}
        )
        return {'success': False, 'error': str(e)}
    finally:
        connection.autocommit = True


def insert_into_table(connection, cursor,
                      table_name: str,
                      db: str,
                      schema: str,
                      start_date: str,
                      end_date: str,
                      staging_table: str,
                      execution_uuid) -> dict:
    """
        Loads and executes a parametrized SQL update/insert script for a given table.
        The script filename is generated based on the table name (snake_case).
        Supports date range parameters for incremental loading.
        Logs progress and errors.
    """

    try:
        snake = ''.join(['_' + c.lower() if c.isupper() else c
                         for c in table_name]).lstrip('_')
        filename = f"update_{snake}.sql"

        sql = load_query(QUERY_DIR, filename).format(
            db_dim=db,
            schema_dim=schema,
            table_dim=table_name,
            db_staging=db,
            schema_staging=schema,
            table_staging=staging_table,
            db_rel=db,
            schema_rel=schema,
            table_stg=staging_table,
            start_date=start_date,
            end_date=end_date
        )

        connection.autocommit = False
        cursor.execute(sql)
        connection.commit()

        dimensional_logger.info(
            msg=f"Data inserted/updated into {db}.{schema}.{table_name} from {staging_table}.",
            extra={"execution_uuid": execution_uuid}
        )
        return {'success': True}

    except Exception as e:
        connection.rollback()
        dimensional_logger.error(
            msg=f"Failed to load {table_name}: {e}",
            extra={"execution_uuid": execution_uuid}
        )
        dimensional_logger.debug(
            msg="Traceback: " + traceback.format_exc(),
            extra={"execution_uuid": execution_uuid}
        )
        return {'success': False, 'error': str(e)}

    finally:
        connection.autocommit = True


source_data = os.path.join(BASE_DIR, 'raw_data_source.xlsx')

def insert_into_staging(connection, cursor, table_name, execution_uuid):
    """
        Loads and executes a parametrized SQL update/insert script for a given table.
        The script filename is generated based on the table name (snake_case).
        Supports date range parameters for incremental loading.
        Logs progress and errors.

    """

    df = pd.read_excel(source_data, sheet_name=table_name, header=0)

    columns = ', '.join(df.columns)
    placeholders = ', '.join(['?'] * len(df.columns))
    sql = f'''INSERT INTO dbo.Staging_Raw_{table_name} ({columns}) VALUES ({placeholders});'''

    for column in df.columns:
        if 'Date' in column:
            df[column] = pd.to_datetime(df[column], format='%Y%m%d', errors='coerce').dt.date

    if table_name == 'Categories':
        df['Description'] = df['Description'].astype(str)

    if table_name == "Employees":
        df.sort_values(by='ReportsTo', ascending=True, na_position='first', inplace=True)
        df['ReportsTo'] = df['ReportsTo'].astype("Int64")

    if table_name == 'Orders':
        df['Freight'] = df['Freight'].astype('Float64')

    if table_name == 'OrderDetails':
        df['UnitPrice'] = df['UnitPrice'].astype('Float64')


    df.replace({np.nan: None, np.inf: None, -np.inf: None}, inplace=True)

    connection.autocommit = True

    try:
        for _, row in df.iterrows():
            print(f"Executing SQL on table: Staging_Raw_{table_name}")
            cursor.execute(sql, tuple(row))
        connection.commit()
        dimensional_logger.info(
            msg=f"Successfully inserted data into Staging_Raw_{table_name}.",
            extra={"execution_uuid": execution_uuid}
        )
        return {'success': True}

    except Exception as e:
        connection.rollback()
        dimensional_logger.error(
            msg=f"Failed to insert data into Staging_Raw_{table_name}. Error: {str(e)}",
            extra={"execution_uuid": execution_uuid}
        )
        dimensional_logger.debug(
            msg="Traceback: " + traceback.format_exc(),
            extra={"execution_uuid": execution_uuid}
        )
        return {'success': False, 'error': str(e)}

    finally:
        connection.autocommit = False

