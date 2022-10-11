# ELY center GIS

## Deployment

### Setup

Log in to openshift server using `oc login`.

If needed, create a new project with:

`oc new-project ely-center-gis`

Switch to project with:

`oc project ely-center-gis`

### Environment variables

Deployment requires setting a number of environment variables. See `.env` file
for required variables.

### Deploy

To deploy the entire app use:
 
`./oc-process.sh -f template.yml -e .env | oc create -f -`

Use `-i` flag to deploy a single component of the app at time:

`./oc-process.sh -f template.yml -e .env -i job | oc create -f -`
