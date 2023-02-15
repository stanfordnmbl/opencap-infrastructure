[
  {
    "environment": [
      {
        "name": "AWS_REGION",
        "value": "${REGION}"
      },
      {
        "name": "CELERY_BROKER_URL",
        "value": "${SQS_URL}"
      },
      {
        "name": "CELERY_TASK_DEFAULT_QUEUE",
        "value": "${SQS_NAME}"
      }
    ],
  }
]