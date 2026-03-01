#!/bin/bash
# Update the ECS task definition with the new image tag

aws ecs update-service \
            --cluster "ECS_CLUSTER" \
            --service "ECS_SERVICE" \
            --force-new-deployment \
            --desired-count 1 \
            --region "AWS_REGION" \

