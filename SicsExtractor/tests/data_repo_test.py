import os
import pathlib
from posixpath import join
import unittest
import unittest.mock
import pandas as pd
import numpy as np
import tempfile
from pandas.core.construction import array
from pandas.core.frame import DataFrame
from parameterized import parameterized
from dataapp.logic.data_repo import DataRepo
from dataapp.logic.models import DataFrameInfo


class TestDataRepo(unittest.TestCase):

    @parameterized.expand([
        [[]], [['A']], [['A', 'C']], [['A', 'B', 'C']]
    ])
    def test_write_partitions(self, partition_on: list[str]):
        df = pd.DataFrame({'A': ['A1', 'A2', 'A3', 'A4'],
                           'B': ['B1', 'B2', 'B3', 'B4'],
                           'C': ['C1', 'C2', 'C3', 'C4'],
                           'D': ['D1', 'D2', 'D3', 'D4'],
                           })
        set_info = DataFrameInfo(__name__)
        set_info.partition_on = partition_on

        with tempfile.TemporaryDirectory() as temp_dir:
            repo = DataRepo(temp_dir)
            repo.write(set_info, df)
            items = pathlib.Path(repo.root_dir).rglob("*.parquet")
            files = list(filter(lambda x: os.path.isfile(x), items))
            [print(x) for x in files]
            expected_dirs = list(
                self.generate_expected_dirs(repo, set_info, df))

            if len(partition_on) > 0:
                expected_dirs.sort()
                actual_dirs = list(map(lambda x: pathlib.Path(
                    x).parent.absolute(), files))
                actual_dirs.sort()
                self.assertEqual(expected_dirs, actual_dirs)
            else:
                self.assertEqual(expected_dirs[0], files[0])


# /var/folders/gb/rjmp_s2j64d213xw03knlgz40000gs/T/tmpqgq12yv4/data_repo_test/data_repo_test.parquet/A=A1/B=B1/C=C1/04767cfebfa048a69250c8b710c21f85.parquet
# /var/folders/gb/rjmp_s2j64d213xw03knlgz40000gs/T/tmpqgq12yv4/data_repo_test/data_repo_test.parquet/A=A2/B=B2/C=C2/ef97567bfdfd40c29c74ec416307ad03.parquet
# /var/folders/gb/rjmp_s2j64d213xw03knlgz40000gs/T/tmpqgq12yv4/data_repo_test/data_repo_test.parquet/A=A3/B=B3/C=C3/f48bd8671e434e5793d58caba508c370.parquet
# /var/folders/gb/rjmp_s2j64d213xw03knlgz40000gs/T/tmpqgq12yv4/data_repo_test/data_repo_test.parquet/A=A4/B=B4/C=C4/6a7a062a35e64bc38b770e218a6b0289.parquet

    def generate_expected_dirs(self, repo: DataRepo, set_info: DataFrameInfo, df: DataFrame) -> list[str]:
        """ Generates the expected dirs based on partition information 
        """
        dir = pathlib.Path(repo.get_data_path(set_info))
        partitions = set_info._partition_ids
        partition_len = len(partitions) if partitions else -1

        if partition_len <= 0:
            yield dir.absolute()
        else:
            # All columns should have same length
            df_count = len(df[partitions[0]])
            data = []
            data = [data.append(x) for x in range(partition_len)]

            for row in range(df_count):
                for idx, id in enumerate(partitions):
                    value = df[id].iloc[row]
                    data[idx] = f"{id}={value}"

                full_path = (dir / '/'.join(data)).absolute()
                yield full_path
