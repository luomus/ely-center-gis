# ELY center GIS

## Deployment

### Setup

Log in to openshift server using `oc login`.

If needed, create a new project with:

`oc new-project ely-center-gis`

Switch to project with:

`oc project ely-center-gis`

### Environment variables

Deployment requires setting a number of environment variables

```sh
# Access token for production FinBIF API
FINBIF_ACCESS_TOKEN=

# Base URL for production FinBIF API
FINBIF_API_URL=

# Access token for development FinBIF API
FINBIF_DEV_ACCESS_TOKEN=

# Base URL for development FinBIF API
FINBIF_DEV_API_URL=

# Path to FinBIF data warehouse
FINBIF_WAREHOUSE=

# Email address for FinBIF API user
FINBIF_EMAIL=

# Name to assign to PostGIS database
DB_NAME=

# Internal port where PostGIS database can be reached
DB_PORT=

# PostGIS database username
DB_USER=

# PostGIS database user password
DB_USER_PASSWORD=
```

### Deploy

To deploy the entire app use:
 
`./oc-process.sh -f template.yml -e .env | oc create -f -`

Use `-i` flag to deploy a single component of the app at time:

`./oc-process.sh -f template.yml -e .env -i job | oc create -f -`
