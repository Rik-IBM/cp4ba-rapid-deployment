cat > cp-must-gather-default.sh << 'EOT'
#!/bin/bash
export MUST_GATHER_IMAGE=quay.io/opencloudio/must-gather:latest
export CLOUDPAK_NAMESPACES=common-service,ibm-common-services,ibm-cp4ba
export MUST_GATHER_MODULES=overview,system,failure,cloudpak,etcd,route
oc adm must-gather --image=$MUST_GATHER_IMAGE -- gather -m $MUST_GATHER_MODULES -n $CLOUDPAK_NAMESPACES
EOT


Procedure do fix Kafka (testing)

we can have a try at deleting that lock file off the filesystem. 
To do that, we will need to shell into the node to access the filesystem as the pod is not running. 

The first thing to do is work out which node the Kafka-0 pod is running on using oc describe. 
Then, get a list of PVCs using oc get pvc and find the volume reference for the Kafka-0 pvc (it will be the value under the VOLUME column). 
Then log into the node that is running Kafka-0 (oc debug node/<nodename>) 
and run the chroot /host command when the shell prompt is available. 
Then run lsblk to get a list of block devices and hopefully you should see a device with a name like rbdx  
which has a reference to the PVC as the mountpoint. 
If you then copy that mountpoint and inspect that directory, you should find a subdirectory named kafka-log0. 
The lock file will be inside that directory as a hidden file (.lock). Delete that file and try and startup the pod again.

4016725
4017263
