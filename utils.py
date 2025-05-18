import configparser
import os
import uuid

# Reads and parses the SQL config file for a given database section.
def get_sql_config(filename, database):
    cf = configparser.ConfigParser()
    if not os.path.exists(filename):
        raise FileNotFoundError(f"Config file {filename} does not exist.")

    cf.read(filename)

    if not cf.has_section(database):
        raise configparser.NoSectionError(f"Section '{database}' not found in {filename}.")

    config = {
        "Driver": cf.get(database, "Driver").strip(),
        "Server": cf.get(database, "Server").strip(),
        "Database": cf.get(database, "Database").strip(),
        "UID": cf.get(database, "UID", fallback=None),
        "PWD": cf.get(database, "PWD", fallback=None),
        "Encrypt": cf.get(database, "Encrypt", fallback="no").strip(),
        "TrustServerCertificate": cf.get(database, "TrustServerCertificate", fallback="no").strip()
    }
    return config

# Loads and returns the content of a SQL query file matching the given query name.
def load_query(query_dir, query_name):
    matched_files = [file for file in os.listdir(query_dir) if query_name in file]
    if not matched_files:
        raise FileNotFoundError(f"No file containing '{query_name}' found in directory '{query_dir}'.")
    if len(matched_files) > 1:
        raise FileExistsError(
            f"Multiple files containing '{query_name}' found in directory '{query_dir}': {matched_files}")

    file_path = os.path.join(query_dir, matched_files[0])
    with open(file_path, 'r', encoding='utf-8') as script_file:
        return script_file.read()

# Generates and returns a new UUID object.
def get_uuid():
    return uuid.uuid4()