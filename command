This Document for CI/CD pipeline

Step 1

Pull the images for NEXUS

Podman pull sonatype/nexus3:latest

Step 2

To create tar for the file 

Podman save -o nexus.tar sonatype/nexus3:latest

Step 3

Send tar to server 

Scp  nexus.tar developer@10.x.x.x

Step 4

To load tar file

Podman load -i nexus.tar

Step 5

Check the images

Podman images

Step 6

To create a container 

podman run -itd --name nexus1 -p 8082:8081 -v /docker_volumes/nexus/data:/nexus-data sonatype/nexus3:latest

Step 7

Check the container is running 

Podman ps




Step 8
  
For jenkins image i take images from etransport because the have all modules in there images

Save the images to tar file

Podman save -o jenkins1.tar localhost/jenkins_vahan:letest

Step 9

To send the images to server 

Scp jenkins1.tar developer@10.x.x.x

Step 10 

To create a container for jenkins

Podman  run -itd --name jenkins1 -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock  -v /var/lib/docker:/var/lib/docker -v /docker_volumes/Jenkins_prod:/var/jenkins_home -v /usr/bin/docker:/usr/bin/docker -e "TZ=Asia/Kolkata" localhost/jenkins_vahan


Step 11

To check the container is running 

Podman ps


Step 12 

Access the nexus in browser

For the you need to do port forwarding

ssh -L 8082:10.x.x.x:8082 root@10.x.x.x













Step 13

Go to browser search menu and type 

Localhost:8082

It visible like this 




Step 14 

Go to the sing in and sign up with 
Username admin
Password admin

















Step 15 

For creating repository 

Go to the setting and then repository 

Then click on create new repository 




Step 16 

Select raw(hosted)



Step 17

Write the name and other details for the repository



Step 18

Then click on create repository and repository is created



Step 19 

You have to create roles 

Go to the roles in the options




Step 20
 Create  a roles

Click on create roles and then select type nexus roles and add details 



Step 21

Add privileges

These 2 privileges has to added 

nx-repository-admin-raw-test1-*
nx-repository-view-raw-test1-*






Step 22 

Then click on save and your role has been created




Step 23 

Now you have to create  user

Select users in the option

Then click create local user

And add details



Password should be the same as username
 In this case password should be test1

Step 24 

Then grand roles to the user then click on create local user



Step 25

To create pipeline in jenkins

Port is not opened you have to do port forwarding

ssh -L 8080:10.x.x.x:8080 root@10.x.x.x

Jenkins will open like this



Step 26

To create pipeline click on new items in option

Then write pipeline name and select pipeline option

Add this pipeline script in pipeline option

pipeline {
    agent any

   stages {
        stage('Deployment of test1 WAR') {
            steps {
               
                sh '''  ansible-playbook  /var/jenkins_home/jenkins/ansible/test1.yml -i /var/jenkins_home/jenkins/ansible/inventory --private-key=/var/jenkins_home/jenkins/ansible/keys/ansibleadm   --user jenkins'''
               
               
                           }
        }
    }
}

Then click on save 

Step 27 

Write a ansible playbook 

Location- /docker_volumes/Jenkins_prod/jenkins/ansible


Create  test1.yml at this location

vim test1.yml

---
 - name: role
   hosts: test1
   roles:
     - test1
~            

Location- /docker_volumes/Jenkins_prod/jenkins/ansible/roles

Create a directory with same name test1

Mkdir test 1
And inside test1 create default and task directories

Location - docker_volumes/Jenkins_prod/jenkins/ansible/roles/test1/defaults

Vim main.yml

---
tomcats:
 - name: 'test1'
   tomcat_name: 'test1'
   war_name: 'test1'
   server_name: 'nq73p-nclt1-002'
   backend_name: 'test1'
   repository_url: "http://10.247.200.134:8085/repository/test1/test1/"
   repository_username: 'test1'
   repository_password: 'test1'


Location- /docker_volumes/Jenkins_prod/jenkins/ansible/roles/test1/tasks





Vim main.yml

---
#tasks:
- name: Create a directory if it does not exist
  file:
    path: /home/developer/test1
    state: directory
    owner: developer
    group: developer
    mode: '0755'

- name: Download Latest WAR
  get_url:
     url_username: "{{ item.repository_username }}"
     url_password: "{{ item.repository_password }}"
     #url:  "{{ item.repository_url }}{{ date }}/{{ item.war_name }}.war"
     url: "{{ item.repository_url }}{{ item.war_name }}.war"
     owner: developer
     group: developer
     dest: "/home/developer/test1/"
  with_items:
    - "{{ tomcats }}"
  register: download_status

- name: Create a directory if it does not exist
  file:
    path: "/opt/test1{{ansible_date_time.date}}"
    state: directory
    owner: developer
    group: developer
    mode: '0755'

- name: execute the command
  become: true
  become_user: developer
  shell: podman  cp test1:/usr/local/tomcat/webapps/test1 /opt/test1{{ansible_date_time.date}}

- name: execute the command
  become: true
  become_user: developer
  shell: podman stop test1

- name: execute the command
  become: true
  become_user: develoepr
  shell: podman rm test1


- name: build the image
  become: true
  become_user: developer
  command: sh /home/developer/build.sh

- name: create container
  become: true
  become_user: developer
  command: sh /home/developer/test1.sh



Run the pipeline















cat build.sh
#!/bin/bash

#f [ $# -eq 0 ]; then
 #  echo "No arguments provided. Pls provide Pod Tag version to start"
  # exit 1
#fi
PODVERSION=`date +%d%h%Y`


MYNAME=${PWD##*/}
MYLOWERNAME=`echo $MYNAME | tr '[:upper:]' '[:lower:]'`
docker build -f Dockerfile -t nclatonline/$MYLOWERNAME-tomcat-9.0.65:$PODVERSION .



cat NCLTOnline1.sh
docker run -itd --name NCLTOnline1 -p 8088:8080 -v /Efile_Document:/Efile_Document -e "TZ=Asia/kolkata" --add-host=bharatkosh.gov.in:164.100.78.112 --add-host=sbox.nesl.co.in:182.18.150.111 --add-host=efiling.nclt.gov.in:164.100.59.89 --add-host=pg.meeseva.telangana.gov.in:103.122.128.44 --add-host=tsstaging.meeseva.telangana.gov.in:103.122.128.114 ncltonline1/developer-tomcat-9.0.65:`date +%d%h%Y`

cat Dockerfile
FROM docker.io/library/tomcat:9.0.65-jdk11-openjdk
COPY ncltonline1.war /usr/local/tomcat/webapps

