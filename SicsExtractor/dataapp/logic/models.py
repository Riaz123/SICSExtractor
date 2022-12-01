from . import config


class DataFrameInfo:
    def __init__(self, name: str, overwrite: bool = False):
        self._name = name
        self._partition_ids = None
        self._overwrite = overwrite

    @property
    def name(self) -> str:
        return self._name

    @property
    def overwrite(self) -> bool:
        return self._overwrite

    @overwrite.setter
    def overwrite(self, overwrite: bool):
        self._overwrite = overwrite

    @property
    def partition_on(self):
        if self._partition_ids:
            return self._partition_ids.copy()
        return None

    @partition_on.setter
    def partition_on(self, ids: list[str]):
        if ids and len(ids) > 0:
            self._partition_ids = ids
        else:
            self._partition_ids = None

    @staticmethod
    def from_config(cfg: config.ConfigSection):
        i = DataFrameInfo(cfg.name)
        i.partition_on = cfg.get("partition_on")
        i.overwrite = cfg.get_bool("overwrite", False)
        return i


class DatabaseInfo:
    def __init__(self, server: str, db_name: str):
        self.server = server
        self.name = db_name

    @property
    def server(self) -> str:
        return self._server

    @server.setter
    def server(self, value: str):
        self._server = value

    @property
    def name(self) -> str:
        return self._name

    @name.setter
    def name(self, value: str):
        self._name = value
