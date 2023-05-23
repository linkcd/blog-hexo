Create
```SQL
DROP TABLE IF EXISTS client_iceberg_table

CREATE TABLE IF NOT EXISTS client_iceberg_table (
  check_time timestamp, 
  clientmac string, 
  firstseen timestamp, 
  lastseen timestamp, 
  power bigint, 
  numpkts bigint, 
  raw_bssid string, 
  raw_probedssids double, 
  fixed_bssid string, 
  fixed_probedssid string, 
  duration double, 
  check_time_date date)
LOCATION 's3://wifidumper-result-iceberg-dev/client_iceberg_table/'
TBLPROPERTIES (
  'table_type'='ICEBERG'
)
```

PARTITIONED BY (check_time_date, day(check_time_date))

GENERIC_USER_ERROR: Exceeded limit of 100 open partitions when writing data. Sorting data based on the table's partition keys is recommended to produce more optimized tables and reduce the likelihood of such error. If the error persists, please contact AWS support for further assistance. If a data manifest file was generated at 's3://athena-query-results-lf/8b6714cf-e18e-49e7-bf39-38a08fedf7a6-manifest.csv', you may need to manually clean the data from locations specified in the manifest. Athena will not delete data in your account.
This query ran against the "wifidumper_result_iceberg" database, unless qualified by the query. Please post the error message on our forum  or contact customer support  with Query Id: 8b6714cf-e18e-49e7-bf39-38a08fedf7a6

Load data
```SQL
INSERT INTO wifidumper_result_iceberg.client_iceberg_table
SELECT * FROM wifidumper_result_db.client_parquet 

--compare
select count(*) from wifidumper_result_db.client_parquet  
select count(*) from wifidumper_result_iceberg.client_iceberg_table 

```

Query 
```SQL
select * from wifidumper_result_db.client_parquet
where clientmac= '00:F6:20:9C:B8:27' and check_time = timestamp '2022-02-27 09:20:00.000'

select * from wifidumper_result_iceberg.client_iceberg_table 
where check_time = timestamp '2022-02-27 09:20:00.000'

```

Drop column
```SQL
ALTER TABLE wifidumper_result_iceberg.client_iceberg_table DROP COLUMN raw_bssid
ALTER TABLE wifidumper_result_iceberg.client_iceberg_table DROP COLUMN raw_probedssids
```

Add column
```SQL
ALTER TABLE wifidumper_result_iceberg.client_iceberg_table ADD COLUMNS (client_name string)
```

Rename and reorder column
```SQL
ALTER TABLE wifidumper_result_iceberg.client_iceberg_table
  CHANGE client_name clientname string 
  AFTER clientmac
```

Update data
```SQL
UPDATE wifidumper_result_iceberg.client_iceberg_table 
SET clientname='Raspberry Pi'
WHERE clientmac='B8:27:EB:1E:47:14'

--verify
select * from wifidumper_result_iceberg.client_iceberg_table 
WHERE clientmac='B8:27:EB:1E:47:14'
```

Time travel query
```SQL
-- by timestamp
SELECT * FROM wifidumper_result_iceberg.client_iceberg_table  FOR SYSTEM_TIME AS OF (current_timestamp - interval '3' minute)
WHERE clientmac='B8:27:EB:1E:47:14'

-- by system version (new version when data is updated)
-- 1. get versions
select * from wifidumper_result_iceberg."client_iceberg_table$iceberg_history"

-- 2. query
SELECT * FROM wifidumper_result_iceberg.client_iceberg_table FOR SYSTEM_VERSION AS OF <version_number>
WHERE clientmac='B8:27:EB:1E:47:14'

```

