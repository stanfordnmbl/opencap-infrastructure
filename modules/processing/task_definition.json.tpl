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
          "name": "CHAIN",
          "value": "bsc"
        },
        {
          "name": "DOCKER",
          "value": "1"
        },
        {
          "name": "FULL_NODE",
          "value": "False"
        },
        {
          "name": "BUILD",
          "value": "1"
        }
      ],
      "secrets": [
        {
          "name": "ANALYTICS_DB_LOGIN",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:660440363484:secret:analytics_db-patuu4:username::"
        },
        {
          "name": "ANALYTICS_DB_PASS",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:660440363484:secret:analytics_db-patuu4:password::"
        },
        {
          "name": "PUPPET_MASTER_PASS",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:660440363484:secret:puppet_master_pass-NcElkl"
        }
      ],
      "resourceRequirements": null,
      "ulimits": null,
      "dnsServers": [],
      "mountPoints": [
        {
          "readOnly": false,
          "containerPath": "/data/bsc/bsc",
          "sourceVolume": "ipc"
        }
      ],
      "workingDirectory": null,
      "dockerSecurityOptions": [],
      "memory": null,
      "memoryReservation": null,
      "volumesFrom": [],
      "stopTimeout": null,
      "image": "660440363484.dkr.ecr.us-east-1.amazonaws.com/opencap/opencap",
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
    },
    {
      "dnsSearchDomains": [],
      "environmentFiles": null,
      "logConfiguration": null,
      "entryPoint": [],
      "portMappings": [
        {
          "hostPort": 8575,
          "protocol": "tcp",
          "containerPort": 8575
        },
        {
          "hostPort": 30311,
          "protocol": "tcp",
          "containerPort": 30311
        },
        {
          "hostPort": 30311,
          "protocol": "udp",
          "containerPort": 30311
        }
      ],
      "command": [],
      "linuxParameters": null,
      "cpu": 0,
      "environment": [],
      "resourceRequirements": null,
      "ulimits": null,
      "dnsServers": [],
      "mountPoints": [
        {
          "readOnly": false,
          "containerPath": "/data",
          "sourceVolume": "ipc"
        }
      ],
      "workingDirectory": null,
      "secrets": null,
      "dockerSecurityOptions": [],
      "memory": null,
      "memoryReservation": null,
      "volumesFrom": [],
      "stopTimeout": null,
      "image": "660440363484.dkr.ecr.us-east-1.amazonaws.com/opencap/openpose:latest",
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
      "name": "bsc"
    }
  ]
