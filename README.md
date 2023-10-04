# AWS EC2 Setup & Connection to GitHub Private Repository

Follow these steps to set up an AWS EC2 instance and connect it to a private GitHub repository:

1. **Launch an EC2 Instance on AWS:**
    1. Navigate to EC2 on AWS.
    2. In the left menu bar, click on `Instances`, then click on `Launch Instances`.
    3. Assign a name for your EC2. For the OS, select `Ubuntu`.
    4. Choose the `t2.micro` instance type.
    5. Under the keypair section:
        1. Create a new key.
        2. Assign a name and select `RSA` as your key pair type.
        3. Choose `.pem` as the key file format.
        
    **Note:** Ensure you safely store the key, as it is essential for remote connection to your EC2.

    6. Click on `Launch Instance`. (Instance creation may take a few minutes.)
    7. Return to `Instances`.
    8. Locate and click on your instance ID.
    9. Click on the `Connect` button.
        - To connect via the AWS website: Use the `EC2 Instance Connect` tab and click on `Connect`.
        - To connect from a local device: 
            1. Click on the `SSH client` tab.
            2. Open a terminal on your local device.
            3. Navigate to the location where you downloaded the .pem key (e.g., `cd Downloads`).
            4. Run `chmod 400 your-key-name.pem`.
            5. Use the SSH command displayed in the `SSH client` tab to establish a remote connection.

2. **Setting up SSH Key for GitHub on EC2:**
    1. After connecting to your EC2 instance, run: 
        ```bash
        ssh-keygen -t rsa
        ```
        Press enter to create an SSH key, which will allow EC2 to connect to a private repo on GitHub.
    2. Display the public key with:
        ```bash
        more /home/ubuntu/.ssh/id_rsa.pub
        ```
    3. Copy the displayed key.
    4. Navigate to your GitHub page, open your profile, and click on `Settings`.
    5. Click on `SSH and GPG keys`, then `New SSH key`.
    6. Assign a name, paste your key, and click `Add SSH key`.

3. **Package Installation & EC2 Configuration:**
    1. Install necessary packages with the following commands:
        ```bash
        sudo apt update && sudo apt upgrade -y
        sudo apt install p7zip-full gfortran make awscli
        ```
    2. On your EC2 instance, navigate to the `/home/ubuntu` directory:
        ```bash
        aws s3 cp s3://mukahead-ec2-rpi/mukahead-EC2/ . --recursive
        ```
    3. Create required directories:
        ```bash
        mkdir -p data/mukahead
        cd data/mukahead
        mkdir archive raw results summaries
        ```
    4. Configure AWS with:
        ```bash
        aws configure
        ```
        Set your access key, secret key, and region (e.g., `us-west-2`).
    5. Navigate to the `raw` folder and copy a ghg file from s3:
        ```bash
        cd raw
        aws s3 cp s3://ec-mukahead-ghg/2016-04-10T113000_AIU-1552.ghg .
        ```
    6. Provide execution permissions to the script and run it:
        ```bash
        cd /home/ubuntu
        chmod +x eddypro_run.sh
        ./eddypro_run.sh
        ```

**Note:** Adjust commands where necessary, such as replacing placeholder file names with actual names.
