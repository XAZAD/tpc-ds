# Preparing VM for GCP

## Install software
```bash
# Ubuntu
???

# Ubuntu 20.04WSL
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-437.0.1-linux-x86_64.tar.gz
tar -xf google-cloud-cli-437.0.1-linux-x86_64.tar.gz && ./google-cloud-sdk/install.sh
./google-cloud-sdk/bin/gcloud init --console-only
```

## Build tools. It needs gcc version 9
```bash
./bin/build-tool.sh
```

## Preparation data
scale:
1 - 1G
10 - 10G
100 - 100G
1000 - 1Tb

```bash
./bin/generate-data.sh <scale>
```

Example for 100 G
```bash
./bin/generate-data.sh 100 # 100 is scale
```


## Schema of DB
DDL query is `tools\tpcds.sql`
