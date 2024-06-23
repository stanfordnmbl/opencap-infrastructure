[
    {
      "dnsSearchDomains": [],
      "environmentFiles": null,
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/${APP_NAME}-processing${ENV}",
          "awslogs-region": "${REGION}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "entryPoint": [],
      "portMappings": [],
      "command": [],
      "linuxParameters": null,
      "cpu": 0,
      "environment": [
        {
          "name": "DOCKERCOMPOSE",
	        "value": "1"
        }
      ],
      "secrets": [
        {
          "name": "API_TOKEN",
	        "valueFrom": "${API_TOKEN}"
        },
        {
          "name": "API_URL",
          "valueFrom": "${API_URL}"
        }
      ],
      "resourceRequirements" : [
          {
             "type" : "GPU",
             "value" : "1"
          }
      ],
      "ulimits": null,
      "dnsServers": [],
      "mountPoints": [
        {
          "readOnly": false,
          "containerPath": "/data",
          "sourceVolume": "data${ENV}"
        }
      ],
      "workingDirectory": null,
      "dockerSecurityOptions": [],
      "memory": null,
      "memoryReservation": null,
      "volumesFrom": [],
      "stopTimeout": null,
      "image": "${OPENCAP}",
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
      "name": "${APP_NAME}"
    },
    {
      "dnsSearchDomains": [],
      "environmentFiles": null,
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/${APP_NAME}-openpose${ENV}",
          "awslogs-region": "${REGION}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "entryPoint": [],
      "portMappings": [
      ],
      "command": [],
      "linuxParameters": null,
      "cpu": 0,
      "environment": [
        {
          "name": "NVIDIA_VISIBLE_DEVICES",
          "value": "0"
        }
      ],
      "ulimits": null,
      "dnsServers": [],
      "mountPoints": [
        {
          "readOnly": false,
          "containerPath": "/openpose/data",
          "sourceVolume": "data${ENV}"
        }
      ],
      "workingDirectory": null,
      "secrets": null,
      "dockerSecurityOptions": [],
      "memory": null,
      "memoryReservation": null,
      "volumesFrom": [],
      "stopTimeout": null,
      "image": "${OPENPOSE}",
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
      "dockerLabels": {},
      "systemControls": [],
      "privileged": null,
      "name": "openpose"
    },
    {
      "dnsSearchDomains": [],
      "environmentFiles": null,
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/${APP_NAME}-mmpose${ENV}",
          "awslogs-region": "${REGION}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "entryPoint": [],
      "portMappings": [
      ],
      "command": [],
      "linuxParameters": null,
      "cpu": 0,
      "environment": [
        {
          "name": "NVIDIA_VISIBLE_DEVICES",
          "value": "0"
        }
      ],
      "ulimits": null,
      "dnsServers": [],
      "mountPoints": [
        {
          "readOnly": false,
          "containerPath": "/mmpose/data",
          "sourceVolume": "data${ENV}"
        }
      ],
      "workingDirectory": null,
      "secrets": null,
      "dockerSecurityOptions": [],
      "memory": null,
      "memoryReservation": null,
      "volumesFrom": [],
      "stopTimeout": null,
      "image": "${MMPOSE}",
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
      "dockerLabels": {},
      "systemControls": [],
      "privileged": null,
      "name": "mmpose"
    }
  ]
