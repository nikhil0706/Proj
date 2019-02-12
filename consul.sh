https://developer.equinix.com/microservices-registration-and-discovery-using-consul


A microservice is built and deployed independently, and can be integrated into an application as an independent component, using APIs. This also makes sure the failure of one component does not bring down the entire application. While microservices architecture is an appealing style to build a high-availability application, we are faced with a new problem: how to manage an ever increasing number of microservice instances? There are multiple solutions available today to handle the service registration, discovery and load balancing. Our focus today is Consul, one of the best in class tool for service discovery, owned by Hashicorp and available in open source and enterprise version.

 

What is Consul?
Consul is the one stop solution for microservices (self) registration, discovery, health checks, key-value store and load balancing. Consul is multi-data center aware by default, which means we can connect consul clusters from multiple DCs. Consul works as a cluster of client and server processes. 

Service registration and discovery
A service can be registered using a service definition, or by using the HTTP API. The microservice can register itself with Consul using the HTTP APIs during start up. Once the service is registered with Consul, any service which is in the same Consul cluster can discover and consume it.

De-registering services
Consul also allows to de-register a service via its exposed HTTP APIs. De-registration APIs allow the services to remove itself from the Consul registry. Combining de-registration with the self registration during server startup can help us achieve zero downtime during deployments. This means, during sequential/rolling deployment of services while one node is under deployment, the other node(s) will remain available. 

Load balancing & DNS interface
Consul provides a DNS interface. Every service is registered with the 'service.consul' domain. This is discoverable within the cluster (and outside, if it is registered as an external service). A service is registered with the same service name in all the instances it is deployed. When multiple instances are serving APIs - containerized or clustered, load balancing is crucial. Consul's default load balancing - a randomized round robin response - is suitable for most of the scenarios. This means that when a service is deployed in two nodes under the same name, each time  a request comes to Consul servers, the nodes are hit in a random fashion similar to round robin (It is not guaranteed that the nodes are hit one after the other). However, there is a little latency associated with DNS interface which is fine for most of our use cases. For latency sensitive applications, we can always plug in a load balancer within  Consul like HA Proxy. 

Why Consul?
Consul set up is straight forward. It hardly takes half a day to set up the cluster for a couple of dozen nodes. Installation of the client and server agents are as simple as downloading and unzipping a single binary file, for both clients and servers. The DNS interface resolves the service names to different instances each time a service is called(in a round robin fashion). This helps removing one layer of infrastructure, i.e. a load balancer with static configuration. The clients will have to be Consul-aware, though. This means instead of mapping the proxy, we will be mapping the Consul service names.

The most important of all, is the extensive health check mechanism to monitor the service instances. The default health check script keeps checking the aliveness of registered services, with an easy way to integrate any number of custom health checks. depending on the time-out configured, the health checks are triggered periodically. Health check scripts should return PASSING, WARNING or CRITICAL response. Consul redirects requests only to healthy service instances - PASSING or WARING - using its DNS interface therebyimproving the availability of the services. If a service runs in critical health longer than the configured deregistration timeout (parameter: deregisterCriticalServicesAfter) Consul deregisters the service. Once the service is back available, since the health check is registered already, it is added back to the list of healthy service instances. Please find a set of basic health checks with the attachments.

The next useful feature is the hierarchical key value store. The KV store helps storing the data, such as ports, service parameters, just to name a few. Consul picks the service instances in a round-robin fashion by default. Like the health checks, this can also be extended to use other load balancing solutions. In other words, Consul is a ready-to-use solution with scope for a variety of customisation. A Consul agent is a long running daemon process with a rather simple 3-step set up, as explained in the set-up section. There can be thousands of client agents running within a Consul cluster. These agents are responsible for checking the health of the node and/or the service. However, we need only a few server agents within a Consul cluster. Though a cluster can function with a single server agent, it is highly recommended to run 3 or 5 server agents to avoid Consul becoming the single point of failure for the application. Below is the picture depicting the Consul architecture (from Consul official documentation).

Service Directory (GSD) > Microservices registration and discovery using Consul > consul-architecture.png

consul-architecture.png

Clients and servers:
Each node which is part of the cluster is required to run a client agent. The Consul client agent registers the services, checks the health of the services or the node itself, but forwards all the service discovery requests to the servers. A client is stateless. Apart from the frequent gossiping, these daemon processes are not running anything in the background. This design helps maintain the client agents lightweight, there by supporting rapid horizontal scalability of thousands of clients with 3 or 5 server agents.  The clients communicate to each other using the gossip protocol, and use UDP pings most of the time.

A server agent can be either a leader, follower, or a candidate. Each server starts out as a follower, and once all the servers are started a leader is elected. We can also specify which server to be elected as leader at first, by bootstrapping. The leader handles all the requests from the client agents, and replicates the state to its peers (follower server nodes). If a follower receives a request, it is forwarded to the leader. The leader election is based on a consensus protocol called Serf. Underlying Consul is the Raft db which stores the state and logs the changes. The data is replicated between the servers. 

Consul servers from different DCs can talk over the WAN using WAN gossip using TCP/UDP . Click here to read more.

How to set up Consul
Below is an example of a Cluster set up with 3 server nodes and a couple of clients.

This section talks specifically about setting up Consul agents in Linux VMs. Here, we will set up a 3-server and n-client cluster. Let's say, each micro service (of a particular version) is deployed to two VMs. The client agents will be installed onto each of these VMs and will be joined to the cluster. This section talks only about registering the internal Java Play micro services, which are running on VMs and accessible via VPN.

Installation instructions:
Download and unzip:
              sudo wget https://releases.hashicorp.com/consul/0.7.2/consul_0.7.2_linux_amd64.zip

              sudo unzip consul_0.7.2_linux_amd64.zip

       2. Start the agent in server mode in all the VMs which are going to be running as server agents:

               consul agent -server  -data-dir /tmp/consul -join=<IP.of.any.vm.in.the.cluster>

               Alternatively, the configuration can be specified in a config file, which is recommended for production use.

              consul agent -server -config-file=./consul-config.json

      3. Start the agents in client mode on all the VMs which are going to register/use the services:

           consul agent -data-dir /tmp/consul -config-dir /etc/consul.d  -join=<IP.of.any.vm.in.the.cluster>

     

By now, the clients and servers are running and are part of a Consul cluster.

Service Registration
The consul agent must be running on the VM where the service is deployed.

       1. Manual registration using consul agent's REST API during Service startup
          a) In the start.sh, register the service to Consul using:

               curl -X PUT -d '{"ID": <ServiceID>, "Name": <ServiceName>, "Check": {"id": <CheckID>, "script": <custom script to check the service health>, "interval": <e.g. 10s>}}' http://localhost:8500/v1/agent/service/register

          b) Upload the port number of the service to the consul key value store:

              curl -X PUT -d $PORT http://localhost:8500/v1/kv/<ServiceID>

       2. Self-Registration of Service - Java Spring boot
            a) Add the following dependency in pom.xml

<dependency>

<groupId>org.springframework.cloud</groupId>

<artifactId>spring-cloud-starter-consul-discovery</artifactId>

</dependency>

  <dependencyManagement>

               <dependencies> 

  <dependency> 

    <groupId>org.springframework.cloud</groupId> 

    <artifactId>spring-cloud-consul- dependencies</artifactId> 

    <version>1.1.2.RELEASE</version> 

    <type>pom</type> 

    <scope>import</scope> 

  </dependency> 

</dependencies>

</dependencyManagement>

 

         b) Add the following configuration in application.yml file.

spring:

   application:

      name: <Service name>

  cloud:

     consul:

        discovery:

           preferAgentAddress: true

           tags: <API Version>

           healthCheckPath: /management/health

           healthCheckInterval: 5s

 

In short, the service registers itself to Consul. When the service is registered consul stores it as <ServiceID>.service.consul. This is accessible to any applications in VMs running agents of the same cluster.

Service Discovery and Verification
Any agent that is part of the same cluster can discover and use the registered service. 

 

              On the client machine, ping the Service (<ServiceID>.service.consul). You will see response coming from different VMs, where the Services are running

               ping  -c1 <ServiceID>.service.consul

               Then hit the Microservice from the client machine using the "curl" command. Here, you will use Consul ServiceID instead of Hostname. If this works, you application should have no problem in                          calling the Microservice

               curl -X GET http://<ServiceId>.service.consul:<port>/index

 

 There is also a Java API Client available for Service Discovery, which will return list of Healthy Microservices.

System Configuration

Linux specific configurations:

Install dnsmasq to forward and resolve consul domain queries from consul DNS port to default DNS port of the VM.

Dnsmasq configuration is under /etc/dnsmasq.d by default.

Create a file which will have the below content: 

server=/consul/127.0.0.1#8600

Edit /etc/dnsmasq.conf and uncomment listen-address.

listen-address=127.0.0.1

Network Manager util to add 'Nameserver 127.0.0.1' to /etc/resolv.conf

References
 https://www.consul.io

https://github.com/hashicorp/consul

https://github.com/consul/consul/issues

https://www.consul.io/docs/guides/consul-containers.html

https://releases.hashicorp.com/consul/1.2.0/
