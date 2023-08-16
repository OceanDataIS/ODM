import os
import paramiko

# Define the SSH connection parameters
hostname = 'linux_server_ip_address'
username = 'your_linux_username'
password = 'your_linux_password'

# Define the remote and local directories
# noaa 19
#remote_dir = 'source_path'
#local_dir = 'destinatio_path'
# Metop-1
#remote_dir = '/home/teradm/datagapfilling/MetopOneYear22'
remote_dir = 'source_path'
local_dir = 'destinatio_path'

# Create an SSH client and connect to the Linux server
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(hostname, username=username, password=password)

# Create an SFTP client and change to the remote directory
sftp = ssh.open_sftp()
sftp.chdir(remote_dir)

# Get a list of all .nc files in the remote directory
file_list = sftp.listdir()
nc_files = [f for f in file_list if f.endswith('.nc')]

# Download each .nc file to the local directory
for file_name in nc_files:
    rpath = os.path.join(remote_dir, file_name)
    remote_path = rpath.replace('\\','/')
    local_path = os.path.join(local_dir, file_name)
    sftp.get(remote_path, local_path)
    print("File {file_name} downloaded from the Linux server to {local_path} successfully!")

# Close the SFTP connection and the SSH session
sftp.close()
ssh.close()

