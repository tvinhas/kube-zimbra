# Devops stack Monitoring and Observability

With the growth of the devops stacks came the need for a more modern and pratical approach for monitoring the application health and
metrics collection that can help us prevent incidents and outages from happening.

## Choosing the Right Tools

There is a plethora of tools available that can help us. We can leverage tools with a some kind of cloud native appeal now, so in the 
future as our stack grows, we don't have to worry about replacing these tools. It's also important to not try to reinvent the wheel by
using tools with backed by large and vibrant open source communities.
With that in mind, our suggestion at this moment would be based on the following tools:

* ### Prometheus
    [Prometheus](https://prometheus.io/) is an open source monitoring and alerting platform that scrapes and stores time series data. It's
extremely extensible through exporters for all kinds of services.

* ### InfluxDB
[InfluxDB](https://influxdata.com/) is a time series database designed to handle high write and query loads. It's a good alternative to
Prometheus's default local disk database when we take the high traffic of our application in consideration.

* ### Grafana
[Grafana](https://grafana.com/) is a tool widely used to create complex dashboards and graphics based on metrics collected by other tools.

## Why use them together?

The Prometheus ecosystem contains a number of actively maintained exporters, such as the node exporter for reporting hardware and 
operating system metrics or Google’s cAdvisor exporter for monitoring containers. InfluxDB will be the database where all the data
collected will be stored. Dashboards will be created on Grafana with dynamically generated graphics that read from the metrics created
by Prometheus.

## Monitoring container metrics using Prometheus and cAdvisor

cAdvisor (short for container Advisor) analyzes and exposes resource usage and performance data from running containers. cAdvisor exposes
Prometheus metrics out of the box.

## Application Metrics
Using the `/health` endpoint on our application, Prometheus will collect its data and a dashboard in Grafana will show different graphics.

## Alerts
One of the most important tools that come with Prometheus is Alertmanager. It can be integrated with different applications or services to
deliver notifications and alerts. We can choose to have alerts delivered by e-mail and outages or critical alerts can use tools such as
PagerDuty or OpsGenie to text and/or call the oncall person's phone.


