#!/bin/ash
    #tuning
        DOCKER_PHP_CONFIG="/usr/local/etc/php-fpm.d/www.conf"
        DOCKER_PHP_OPCACHE="/usr/local/etc/php/conf.d/opcache-recommended.ini"

        DOCKER_PHP_OPCACHE_MAX_MEMORY=$(awk '/MemFree/ { printf "%.0f \n", $2/1024*0.25 }' /proc/meminfo) # 25% memory for OPCACHE
        DOCKER_PHP_MAX_CHILDREN=$(awk '/MemFree/ { printf "%.0f \n", $2/1024*0.75/64 }' /proc/meminfo) # 75% memory for PHP Processes
        DOCKER_PHP_MAX_SERVERS="$(nproc --all 7 | awk '{ SUM += $1*4} END { print SUM }')"
        DOCKER_PHP_MIN_SERVERS="$(nproc --all 7 | awk '{ SUM += $1*2} END { print SUM }')"
        DOCKER_PHP_MAX_REQUESTS="10000"
        DOCKER_PHP_TIMEOUT="10s"

        sed -i "/pm =/{h;s/=.*/= dynamic/g};\${x;/^$/{s//[;]pm = dynamic/;H};x};s/^[;]pm = /pm = /g" $DOCKER_PHP_CONFIG
        sed -i "/pm.max_children =/{h;s/=.*/= ${DOCKER_PHP_MAX_CHILDREN}/g};\${x;/^$/{s//pm.max_children = ${DOCKER_PHP_MAX_CHILDREN}/g;H};x}s/^[;]pm.max_children = /pm.max_children = /g" $DOCKER_PHP_CONFIG
        sed -i "/pm.start_servers =/{h;s/=.*/= ${DOCKER_PHP_MAX_SERVERS}/g};\${x;/^$/{s//pm.start_servers = ${DOCKER_PHP_MAX_SERVERS}/g;H};x}s/^[;]pm.start_servers = /pm.start_servers = /g" $DOCKER_PHP_CONFIG
        sed -i "/pm.min_spare_servers =/{h;s/=.*/= ${DOCKER_PHP_MIN_SERVERS}/g};\${x;/^$/{s//pm.min_spare_servers = ${DOCKER_PHP_MIN_SERVERS}/g;H};x}s/^[;]pm.min_spare_servers = /pm.min_spare_servers = /g" $DOCKER_PHP_CONFIG
        sed -i "/pm.max_spare_servers =/{h;s/=.*/= ${DOCKER_PHP_MAX_SERVERS}/g};\${x;/^$/{s//pm.max_spare_servers = ${DOCKER_PHP_MAX_SERVERS}/g;H};x}s/^[;]pm.max_spare_servers = /pm.max_spare_servers = /g" $DOCKER_PHP_CONFIG
        sed -i "/pm.max_requests =/{h;s/=.*/= ${DOCKER_PHP_MAX_REQUESTS}/g};\${x;/^$/{s//pm.max_requests = ${DOCKER_PHP_MAX_REQUESTS}/g;H};x}s/^[;]pm.max_requests = /pm.max_requests = /g" $DOCKER_PHP_CONFIG
        sed -i "/pm.process_idle_timeout =/{h;s/pm.process_idle_timeout= .*/= ${DOCKER_PHP_TIMEOUT}/g};\${x;/^$/{s//pm.process_idle_timeout = ${DOCKER_PHP_TIMEOUT}/g;H};x}s/^[;]pm.process_idle_timeout = /pm.process_idle_timeout = /g" $DOCKER_PHP_CONFIG

        sed -i "/^opcache.enable=/{h;s/=.*/=1/g};\${x;/^$/{s//opcache.enable=1/g;H};x}" $DOCKER_PHP_OPCACHE
        sed -i "/^opcache.interned_strings_buffer=/{h;s/=.*/=8/g};\${x;/^$/{s//opcache.interned_strings_buffer=8/g;H};x}" $DOCKER_PHP_OPCACHE
        sed -i "/^opcache.max_accelerated_files=/{h;s/=.*/=10000/g};\${x;/^$/{s//opcache.max_accelerated_files=10000/g;H};x}" $DOCKER_PHP_OPCACHE
        sed -i "/^opcache.revalidate_freq=/{h;s/=.*/=1/g};\${x;/^$/{s//[;]*opcache.revalidate_freq=1/g;H};x}" $DOCKER_PHP_OPCACHE
        sed -i "/^opcache.validate_timestamps=/{h;s/=.*/=0/g};\${x;/^$/{s//opcache.validate_timestamps=0/g;H};x}" $DOCKER_PHP_OPCACHE
        sed -i "/^opcache.max_wasted_percentage=/{h;s/=.*/=20/g};\${x;/^$/{s//opcache.max_wasted_percentage=20/g;H};x}" $DOCKER_PHP_OPCACHE
        sed -i "/^opcache.memory_consumption=/{h;s/=.*/=${DOCKER_PHP_OPCACHE_MAX_MEMORY}/g};\${x;/^$/{s//opcache.memory_consumption=${DOCKER_PHP_OPCACHE_MAX_MEMORY}/g;H};x}" $DOCKER_PHP_OPCACHE

    #run
        exec "$@"