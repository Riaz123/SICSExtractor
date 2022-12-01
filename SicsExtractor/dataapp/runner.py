from datetime import datetime
from logic import models
from logic import data_extractor
from logic import config
import os


def main():
    config_file = os.path.join(os.path.dirname(__file__), "config.json")
    helper = config.ConfigHelper.load_json_file(config_file)
    data_extractor.parquet_from_db(helper)

    print(datetime.now())


if __name__ == "__main__":
    main()
