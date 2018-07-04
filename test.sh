encodecrop="ssfdsdfsdf"
autocrop=""
echo "p6:${encodecrop}"
if [ "$encodecrop" != "" ]; then
        autocrop="${encodecrop},"
fi
echo $autocrop
