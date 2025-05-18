import os
import traceback
from pipeline_dimensional_data.config import BASE_DIR

import pyodbc

from pipeline_dimensional_data import tasks
from pipeline_dimensional_data.tasks import get_uuid
from logging_file import get_dimensional_logger

class DimensionalDataFlow:
    def __init__(self):
        self.execution_uuid = get_uuid()
        self.logger = get_dimensional_logger(self.execution_uuid)

    def exec(self, start_date, end_date):

        """
                Executes the full dimensional data pipeline flow:
                - Connects to database
                - Creates database and tables
                - Loads data into staging tables
                - Loads data into dimension and fact tables
                Handles errors and logs all important steps.
        """

        connection = cursor = None
        try:
            self.logger.info("Starting Dimensional Data Flow execution.")
            config_path = os.path.join(BASE_DIR, 'configuration.cfg')
            connection, cursor = tasks.connect_db_create_cursor(config_path, 'ORDER_DDS')
            print("Connected to database:", connection.getinfo(pyodbc.SQL_DATABASE_NAME))

            result = tasks.create_database(connection, cursor, self.execution_uuid)
            if not result['success']:
                raise Exception(result['error'])
            result = tasks.create_tables(connection, cursor, execution_uuid=self.execution_uuid)
            if not result['success']:
                raise Exception(result['error'])

            staging_tables = ['Categories', 'Customers', 'Employees', 'Products',
                              'Region', 'Shippers', 'Suppliers', 'Territories', 'Orders', 'OrderDetails']
            for st in staging_tables:
                res = tasks.insert_into_staging(connection, cursor, st, self.execution_uuid)
                if not res['success']:
                    raise Exception(f"Staging {st} failed: {res['error']}")

            dimension_tables = [
                'DimCategories', 'DimCustomers', 'DimEmployees', 'DimProducts',
                'DimRegion', 'DimShippers', 'DimSuppliers', 'DimTerritories',
                'FactOrders', 'FactError'
            ]
            for tbl in dimension_tables:
                base = tbl[3:] if tbl.startswith('Dim') else tbl[4:]
                staging_table = f"Staging_Raw_{base}"

                res = tasks.insert_into_table(
                    connection,
                    cursor,
                    tbl,
                    "ORDER_DDS",
                    "dbo",
                    start_date,
                    end_date,
                    staging_table,
                    self.execution_uuid
                )
                if not res['success']:
                    raise Exception(f"Ingest {tbl} failed: {res['error']}")

            self.logger.info("Dimensional Data Flow executed successfully.")

        except Exception as e:
            self.logger.error(f"Dimensional Data Flow execution failed: {e}")
            self.logger.debug(f"Traceback: {traceback.format_exc()}")

        finally:
            try:
                if cursor:    cursor.close()
                if connection: connection.close()
                self.logger.info("Database connection closed.")
            except Exception as e:
                self.logger.error(f"Error closing database connection: {e}")

