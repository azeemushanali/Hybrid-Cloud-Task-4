# Hybrid-Cloud-Task-4 ![Visitors](https://visitor-badge.laobi.icu/badge?page_id=az/hybridcloudtask4)
Hello and welcome to all.In this article we will be getting some hands on knowledge over some of the leading technology and that is Cloud Computing with Automation by Terraform. Before moving on further with the task let us first understand the agenda.

This is the hands on task which will do following things -
1. Write an Infrastructure as code using terraform, which automatically create a VPC.
2. In that VPC we have to create 2 subnets:
1. public subnet [ Accessible for Public World! ]
2. private subnet [ Restricted for Public World!
3. Create a public facing internet gateway for connect our VPC/Network to the internet world and attach this gateway to our VPC.
4. Create a routing table for Internet gateway so that instance can connect to outside world, update and associate it with public subnet.
5. Create a NAT gateway for connect our VPC/Network to the internet world and attach this gateway to our VPC in the public network
6. Update the routing table of the private subnet, so that to access the internet it uses the NAT gateway created in the public subnet
7. Launch an ec2 instance which has WordPress setup already having the security group allowing port 80 so that our client can connect to our WordPress site. Also attach the key to instance for further login into it.
8. Launch an ec2 instance which has MySQL setup already with security group allowing port 3306 in private subnet so that our WordPress VM can connect with the same. Also attach the key with the same.
Note: WordPress instance has to be part of public subnet so that our client can connect our site.MySQL instance has to be part of private subnet so that outside world can't connect to it.
Don't forgot to add auto IP assign and auto DNS name assignment option to be enabled.

![Output](https://github.com/azeemushanali/Hybrid-Cloud-Task-4/blob/master/images/Screenshot%20(46).png?raw=true)
