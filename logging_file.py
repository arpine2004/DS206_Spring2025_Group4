import logging
import os
from logging import LoggerAdapter

# Function to configure and return a logger that writes logs to a specified file path
def setup_logger(log_file_path):
    log_dir = os.path.dirname(log_file_path)
    os.makedirs(log_dir, exist_ok=True)

    logger = logging.getLogger('dimensional')
    logger.setLevel(logging.DEBUG)

    if not logger.handlers:
        file_handler = logging.FileHandler(log_file_path)
        file_handler.setLevel(logging.DEBUG)

        formatter = logging.Formatter(
            "%(asctime)s - %(execution_id)s - %(levelname)s - %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S"
        )
        file_handler.setFormatter(formatter)

        logger.addHandler(file_handler)

    return logger


class ExecutionLoggerAdapter(LoggerAdapter):

    def process(self, msg, kwargs):
        return msg, {'extra': {'execution_id': self.extra['execution_id']}}


def get_dimensional_logger(execution_id, log_file="logs/logs_dimensional_data_pipeline.txt"):
    base_logger = setup_logger(log_file)

    adapter = ExecutionLoggerAdapter(base_logger, {'execution_id': execution_id})

    return adapter
