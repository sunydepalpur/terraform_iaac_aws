# Terraform AWS IAAC
### To complete this task, please provide Terraform code, that
○ Creates a VPC with 3 Subnets

○ Public, Private, and Workload

○ Create an instance in the workload subnet, that will

○ Create an instance in the private subnet this must only be reachable from the workfload zone

○ Create a possibilty for the instance in the workload zone to reach the internet

○ Once this is done, also provide access to the internet for the instance in the private zone.

○ There must never be a direct connection between private and public. All the traffic needs to go through the workload zone

• Please answer the question:
○ What advantages has this kind of networking architecture?

This is an implementation of 3 tier architecture where public servers handle the client request, which coordinates the execution of the requests with workload / application servers. It adds middle ware(middle tier), which provides a way for public servers to access data on the private servers with maintaining security.

The key benefits are improved security, scalability, improves data integrity, load balancing is much more easier, high performance, lightweight, persistent object.