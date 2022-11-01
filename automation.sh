sudo apt update -y
myname="Binisha"
timestamp=`date +%d%m%Y-%H%M%S`
inventoryFile="/var/www/html/inventory.html"
s3_bucket="upgrad_binisha"
cronJob="/etc/cron.d/automation"
a=$(dpkg-query -l | grep apache2 | wc -l)
echo $a
echo "********************************************************************"
if [ $a -eq 0 ]; then
	echo "Apache2 not installed.Installing the file"
         sudo apt install apache2
 else
	 echo "Apache2 already installed"
	 status=$(service apache2 status | grep Stopped | wc -l)
#echo $status
echo "**************************************************************************"
if [ $status -eq 1 ]; then
echo "Service is disabled! Enabling the service"
sudo service apache2 restart
else
echo "Service is Running"
fi
fi
echo "*******************************************************************"
echo "Creating the log files tar and moving to /tmp"
fileName=$myname-httpd-logs-$timestamp.tar
echo $fileName
#mkdir /tmp/$fileName
echo "Creating tar files from logs"
sudo tar cvf /tmp/$fileName /var/log/apache2/*.log

echo "***************************************************************"
echo "Copying tar to s3"
aws s3 \
cp /tmp/${fileName} \
s3://${s3_bucket}/${fileName}
echo "****************************************************************"


