#!/bin/bash
#
# Deploys a web application from an git repository by tag version
#

#### Variables
SLACK_URL=''
SLACK_CHANNEL='#deployments'
GIT_FQDN=''
WEB_DIR='/var/www' # No trailing forward slash

#### Do not edit below this line
FOLDER=$(date +"%Y%m%d%H%M%S")
NAMESPACE=$1
PROJECT=$2
TAG=$3

function postSlack () {
  SLACK_MESSAGE="$1"
  case "$2" in
    INFO)
      SLACK_ICON=':slack:'
      ;;
    WARNING)
      SLACK_ICON=':warning:'
      ;;
    ERROR)
      SLACK_ICON=':bangbang:'
      ;;
    *)
      SLACK_ICON=':slack:'
      ;;
  esac
  curl -X POST --data-urlencode "payload={\"channel\": \"$SLACK_CHANNEL\", \"username\": \"$(hostname)\", \"text\": \"$SLACK_MESSAGE\", \"icon_emoji\": \"$SLACK_ICON\"}" $SLACK_URL
}

if [ $# -lt 1 ]; then
  echo Usage: deploy.sh namespace project tag
  exit
fi

cd "$WEB_DIR" || { postSlack "$NAMESPACE/$PROJECT $TAG could not change to web directory." "ERROR"; exit 1; }
git clone git@"$GIT_FQDN":"$NAMESPACE"/"$PROJECT".git "$FOLDER" || { postSlack "$NAMESPACE/$PROJECT $TAG could clone from $GIT_FQDN." "ERROR"; exit 1; }
cd "$FOLDER" || exit 1;
git checkout "$TAG" || { postSlack "$NAMESPACE/$PROJECT $TAG tag not found." "ERROR"; exit 1;}
if [ -d "/etc/env/$NAMESPACE/$PROJECT" ]; then
  cp /etc/env/"$NAMESPACE"/"$PROJECT"/.env /var/www/"$FOLDER"/.env
  composer install --no-interaction
  chmod 777 -R "$WEB_DIR"/"$FOLDER"/storage
  php artisan optimize
  php artisan key:generate # Comment this if we symlink to $FOLDER/storage
fi
rm -rf "${WEB_DIR:?}"/"$PROJECT"
ln -sf "$WEB_DIR"/"$FOLDER" "$WEB_DIR"/"$PROJECT"
postSlack "$NAMESPACE/$PROJECT $TAG deployed successfully." "INFO"
exit 0
