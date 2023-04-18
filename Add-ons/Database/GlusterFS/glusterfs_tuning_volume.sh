VOLUME=""

if	[ -n $VOLUME ] ; then

	gluster volume set $VOLUME group distributed-virt
	gluster volume set $VOLUME group metadata-cache
	gluster volume set $VOLUME group nl-cache

	gluster volume set $VOLUME cluster.data-self-heal-algorithm full
	gluster volume set $VOLUME cluster.favorite-child-policy majority
	gluster volume set $VOLUME cluster.heal-timeout 60
	gluster volume set $VOLUME cluster.locking-scheme granular
	gluster volume set $VOLUME cluster.quorum-type auto
	gluster volume set $VOLUME cluster.use-anonymous-inode yes

	gluster volume set $VOLUME features.shard off
	gluster volume set $VOLUME network.ping-timeout 20

	gluster volume set $VOLUME

	gluster volume set $VOLUME server.keepalive-count 2
	gluster volume set $VOLUME server.keepalive-interval 5
	gluster volume set $VOLUME server.keepalive-time 10
	gluster volume set $VOLUME server.tcp-user-timeout 20

	gluster volume set $VOLUME storage.build-pgfid on
	gluster volume set $VOLUME storage.health-check-interval 60

	gluster volume set $VOLUME user.cifs off
	gluster volume set $VOLUME user.nfs off
fi
