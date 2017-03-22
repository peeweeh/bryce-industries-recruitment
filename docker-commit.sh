ECS_SERVICE=arn:aws:ecs:ap-southeast-1:650143975734:service/bryce-web
ECS_CLUSTER=arn:aws:ecs:ap-southeast-1:650143975734:cluster/BryceSystems
ECS_TASK=arn:aws:ecs:ap-southeast-1:650143975734:task-definition/bryce-recruitment:
ECS_REPO=650143975734.dkr.ecr.ap-southeast-1.amazonaws.com/bryce-web:latest
ECS_REPO_NAME=bryce-web
ECS_REPO_TAG=bryce-web:latest

echo "Building Container"
aws ecr get-login --region ap-southeast-1 --profile trend | sh
docker build -t $ECS_REPO_NAME .
docker tag $ECS_REPO_TAG $ECS_REPO
docker push $ECS_REPO

echo "Creating Task Definition"
REV=$(aws ecs register-task-definition --cli-input-json file://task-definition.json  --region ap-southeast-1 --profile trend --query 'taskDefinition.revision')
echo "Updating Service"
aws ecs update-service --service $ECS_SERVICE --cluster $ECS_CLUSTER --task-definition $ECS_TASK$REV --region ap-southeast-1 --profile trend
echo "Done"