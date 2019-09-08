#!/bin/bash
docker build . -t simonmassey/ocd-release-build
docker push simonmassey/ocd-release-build:latest
