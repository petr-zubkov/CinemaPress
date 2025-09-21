#!/bin/bash

# =============================================================================
# CinemaPress One-Command Installation Script
# Based on original CinemaPress installer from https://github.com/petr-zubkov/CinemaPress
# =============================================================================

# Color definitions for output
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
C='\033[0;36m'
B='\033[0;34m'
S='\033[0;37m'
NC='\033[0m'

# Script information
SCRIPT_NAME="CinemaPress One-Command Installer"
SCRIPT_VERSION="1.0.0"
ORIGINAL_URL="https://git.io/JGKNq"

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if running as root
check_root() {
    if [ ${EUID} -ne 0 ]; then
        print_status "${R}" "ERROR: This script must be run as root!"
        print_status "${Y}" "Please run: sudo $0"
        exit 1
    fi
}

# Function to check internet connection
check_internet() {
    print_status "${C}" "Checking internet connection..."
    if ! curl -s --head https://github.com > /dev/null; then
        print_status "${R}" "ERROR: No internet connection detected!"
        exit 1
    fi
    print_status "${G}" "✓ Internet connection OK"
}

# Function to install required packages
install_requirements() {
    print_status "${C}" "Installing required packages..."
    
    # Update package lists
    apt-get update -qq
    
    # Install required packages
    local packages=("wget" "curl" "sudo" "ca-certificates")
    for package in "${packages[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            print_status "${Y}" "Installing $package..."
            apt-get install -y "$package" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                print_status "${G}" "✓ $package installed successfully"
            else
                print_status "${R}" "✗ Failed to install $package"
                exit 1
            fi
        else
            print_status "${G}" "✓ $package already installed"
        fi
    done
}

# Function to download and execute original CinemaPress script
install_cinemapress() {
    print_status "${C}" "Downloading CinemaPress installation script..."
    
    # Create temporary file for the script
    local temp_script="/tmp/cinemapress-install-$(date +%s).sh"
    
    # Download the original script
    if wget -qO "$temp_script" "$ORIGINAL_URL"; then
        print_status "${G}" "✓ CinemaPress script downloaded successfully"
        
        # Make the script executable
        chmod +x "$temp_script"
        
        # Execute the original script
        print_status "${C}" "Starting CinemaPress installation..."
        print_status "${Y}" "This may take several minutes..."
        
        # Pass through any environment variables that might be set
        export CP_DOMAIN="${CP_DOMAIN:-}"
        export CP_LANG="${CP_LANG:-}"
        export CP_THEME="${CP_THEME:-}"
        export CP_PASSWD="${CP_PASSWD:-}"
        export CP_MIRROR="${CP_MIRROR:-}"
        export CP_KEY="${CP_KEY:-}"
        
        # Execute the script
        bash "$temp_script"
        
        # Check exit status
        local exit_code=$?
        if [ $exit_code -eq 0 ]; then
            print_status "${G}" "✓ CinemaPress installation completed successfully!"
        else
            print_status "${R}" "✗ CinemaPress installation failed with exit code: $exit_code"
            exit $exit_code
        fi
        
        # Clean up
        rm -f "$temp_script"
        
    else
        print_status "${R}" "✗ Failed to download CinemaPress script"
        print_status "${Y}" "Please check your internet connection and try again"
        exit 1
    fi
}

# Function to display system information
show_system_info() {
    print_status "${B}" "System Information:"
    print_status "${S}" "  OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    print_status "${S}" "  Kernel: $(uname -r)"
    print_status "${S}" "  Architecture: $(uname -m)"
    print_status "${S}" "  User: $(whoami)"
    print_status "${S}" "  Memory: $(free -h | grep Mem | awk '{print $2}')"
    print_status "${S}" "  Disk Space: $(df -h / | tail -1 | awk '{print $4}') available"
}

# Main execution function
main() {
    # Display header
    echo "=================================================================="
    print_status "${B}" "$SCRIPT_NAME v$SCRIPT_VERSION"
    print_status "${C}" "Based on CinemaPress by petr-zubkov"
    echo "=================================================================="
    echo ""
    
    # Show system information
    show_system_info
    echo ""
    
    # Pre-flight checks
    print_status "${C}" "Performing pre-flight checks..."
    check_root
    check_internet
    install_requirements
    
    echo ""
    print_status "${G}" "All checks passed! Starting installation..."
    echo ""
    
    # Install CinemaPress
    install_cinemapress
    
    echo ""
    echo "=================================================================="
    print_status "${G}" "Installation process completed!"
    print_status "${Y}" "Thank you for using CinemaPress!"
    echo "=================================================================="
}

# Execute main function
main "$@"