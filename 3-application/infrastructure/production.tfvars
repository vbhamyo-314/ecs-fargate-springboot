# remote state
remote_state_key    = "layer1/platform.tfstate"
remote_state_bucket = "ecs-fargate-terraform-remote-state-v1"

# service variables
ecs_service_name      = "springbootapp"
docker_container_port = 8080
desired_task_number   = "2"
spring_profile        = "default"
memory                = 1024
