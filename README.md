# Cloud_Resume_Backend
Architecture: ![image](https://user-images.githubusercontent.com/47158510/233435755-5460c85e-05f5-4dc7-a9d9-4a17a8d7005b.png)

This repo contains the terraform files and code for the Lambda, API Gateway, and DynamoDB portions of this project.  The front end files and content distribtuion portions can be found [here](https://github.com/Tside777/Cloud_Resume_Infra).

Future Improvements:
- Enhance testing by leveraging PyTest instead of unittest
- Adjust GitHub Actions to run tests on pull requests and not deploy infra changes until merged.
- Expand infra to include a "dev" environment where changes are staged prior to "prod" deployment
