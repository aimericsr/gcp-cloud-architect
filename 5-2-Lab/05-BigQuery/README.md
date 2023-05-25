you can send logs to :
Logging bucket
BigQuery dataset
Cloud Storage bucket
Cloud Pub/Sub topic
Splunk
Other project

create log sink

create a view to see a subset of the sink :
CREATE OR REPLACE VIEW
bq*logs.v_querylogs AS
SELECT
resource.labels.project_id,
protopayload_auditlog.authenticationInfo.principalEmail,
protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobConfiguration.query.query,
protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobConfiguration.query.statementType,
protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatus.error.message,
protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.startTime,
protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.endTime,
TIMESTAMP_DIFF(protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.endTime, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.startTime, MILLISECOND)/1000 AS run_seconds,
protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalProcessedBytes,
protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalSlotMs,
ARRAY(SELECT as STRUCT datasetid, tableId FROM UNNEST(protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.referencedTables)) as tables_ref,
protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalTablesProcessed,
protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.queryOutputRowCount,
severity
FROM
`<YOUR-PROJECT-ID>.bq_logs.cloudaudit_googleapis_com_data_access*\*`
ORDER BY
startTime

SELECT \* FROM bq_logs.v_querylogs
