import unittest
import unittest.mock
import pandas as pd
import numpy as np
from parameterized import parameterized
from dataapp.logic.data_repo import DataFormatter


class TestDataFormatter(unittest.TestCase):

    @parameterized.expand([
        [np.ubyte], [np.uint], [np.uint0], [np.uint16],
        [np.uint32], [np.uint64], [np.uint8], [np.uintc], [np.uintp],
        [np.ulonglong]
    ])
    def test_unsigned_convert(self, col_type):
        formatter = DataFormatter()
        df = pd.DataFrame({'a': pd.Series(dtype=col_type)})
        df2 = formatter.fix_schema(df)
        self.assertNotEqual(df.dtypes[0], df2.dtypes[0])
