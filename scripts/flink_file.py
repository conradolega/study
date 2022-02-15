import json
import os

from pyflink.table import EnvironmentSettings, TableEnvironment

table_env = TableEnvironment.create(EnvironmentSettings.in_streaming_mode())

def main():
    table_env.execute_sql("""
        CREATE TABLE input (
            created_at TIMESTAMP(3),
            message_id BIGINT,
            guild_id BIGINT,
            author_id BIGINT,
            channel_id BIGINT,
            WATERMARK FOR created_at AS created_at
        ) WITH (
            'connector' = 'filesystem',
            'path' = 'file:///data/input',
            'format' = 'json',
            'json.timestamp-format.standard' = 'ISO-8601'
        )
    """)

    table_env.execute_sql("""
        CREATE TABLE output (
            window_start TIMESTAMP(3),
            window_end TIMESTAMP(3),
            author_id BIGINT,
            message_count BIGINT
        ) WITH (
            'connector' = 'filesystem',
            'path' = 'file:///data/output',
            'format' = 'json',
            'json.timestamp-format.standard' = 'ISO-8601'
        )
    """)

    table_result = table_env.execute_sql("""
        INSERT INTO output
        SELECT window_start, window_end, author_id, COUNT(DISTINCT message_id) AS message_count
        FROM TABLE(
            TUMBLE(TABLE input, DESCRIPTOR(created_at), INTERVAL '1' MINUTES))
        GROUP BY window_start, window_end, author_id
    """)

    table_result.wait()

if __name__ == "__main__":
    main()
