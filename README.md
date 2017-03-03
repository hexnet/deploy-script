# lizmo-slacks
A Script for Web Application Deployments

I created this script initially for my laravel project deployments to provide updates in a way with minimised downtime. The projects do not need persistent storage but this feature can be worked into the script by creating a symlink to $FOLDER/storage.  
To use this on a laravel project, create a directory as /etc/env/$NAMESPACE/$PROJECT and copy in the .env (phpdotenv) file for it to set laravel up correctly.  

### My Development Workflow
I code on a workstation and commit to a GitLab server located within our LAN. On the GitLab project, I tag commits which are ready for production.  
This script clones the project into a datestamped directory and checks out to the specified tag then creates a symlink from this folder to the directory the webserver expects the project to be at.
