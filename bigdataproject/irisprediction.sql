CREATE EXTERNAL TABLE IF NOT EXISTS `bigdata`.`predictions` (
  `user_name` string,
  `user_screen_name` string,
  `text` string,
  `followers_count` int,
  `location` string,
  `created_at` string,
  `sentiment_score` float,
  `label` int,
  `prediction` double
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT 'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 's3://irisbuckett/predictions.parquet/'
TBLPROPERTIES ('classification' = 'parquet');
       