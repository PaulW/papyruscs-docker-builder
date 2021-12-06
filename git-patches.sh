#!/bin/bash
# Use this file to pull any other PR's which you want to build in.
git fetch -q origin +refs/pull/95/merge:
git checkout -qf FETCH_HEAD
