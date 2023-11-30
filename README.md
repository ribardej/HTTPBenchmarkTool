# HTTPBenchmarkTool [![Build Status](https://github.com/ribardej/HTTPBenchmarkTool.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ribardej/HTTPBenchmarkTool.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Purpose
HTTP benchmark tool will make possible to simulate traffic on a server and provide statistics along with their visualization.

## Functionality
User needs to provide at least three parameters:
1. url adress or IP adress of targeted server
2. number of parallel(asynchronous) clients
3. total number of requests to be made

There will be also keyword arguments specifying the later analysis and visualization of the measurment results - Right now I can not say how will the arguments look like(I did not figure out yet. Will do during implementation)

During the measurment the total number of requests will be distributed between the clients. Each client will make the requests asynchronously.

## Areas of measurment
+ number of requests/second
+ average response time
+ distribution of response times - some kind of histogram
+ (possibly further statistical analysis of response times)