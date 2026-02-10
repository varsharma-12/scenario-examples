# 1. Clear the screen to look professional
clear

# 2. Show a loading message
echo " Initializing Java 26 GC Performance Environment..."
echo "Please wait while we prepare your files and Kubernetes cluster."

# 3. Wait for the 'finished_setup' signal from background.sh
while [ ! -f /tmp/finished_setup ]; do
  echo -n "."
  sleep 2
done

# 4. Success message and move to the directory
echo -e "\n\n Environment Ready!"
cd /root/demo/kafka-streams-demo/
ls -la
