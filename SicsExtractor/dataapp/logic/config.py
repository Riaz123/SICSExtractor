from __future__ import annotations
import pandas as pd
import json


class ConfigSection:

    def __init__(self, name: str, dict: dict[str, object] = None):
        self._name = name
        if dict:
            self._cfg_dict = dict
        else:
            self._cfg_dict = {}

    @property
    def name(self) -> str:
        return self._name

    @property
    def count(self) -> int:
        return len(self._cfg_dict)

    def get_string(self, key: str):
        value = self._cfg_dict.get(key, None)

        if value:
            return str(value)
        return None

    def get_bool(self, key: str, default_value: bool = None) -> bool:
        value = self._cfg_dict.get(key, None)

        if value:
            return bool(value)
        return default_value

    def get_section(self, key: str):
        value = self._cfg_dict.get(key, None)
        return ConfigSection(key, value)

    def get_section_array(self, key: str):
        value = self._cfg_dict.get(key, None)

        return [ConfigSection(f"{key}-{i}", v) for i, v in enumerate(value)]

    def get(self, key: str):
        return self._cfg_dict.get(key, None)


class ConfigHelper(ConfigSection):

    def __init__(self, dict: dict[str, object] = None):
        ConfigSection.__init__(self, "root", dict)

    @staticmethod
    def load_json_file(path: str, mode='r', encoding='utf8') -> ConfigHelper:
        with open(path, mode=mode, encoding=encoding) as f:
            return ConfigHelper.load_json_stream(f)

    @staticmethod
    def load_json_stream(fp) -> ConfigHelper:
        """Deserialize a ConfigHelper from ``fp`` (a ``.read()``-supporting file-like object containing
        a JSON document) to a Python object.
        """
        dict = json.load(fp)
        return ConfigHelper(dict)
