clean-backend:
	rm -rf backend/node_modules
	rm -rf backend/dist

clean-frontend:
	rm -rf frontend/node_modules
	rm -rf frontend/www

build-backend: clean-backend
	cd backend && npm ci && npx webpack && cd dist && zip api.zip *

build-frontend:
	cd frontend && npm ci && npm run build

deploy-backend:
	cd backend/dist && aws s3 cp api.zip s3://${BE_DEPLOYMENT_BUCKET}

deploy-frontend:
	cd frontend/ && aws s3 cp www s3://${FE_DEPLOYMENT_BUCKET} --recursive

prepare-cf:
	sam package \
	  --template-file cloudFormation.yml \
	  --s3-bucket ${BE_DEPLOYMENT_BUCKET} \
	  --output-template-file packaged-template.yml

deploy-cf:
	sam deploy \
		--template-file packaged-template.yml \
		--stack-name ${STACK_NAME} \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			UserEmail=${USER_EMAIL} \
			BucketName=${FE_DEPLOYMENT_BUCKET} \
			DeploymentBucketName=${BE_DEPLOYMENT_BUCKET} 
