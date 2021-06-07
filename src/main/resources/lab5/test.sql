SELECT
  UNIX_MILLIS(event_timestamp) - min_millis.min_event_millis AS event_millis,
  UNIX_MILLIS(processing_timestamp) - min_millis.min_event_millis AS processing_millis,
  user_id,

  -- added as unique label so we see all the points
  CAST(UNIX_MILLIS(event_timestamp) - min_millis.min_event_millis AS STRING) AS label
FROM
  `logs.raw`
CROSS JOIN (
  SELECT
    MIN(UNIX_MILLIS(event_timestamp)) AS min_event_millis
  FROM
    `logs.raw`) min_millis
WHERE
  event_timestamp IS NOT NULL
ORDER BY
  event_millis ASC