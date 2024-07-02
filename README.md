# ELY center GIS

## Deployment

### Setup

Log in to openshift server using `oc login`.

If needed, create a new project with:

`oc new-project ely-center-gis`

Switch to project with:

`oc project ely-center-gis`

### Environment variables

Deployment requires setting a number of environment variables, e.g.,

```sh
# Access token for production FinBIF API
FINBIF_ACCESS_TOKEN=

# Base URL for production FinBIF API
FINBIF_API_URL=

# Access token for development FinBIF API
FINBIF_ACCESS_TOKEN_DEV=

# Base URL for development FinBIF API
FINBIF_API_URL_DEV=

# Path to FinBIF data warehouse
FINBIF_WAREHOUSE=

# Email address for FinBIF API user
FINBIF_EMAIL=

# PostGIS database password
DB_PASSWORD=

# PostGIS development database password
DB_PASSWORD_DEV=
```

### Deploy

To deploy the entire app use:
 
`./oc-process.sh -i all | oc create -f -`

Use `-i` flag to deploy a single component of the app at time:

`./oc-process.sh -i job | oc create -f -`
