echo $(pwd)
echo "Building"
aur graph */.SRCINFO | tsort | tac > queue
aur build -a queue -s
rm queue
