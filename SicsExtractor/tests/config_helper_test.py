import unittest
import unittest.mock
import json
import pathlib
from tempfile import TemporaryFile
from dataapp.logic.config import ConfigHelper, ConfigSection


class TestConfigHelper(unittest.TestCase):

    def test_create_empty(self):
        helper = ConfigHelper()
        self.assertIsInstance(helper, ConfigHelper)
        self.assertEqual(0, helper.count)

    def test_read_string(self):
        key = 'hello'
        value = 'world'
        dict = {key: value}
        helper = ConfigHelper(dict)
        self.assertEqual(value, helper.get_string(key))
        self.assertEqual(1, helper.count)

    def test_get_section(self):
        section_name, key, value, dict = self.create_greeting_section()
        helper = ConfigHelper(dict)
        section = helper.get_section(section_name)
        self.assertIsInstance(section, ConfigSection)
        self.assertEqual(section_name, section.name)
        self.assertEqual(value, section.get_string(key))
        self.assertEqual(1, helper.count)
        self.assertEqual(1, section.count)

    def test_json_file(self):
        section, key, value, dict = self.create_greeting_section()
        with TemporaryFile(mode='r+', encoding='utf8') as f:
            json.dump(dict, f, sort_keys=True, indent=4)
            f.seek(0)
            content = f.read()
            f.seek(0)
            helper = ConfigHelper.load_json_stream(f)
            section = helper.get_section(section)
            self.assertIsInstance(section, ConfigSection)
            self.assertEqual(value, section.get_string(key))
            self.assertEqual(1, helper.count)
            self.assertEqual(1, section.count)

    def test_real_config(self):
        path = pathlib.Path().resolve() / "dataapp" / "config.json"
        helper = ConfigHelper.load_json_file(path)
        parquet_section = helper.get_section("parquet")
        self.assertIsInstance(parquet_section, ConfigSection)
        self.assertGreater(parquet_section.count, 0)

    def create_greeting_section(self):
        section = 'greeting'
        key = 'hello'
        value = 'world'
        dict = {section: {key: value}}
        return section, key, value, dict
