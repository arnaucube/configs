# create swap file
dd if=/dev/zero of=./swapfile bs=1GB count=40

# add permisions
chmod 600 ./swapfile

# format the swapfile
mkswap ./swapfile

# enable swap on swapfile
swapon ./swapfile

# check that it is enabled
swapon --show
