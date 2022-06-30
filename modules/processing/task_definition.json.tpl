[
    {
      "dnsSearchDomains": [],
      "environmentFiles": null,
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/opencap-processing",
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
        }
      ],
      "resourceRequirements": null,
      "ulimits": null,
      "dnsServers": [],
      "mountPoints": [
        {
          "readOnly": false,
          "containerPath": "/data",
          "sourceVolume": "data"
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
      "name": "opencap"
    },
    {
      "dnsSearchDomains": [],
      "environmentFiles": null,
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/opencap-openpose",
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
      "environment": [],
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
          "containerPath": "/openpose/data",
          "sourceVolume": "data"
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
    }
  ]
