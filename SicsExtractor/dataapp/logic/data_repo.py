import pathlib
import os
import pandas as pd
import shutil
from pandas import api
from . import models


class DataFormatter:

    def fix_schema(self, df: pd.DataFrame) -> pd.DataFrame:
        # pyspark doesn't allow unsigned types

        for c in df.columns:
            c_data_type = df.dtypes[c]

            if api.types.is_unsigned_integer_dtype(c_data_type):
                # TODO, nicer solution.
                # Just remove the u from the name
                c_signed_type = c_data_type.name[1:]
                df = df.astype({c: c_signed_type}, 'same_kind')

        return df


class DirectoryHelper:

    @staticmethod
    def ensure_dir(dir_path: str) -> bool:
        try:
            if not os.path.exists(dir_path):
                os.makedirs(dir_path)
                return True
        except FileExistsError:
            pass
        return False


class DataRepo:

    def __init__(self, root_dir: str = None):
        if root_dir:
            self._root_dir = root_dir
        else:
            self._root_dir = (pathlib.Path() / 'data').absolute()

    @property
    def root_dir(self) -> str:
        return self._root_dir

    def can_reuse_data(self, set_info: models.DataFrameInfo) -> bool:

        if (set_info.overwrite):
            return False

        data_path = pathlib.Path(self.get_data_path(set_info))
        partition_on = set_info.partition_on
        is_partitioned = partition_on and len(partition_on) > 0

        if (is_partitioned):
            return data_path.exists() and next(data_path.rglob("*.parquet"), None) is not None
        return data_path.exists()

    def write(self, set_info: models.DataFrameInfo, df: pd.DataFrame, compression: str = "snappy") -> str:
        data_path = self.get_data_path(set_info)
        data_dir = pathlib.Path(data_path).parent.absolute()
        self.prepare_data_dir(set_info, data_dir)
        df.to_parquet(data_path,
                      compression=compression,
                      partition_cols=set_info.partition_on,
                      allow_truncated_timestamps=True)
        print(f"Wrote: {data_path}")
        return data_path

    def prepare_data_dir(self, set_info: models.DataFrameInfo, data_dir: str):
        if set_info.overwrite and os.path.exists(data_dir):
            shutil.rmtree(data_dir)
        DirectoryHelper.ensure_dir(data_dir)

    def get_data_path(self, set_info: models.DataFrameInfo) -> str:
        return (pathlib.Path(self.root_dir) / set_info.name / f"{set_info.name}.parquet").absolute()

    def read(self, set_info: models.DataFrameInfo) -> pd.DataFrame:
        file_path = self.get_data_path(set_info)

        if os.path.exists(file_path):
            df = pd.read_parquet(file_path)
            return df
        else:
            raise FileNotFoundError(file_path)
