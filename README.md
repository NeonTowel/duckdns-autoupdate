# DuckDNS Autoupdate

This repository contains scripts to automatically update your DuckDNS domains with your current public IP address. Scripts are provided for both Windows and Linux.

## Prerequisites

You need to have a DuckDNS account and at least one domain. You can get your token from your DuckDNS account page.

## Windows

The Windows script is written in PowerShell.

### Usage

You can run the script from a PowerShell terminal.

```powershell
./windows/Update-DuckDNS.ps1 -domains your_domain -token your_token
```

You can also update multiple domains by separating them with a comma:

```powershell
./windows/Update-DuckDNS.ps1 -domains your_domain1,your_domain2 -token your_token
```

Alternatively, you can set the `DUCKDNS_DOMAINS` and `DUCKDNS_TOKEN` environment variables.

```powershell
$env:DUCKDNS_DOMAINS="your_domain"
$env:DUCKDNS_TOKEN="your_token"
./windows/Update-DuckDNS.ps1
```

You can also use the `install-task.ps1` script to automate the creation of the scheduled task.

```powershell
./windows/install-task.ps1 -domains "your_domain1,your_domain2" -token "your_token"
```

### Automation

You can use the Windows Task Scheduler to run the script periodically.

1.  Open Task Scheduler.
2.  Create a new basic task.
3.  Set the trigger to run at your desired frequency (e.g., daily).
4.  For the action, select "Start a program".
5.  Program/script: `powershell.exe`
6.  Add arguments (optional): `-File "C:\path\to\your\repo\windows\Update-DuckDNS.ps1"`
    - If you are using environment variables, you don't need to pass the arguments.

## Linux

The Linux script is a bash script.

### Usage

First, make the script executable:

```bash
chmod +x linux/update-duckdns.sh
```

You can run the script from your terminal. The first argument is the domain(s) and the second is the token.

```bash
./linux/update-duckdns.sh your_domain your_token
```

To update multiple domains, separate them with a comma:

```bash
./linux/update-duckdns.sh your_domain1,your_domain2 your_token
```

Alternatively, you can set the `DUCKDNS_DOMAINS` and `DUCKDNS_TOKEN` environment variables.

```bash
export DUCKDNS_DOMAINS="your_domain"
export DUCKDNS_TOKEN="your_token"
./linux/update-duckdns.sh
```

### Automation (systemd)

The recommended way to automate the script on Linux is to use the provided systemd service and timer. An installation script is provided to make this easy.

1.  Navigate to the `linux` directory.
2.  Run the installation script:
    ```bash
    sudo ./install.sh
    ```
3.  Edit the configuration file with your details:
    ```bash
    sudo nano /etc/default/duckdns-autoupdate
    ```
    Update the `DUCKDNS_DOMAINS` and `DUCKDNS_TOKEN` variables.
4.  The service is now running. You can check its status:
    ```bash
    systemctl status duckdns-autoupdate.timer
    ```

### Uninstallation

An uninstall script is also provided.

```bash
sudo ./uninstall.sh
```

### Automation (cron - DEPRECATED)

You can use `cron` to run the script periodically.

1.  Open your crontab for editing: `crontab -e`
2.  Add a new line to run the script at your desired frequency. For example, to run it every hour:

```cron
0 * * * * /path/to/your/repo/linux/update-duckdns.sh your_domain your_token
```

If you are using environment variables, you'll need to make sure they are available to your cron job, or define them in the crontab file.

```cron
DUCKDNS_DOMAINS="your_domain"
DUCKDNS_TOKEN="your_token"
0 * * * * /path/to/your/repo/linux/update-duckdns.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
