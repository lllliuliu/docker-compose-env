#!/bin/sh
DATA="/data"
USER="www-data"
GROUP="www-data"

# Check whether the give host and port are started
wait_for() {
    while true; do
        nc -z "$1" "$2" > /dev/null 2>&1
        result=$?
        if [ $result -eq 0 ] ; then
            return 0
        fi
        echo "Wait for $1:$2 to started..."
        sleep 1
    done
}

cd $DATA

# According to different APP_ENV environments
case $APP_ENV in
    "test")
        if [ ! -d $DATA/.git ]; then
            if [ -d $DATA ]; then
                rm -rf $DATA/*
            fi

            # Pull repository and update floder permissions
            git clone $REPO_URL $DATA
        else
            chown -R $USER:$GROUP $DATA
            # Pull repository
            su-exec $USER git pull
        fi

        # Update .env.test file
        sed -i -E 's/DB_HOST=.+$/DB_HOST=mariadb/g' .env.test
        sed -i -E "s/DB_DATABASE=.+$/DB_DATABASE=${MYSQL_DATABASE}/g" .env.test
        sed -i -E "s/DB_USERNAME=.+$/DB_USERNAME=${MYSQL_USER}/g" .env.test
        sed -i -E "s/DB_PASSWORD=.+$/DB_PASSWORD=${MYSQL_PASSWORD}/g" .env.test

        sed -i -E 's/REDIS_HOST=.+$/REDIS_HOST=redis/g' .env.test
        ;;
    "dev")
        # Check that the REPO_ROOT folder is ready 
        while [ ! -d $DATA/.git ]; do
            echo " Wait for the REPO_ROOT folder is ready ..."
            sleep 5
        done
        ;;
    *)
        echo "APP_ENV error"
        exit 1
        ;;
esac

# Initialize work before other containers start
# Example：Update floder permissions
# chown -R $USER:$GROUP $DATA
# chmod -R 775 storage bootstrap/cache

# Check whether mariadb are started
wait_for mariadb 3306
wait_for redis 6379

# Initialize work after other containers start
# Example：migrate of laravel
# su-exec $USER php artisan migrate --env=$APP_ENV

# Generate finish file
# Note：It is recommended to place file in a non-git repository directory
touch fin.lock

