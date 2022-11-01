sudo apt update -y
myname="Binisha"
timestamp=`date +%d%m%Y-%H%M%S`
inventoryFile="/var/www/html/inventory.html"
s3_bucket="upgrad-binisha"
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

size=`du -sh /tmp/$fileName | cut -f1`
#echo $size
echo "********************************************************************"
echo "Update the inventory list"
if [ -f "$inventoryFile" ]; then
	echo "$inventoryFile exists."
else
   echo "Creating the file"
   sudo touch $inventoryFile
   sudo echo "Logtype		Time Created	Type	Size" >> $inventoryFile
fi
sudo echo "httpd-logs	$timestamp	tar	$size">> $inventoryFile
cat $inventoryFile

echo "********************************************************************"
echo "Create Cron Job, to schedule this Script once in a day"
#if the cron Job doesnt exists create a cron file
if [ -f "$cronJob" ]; then
	echo "$cronJob exists"
else
	echo "Creating Cron Job File"
	sudo touch $cronJob
sudo echo "0 5 * * * root /root/AutomationProject/automation.sh >>/tmp/out.txt" >> $cronJob
fi
echo "*************************************************************"
