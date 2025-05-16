[
  {
    "name": "${container_name}",
    "image": "${image}",
    "portMappings": [
      {
        "name": "${container_name}", 
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "linuxParameters": {
      "initProcessEnabled": true
    },
    
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "e-commerce-service"
      }
    }
  }
]
