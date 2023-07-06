# AWS (Amazon Web Services)

## Differences between Azure and AWS:
---

* Resource groups 
  - in Azure, everything needs to go in a Resource group
  - in AWS, there is no need for Resource Groups. They exist but not necessery.

* Public IP addresses 
  - in Azure, by default, uses static
  - in AWS, by default, use dynamic (changes it every time your VM restarts)

* Terminology
  - Launch in AWS = Create in Azure
  - Instance in AWS = VM in Azure


# Starting EC2 instance:

* **At the beginning, after logging in to AWS portal with your credentials make sure to change the region for EUROPE (Ireland).**

![region](region.png)

* **EC2 -> Instances -> Launch instances - over here we can launch (create) instances (VMs)**
  
![instances](list-of-instances.png)
  
* **search for image : 18.04 LTS 1e9 (community AMIs) - this is the version of the Ubuntu we are using for test purposes**

![ubuntu](ubuntu-version.png)

* **t2.micro for Instance type**
* **Network security groups (SSH, HTTP, 3000) -for Sparta app or (SSH, 27017) for db.**

![Securitu](new-sg.png)

<mark>**We can also save Security group rules and reused them later**

![existing-sg](existing-sg.png)

* **After launching an instance we can stop it or terminate it simply from the AWS EC2 dashboard**

![terminate](stop-start-terminate-instances.png)

## In case of setup SSH key in AWS:
---

* type 'key pair' -> create key pair.
* RSA key pair type
* Key file format .pem

![key-pair](key-pair.png)

## Connect to SSH:
---

`ssh -i "~/.ssh/tech241.pem" ubuntu@ec2-54-73-7-211.eu-west-1.compute.amazonaws.com`

<mark>**REMEMBER**</mark> IP is dynamic so you won't be able to log back in with the same IP in the command

![ssh](shh-in.png)

# Running sparta app and db scripts on AWS instances:

After sucessfully logging in to instances to run our scripts it is simply copying and pasting the same code we used in Azure.

# Private and Public IP differences:

In the particular scenario of our Sparta app and Mongo db, we can connect app to db by using Private IP. If both VMs are created within one Virtual Network the step will ommit security check for port 27017 and connect 'directly'. It has benefit because the public ip of db is dynamic, but private is static. 


## App script:
---

```bash
#!/bin/bash


# update
sudo apt update -y

# upgrade
sudo apt upgrade -y
# install nginx
sudo apt install nginx -y

# enable nginx
sudo systemctl enable nginx
# installing sed
sudo apt install sed
# setup nginx as a reverse proxy
sudo sed -i 's@try_files .*;@proxy_pass http://localhost:3000;@' /etc/nginx/sites-available/default
# restart nginx again
sudo systemctl restart nginx
# get from url needed version of node
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
# install nodejs
sudo apt install -y nodejs
#installing pm2 that helps run apps in the background
sudo npm install pm2 -g
# getting app folder to the VM
git clone https://github.com/majeranowski/tech241-sparta-app.git repo
#getting inside app folder
cd repo/app
#Creating DB_HOST env variable
export DB_HOST=mongodb://172.31.38.156:27017/posts
# installing the app
npm install
# populates database in case there are no posts
node seeds/seed.js
# kills previous background processes
pm2 kill
# starting the app
pm2 start app.js     

```

## **Notes**: 

* in the command for creating DB_HOST env variable we need to remember that IP for our DB instance will be dynamic. We have to specify the correct IP address before running the script.
  
  ---

## DB script

```bash
#!/bin/bash

# Update and upgrade the system
sudo apt update -y
sudo apt upgrade -y

#to download key for the right version (from mongo db website)
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -

# source list
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# update again
sudo apt update -y

# install mongo db
sudo apt-get install -y mongodb-org=3.2.20 mongodb-org-server=3.2.20 mongodb-org-shell=3.2.20 mongodb-org-mongos=3.2.20 mongodb-org-tools=3.2.20

# Configure bindIp to 0.0.0.0
sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf

# Start Mongo DB
sudo systemctl start mongod

# Enable Mongo DB
sudo systemctl enable mongod
```
--- 


**After sucessfully running both scripts everything should work like that:**


---

![working-app](working-app.png)

---

# Logging/SSHing in and running app script

## Scenario 1 as Ubuntu:

pwd

/home/ubuntu

git clone ... repo

/home/ubuntu/repo

cd repo/app

---

## Scenario 2 - get VM to run app script for us (as root user)

pwd 

/

git clone ... repo

/repo

cd repo/app

---

# AMIs

**AMI - Amazon Machine Image**

If we have VM and want to duplicate it. AMI is the image of that VM. Part of creating AMI is taking a snapshot of the disk. 
If we have an image we can make identical copy of VM.

## **Creating an AMI**

---



![creating-ami](creating-ami.png)
![creating-ami](image-tags.png)

## **Launching an instance from AMI**

![creating-ami](launching-ami.png)

---

When we launch an instance from AMI we wo't have to specify the image of the operating system and copy of the disk will be exactly the same as from the copied instance, including user data we ran before.

## **User Data**

---

User data is a place while creating an instance where we can write some commands. User data will be executed while creating an Instance.
User data will run only once, when creating VM.

We can add it while launching an instance in 'Advance settings'

![user-data](user-data.png)

# Monitoring and alerts

First step is to enable detailed monitoring in our Instances:

* We can do in in our instance dashboard inside 'monitoring' tab

![1ststep](adding-to-dashboard.png)
![1ststep](enable.png)

# Setting up a CPU usage alarm using the AWS Management Console
**Use these steps to use the AWS Management Console to create a CPU usage alarm.**

* To create an alarm based on CPU usage
Open the CloudWatch console at https://console.aws.amazon.com/cloudwatch/.

* In the navigation pane, choose Alarms, All Alarms.

![1ststep](alarms-all-allarms.png)

* Choose Create alarm.

* Choose Select metric.

* In the All metrics tab, choose EC2 metrics.

* Choose a metric category (for example, Per-Instance Metrics).

 - Find the row with the instance that you want listed in the   InstanceId column and CPUUtilization in the Metric Name column. Select the check box next to this row, and choose Select metric.

![1ststep](cpumetric.png)

* Under Specify metric and conditions, for Statistic choose Average, choose one of the predefined percentiles, or specify a custom percentile (for example, p95.45).

* Choose a period (for example, 5 minutes).

* Under Conditions, specify the following:

* For Threshold type, choose Static.

   - For Whenever CPUUtilization is, specify Greater. Under than..., specify the threshold that is to trigger the alarm to go to ALARM state if the CPU utilization exceeds this percentage. For example, 70.

   - Choose Additional configuration. For Datapoints to alarm, specify how many evaluation periods (data points) must be in the ALARM state to trigger the alarm. If the two values here match, you create an alarm that goes to ALARM state if that many consecutive periods are breaching.

   - To create an M out of N alarm, specify a lower number for the first value than you specify for the second value. For more information, see Evaluating an alarm.

  -  For Missing data treatment, choose how to have the alarm behave when some data points are missing. For more information, see Configuring how CloudWatch alarms treat missing data.

  -  If the alarm uses a percentile as the monitored statistic, a Percentiles with low samples box appears. Use it to choose whether to evaluate or ignore cases with low sample rates. If you choose ignore (maintain alarm state), the current alarm state is always maintained when the sample size is too low. For more information, see Percentile-based CloudWatch alarms and low data samples.

![1ststep](treshold.png)

* Choose Next.

* Under Notification, choose In alarm and select an SNS topic to notify when the alarm is in ALARM state

    -  To have the alarm send multiple notifications for the same alarm state or for different alarm states, choose Add notification.

   - To have the alarm not send notifications, choose Remove.

![1ststep](alarms.png)

* When finished, choose Next.

* Enter a name and description for the alarm. Then choose Next.


Under Preview and create, confirm that the information and conditions are what you want, then choose Create alarm.

When CPU usage reaches the specified limit we will be notify via email and status of the alrm will change to 'in alarm'

![1ststep](mail.png)
![1ststep](in-alarm.png)

# S3 (Simple storage system)

Similiar to blob storage in Azure.

Amazon Simple Storage Service (Amazon S3) is an object storage service that offers industry-leading scalability, data availability, security, and performance. Customers of all sizes and industries can use Amazon S3 to store and protect any amount of data for a range of use cases, such as data lakes, websites, mobile applications, backup and restore, archive, enterprise applications, IoT devices, and big data analytics. Amazon S3 provides management features so that you can optimize, organize, and configure access to your data to meet your specific business, organizational, and compliance requirements.


## AWS CLI

---

`aws s3 ls` - listing all the buckets (containers)

`aws s3 mb s3://tech241-krzysztof-bucket --region eu-west-1` - creating a bucket

`aws s3 cp testfile.txt s3://tech241-krzysztof-bucket` - upload the file to the bucket

`aws s3 sync s3://tech241-krzysztof-bucket s3_download` - get the files from the bucket

`aws s3 rm s3://tech241-krzysztof-bucket/testfile.txt` - delete the file from the bucket 

`aws s3 rm s3://tech241-krzysztof-bucket --recursive` - delete everything from the bucket. all the files inside but not the bucket

`aws s3 rb s3://tech241-krzysztof-bucket` - delete the bucket

---

# BOTO3

**Boto3 is the name of the Python SDK (Software Development Kit) for AWS. It allows you to directly create, update, and delete AWS resources from your Python scripts.**

## Python Scripts using boto3 for s3

---

### Creating a bucket:

---

```python
# first thing is to import boto3 library

# set up an s3 connection

# create a bucket in the eu-west-1 region

# print bucket name to confirm script

import boto3

s3 = boto3.client('s3')

bucket_name = s3.create_bucket(Bucket= "tech241-krzysztof-python-bucket", CreateBucketConfiguration={"LocationConstraint":"eu-west-1"})

print(bucket_name)
```

### Deleting a bucket:

---

```python
import boto3

s3 = boto3.resource("s3")

bucket = s3.Bucket("tech241-krzysztof-python-bucket")

response = bucket.delete()

print(response)
```

### Uploading file to a bucket:

---

```python
#import boto3

# hints -> you will need a s3 variable, a bucket variable and a response variable

# Can you work out what boto3 methods you need to use and the data they need to work

# print response

#find a way to upload testfile.txt to your bucket using boto3
import boto3


s3 = boto3.client('s3')

bucket_name = 'tech241-krzysztof-python-bucket'
file_name = 'testfile.txt'


response = s3.upload_file(file_name, bucket_name, file_name)

print(s3.list_objects_v2(Bucket=bucket_name))

```

### Downloading file from a bucket:

---

```python
import boto3

s3 = boto3.client('s3')

bucket_name = 'tech241-krzysztof-python-bucket'
file_name = 'testfile.txt'
destination = 'downloadedfile.txt'
response = s3.download_file(Bucket=bucket_name, Key=file_name, Filename=destination)

```

### Removing file from a bucket:

---

```python
import boto3


s3 = boto3.client('s3')

bucket_name = 'tech241-krzysztof-python-bucket'
file_name = 'testfile.txt'

response = s3.delete_object(Bucket=bucket_name, Key=file_name)


print(response)
```




# Auto scaling groups

Why do we want to use auto scaling groups?

1) let's say for example if we have our app VM and CPU load is too high in some point it will crash and won't work properly.


2) we can use Cloudwatch and set up detailed monitoring and monitor specific metric like CPU load in the dashboard. Someone has to watch and monitor the dashboard though. You might missed some spike in CPU load.

3) Similiar to example 2 we can this time set up alarms that automatically will send us notifications, but you have to manually change settins and resources. 

4) The better solution would be autoscaling. We can use autoscaling to watch specific metrics and if i.g. CPU load sets specific points we can set scaling to increase or decrease resources.


## **How to set up system with auto scaling.**

in AWS there is someting called Auto Scaling Group. 
The benefit is:

- Scalability
- High Availibility (redundancy, more VMs but also in different data centers)


From VM we can create AMI (copy of the disk) -> Using AMIs we can go and create more using VMs, but we can also create something called 'Launch Template', where you can specify all the details you want your VM to have. Lauch template is needed for Auto Scaling Groups.

ASG needs to have templates to create VMs on demand when they are needed. ASG needs to know wat to create in case of necessery. That's why template is needed.

---

### **Scaling Policy**

ASG needs to know the threshold and what to monitor. That needs to be set in the 'scaling policy' i.g metric what we want to monitor CPU load 50%

if one VM uses 40% of CPU and second uses 60%, ASG set up for 50% will trigger to create another VM because the avarage is 50%.

ASG needs to have limit of VMs to create. Minimum is 2 just in case 1 crashes we have backup. We can set up 'desired' for like a needed number, and lastly we can set up maximum, so ASG knows that it cannot create more VMS than that number.

---

## **Architecture needed for ASG to work**

---

Traffic comes from internet to a load balancer.

Load Balancer - It balances the load between VMs to make sure it is distributed equally

We specify VMs to create in different availibility zones within 1 region. It helps with High Availibility. If there are only 3 zones in 1 region and we need to create 4 VMs, the 4th one will be created again with 1st zone.



**CODEALONG**:

---

1. db VM running

SEED DATABASE: (Clears and seeds database with data) inside app folder. IN CASE post page loads with no content

```bash
node seeds/seed.js
```
2. created a new app VM (used full app script with user data)

3. create AMI of new app VM
4. create Launch template from AMI of app VM. We can put all the details here (tag with a name) and add shorter version of script just running the app. Nginx, pm2, node etc. are already installed previously on the copied disk of AMI.
   
   ![create-lt](create-lt.png)

   * script for Launch template

```bash
#!/bin/bash

#Creating DB_HOST env variable
export DB_HOST=mongodb://172.31.38.156:27017/posts
#getting inside app folder
cd repo/app
# installing the app
npm install
# repopulate db
node seeds/seed.js
# starting the app
pm2 start app.js  
```


5. tested launch template if it works. Important step before using launch template with asg.
   
   ![create-lt](testing-lt.png)

6. create auto scaling group from launch template

 * On the first page we need to specify launch template we will be using to create new VMs

![create-lt](creating-asg.png)
![create-lt](create-asg-2.png)

* On the second screen we specify in which zones we want our VMs be created. In our example 3 zones within Ireland Region (student default 1a, 1b, 1c)

* Load balancer. In our case we need Internet-facing Load balancer on port 80 http. Load balancer will listen on that port and reroute the traffic to our ASG.

![create-lt](creating-lb.png)
![create-lt](creating-lb-healthy-check.png)

* Scaling policy (minimum, desired and maximum number of instances) and what to monitor.

![create-lt](scaling_policy.png)
![create-lt](asg-cpu-usage.png)

   

Target group - machines created in ASG



