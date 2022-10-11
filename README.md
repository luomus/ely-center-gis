# ELY center GIS

## Deploy

Log in to openshift server using `oc login`.

To deploy the entire app use:
 
`./oc-process.sh -f template.yml -e .env | oc-create -f -`

Use `-i` flag to deploy a single component of the app at time:

`./oc-process.sh -f template.yml -e .env -i job | oc-create -f -`
