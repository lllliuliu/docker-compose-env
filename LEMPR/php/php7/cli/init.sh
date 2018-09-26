#!/bin/sh
DATA="/data"
USER="www-data"

# Wait for repo to mount the volume
while [ ! -f $DATA/fin.lock ]; do
    echo "Wait for repo to initialize and try again 1 seconds later..."
    sleep 1
done

# CLI Command
# Example：task queue of laravel
# cd $DATA
# su-exec $USER php artisan queue:work redis --queue=uc:sms:listener --env=$APP_ENV >/logs/sms.log 2>&1 &
# su-exec $USER php artisan queue:work redis --queue=uc:email:listener --env=$APP_ENV >/logs/email.log 2>&1
