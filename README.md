![Terraform AWS ECS Cluster](https://miro.medium.com/max/700/1*A-WiJ5SoQ1C3hlYLWi0m3g.png)

Creating an AWS ECS cluster using Terraform. 

The code includes: 
- Docker test image for Nginx
- Load Balancer
- Creating a registry of elastic containers
- Creating an Amazon Elastic Container Cluster with metrics tracking via CloudWatch
- Warm pool prepared for rapid scaling based on metrics

All variables are stored in variables.tf to run on any server with the ability to quickly specify your parameters for the build.
