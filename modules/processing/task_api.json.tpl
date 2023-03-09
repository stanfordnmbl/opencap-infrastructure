[
    {
      "dnsSearchDomains": [],
      "environmentFiles": null,
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/${APP_NAME}-api${ENV}",
          "awslogs-region": "${REGION}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "entryPoint": [],
      "portMappings": [
        {
          "hostPort": 80,
          "protocol": "tcp",
          "containerPort": 80
        }
      ],
      "command": ${jsonencode(split(",", CMD))},
      "linuxParameters": null,
      "cpu": 0,
      "environment": [
        {
          "name": "AWS_STORAGE_BUCKET_NAME",
          "value": "mc-mocap-video-storage"
        },
        {
          "name": "HOST",
          "value": "${API_HOST}"
        },
        {
          "name": "PROTOCOL",
          "value": "https"
        },
        {
          "name": "DB_HOST",
          "value": "${DB_HOST}"
        },
        {
          "name": "DEBUG",
          "value": "${DEBUG}"
        },
        {
          "name": "REDIS_URL",
          "value": "${REDIS_URL}"
        }
      ],
      "secrets": [
        {
          "name": "API_TOKEN",
          "valueFrom": "${API_TOKEN}"
        },
        {
          "name": "AWS_ACCESS_KEY_ID",
          "valueFrom": "${API_AWS_KEY}"
        },
        {
          "name": "AWS_SECRET_ACCESS_KEY",
          "valueFrom": "${API_AWS_SECRET}"
        },
        {
          "name": "DB_USER",
          "valueFrom": "${DB_USER_ARN}"
        },
        {
          "name": "DB_PASS",
          "valueFrom": "${DB_PASS_ARN}"
        },
        {
          "name": "SENDGRID_API_KEY",
          "valueFrom": "${SENDGRID_API_KEY}"
        }        
      ],
      "resourceRequirements": null,
      "ulimits": null,
      "dnsServers": [],
      "mountPoints": [],
      "workingDirectory": null,
      "dockerSecurityOptions": [],
      "memory": null,
      "memoryReservation": null,
      "volumesFrom": [],
      "stopTimeout": null,
      "image": "${OPENCAP_API}",
      "startTimeout": null,
      "firelensConfiguration": null,
      "dependsOn": null,
      "disableNetworking": null,
      "interactive": null,
      "healthCheck": null,
      "essential": true,
      "links": [],
      "hostname": null,
      "extraHosts": null,
      "pseudoTerminal": null,
      "user": null,
      "readonlyRootFilesystem": null,
      "dockerLabels": null,
      "systemControls": [],
      "privileged": null,
      "name": "code"
    }
]
