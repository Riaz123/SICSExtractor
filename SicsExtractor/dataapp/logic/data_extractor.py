from . import config
from . import sicsdb
from . import data_repo
from . import models
import glob
import os
import pathlib


def create_reader(db_info: models.DatabaseInfo):
    # Create a reader
    db_conn = sicsdb.DbConnection(db_info)
    return sicsdb.SicsReader(db_conn)


def parquet_from_db(cfg: config.ConfigHelper, compression: str = "snappy"):
    sections = cfg.get_section("parquet").get_section_array("data_sets")

    for s in sections:
        conn = s.get_section("connection")
        db_info = models.DatabaseInfo(
            conn.get_string("server"),
            conn.get_string("database"))

        process_script_dir(db_info, s, compression)


def process_script_dir(db_info: models.DatabaseInfo, cfg: config.ConfigSection, compression: str = "snappy"):

    # Create a reader
    reader = create_reader(db_info)
    formatter = data_repo.DataFormatter()
    cfg_data_sets = cfg.get_section("config")
    script_dir = pathlib.Path(cfg.get_string("script_dir"))

    # Create the repo
    repo = data_repo.DataRepo(cfg.get_string("out_dir"))

    # Get all queries
    files = script_dir.glob("*.sql")

    for script_file in files:
        file_name = script_file.stem
        set_info = models.DataFrameInfo.from_config(
            cfg_data_sets.get_section(file_name))

        if repo.can_reuse_data(set_info):
            print(f"Reused: {file_name}, NOOP")
            continue

        with script_file.open('r') as f:
            print(f"Reading: {file_name}")
            query = f.read()
            df = reader.get(query)
            print(f"Fix schema: {file_name}")
            df = formatter.fix_schema(df)

            print(f"Writing: {file_name}")
            repo.write(set_info, df, compression)
