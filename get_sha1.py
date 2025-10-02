#!/usr/bin/env python3
"""
Google Maps API - Android SHA-1 Fingerprint Extractor
Extracts SHA-1 certificate fingerprints for Android app restrictions
"""

import subprocess
import os
import sys
from pathlib import Path

# Colors for terminal output
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'

def print_header(text):
    print(f"\n{Colors.BOLD}{Colors.HEADER}{'='*50}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.HEADER}{text}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.HEADER}{'='*50}{Colors.END}\n")

def print_success(text):
    print(f"{Colors.GREEN}✓ {text}{Colors.END}")

def print_error(text):
    print(f"{Colors.RED}✗ {text}{Colors.END}")

def print_info(text):
    print(f"{Colors.BLUE}ℹ {text}{Colors.END}")

def print_warning(text):
    print(f"{Colors.YELLOW}⚠ {text}{Colors.END}")

def get_debug_sha1():
    """Get SHA-1 from debug keystore"""
    debug_keystore = Path.home() / '.android' / 'debug.keystore'
    
    if not debug_keystore.exists():
        print_warning(f"Debug keystore not found at: {debug_keystore}")
        print_info("Run your Flutter app once to generate it: flutter run")
        return None
    
    print_success(f"Debug keystore found: {debug_keystore}")
    
    try:
        cmd = [
            'keytool', '-list', '-v',
            '-alias', 'androiddebugkey',
            '-keystore', str(debug_keystore),
            '-storepass', 'android',
            '-keypass', 'android'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        
        # Parse SHA-1 from output
        for line in result.stdout.split('\n'):
            if 'SHA1:' in line or 'SHA-1:' in line:
                sha1 = line.split(':', 1)[1].strip()
                return sha1
        
        print_error("Could not find SHA-1 in keytool output")
        return None
        
    except subprocess.TimeoutExpired:
        print_error("Keytool command timed out")
        return None
    except FileNotFoundError:
        print_error("keytool not found. Make sure Java/JDK is installed")
        return None
    except Exception as e:
        print_error(f"Error running keytool: {e}")
        return None

def find_release_keystores():
    """Find potential release keystores"""
    search_paths = [
        'android/app/keystore.jks',
        'android/app/upload-keystore.jks',
        'android/app/release-keystore.jks',
        'android/keystore.jks',
        'keystore.jks',
        'upload-keystore.jks',
    ]
    
    found = []
    for path in search_paths:
        if Path(path).exists():
            found.append(path)
    
    return found

def get_package_name():
    """Extract package name from build.gradle.kts"""
    gradle_file = Path('app/android/app/build.gradle.kts')
    
    if not gradle_file.exists():
        return None
    
    try:
        with open(gradle_file, 'r') as f:
            for line in f:
                if 'applicationId' in line and '=' in line:
                    # Extract package name from: applicationId = "com.example.app"
                    package = line.split('=')[1].strip().strip('"').strip("'")
                    return package
    except Exception as e:
        print_error(f"Error reading gradle file: {e}")
    
    return None

def main():
    print_header("Google Maps API - SHA-1 Fingerprint Tool")
    
    # Get package name
    package_name = get_package_name()
    if package_name:
        print_success(f"Package Name: {Colors.BOLD}{package_name}{Colors.END}")
    else:
        print_warning("Could not determine package name")
        package_name = "com.example.app"
        print_info(f"Using default: {package_name}")
    
    print()
    
    # Get debug SHA-1
    print_info("Checking for debug keystore...")
    debug_sha1 = get_debug_sha1()
    
    if debug_sha1:
        print()
        print_success(f"Debug SHA-1: {Colors.BOLD}{debug_sha1}{Colors.END}")
        
        print("\n" + "="*50)
        print(f"{Colors.BOLD}📋 Copy this for Google Cloud Console:{Colors.END}")
        print("="*50)
        print(f"{Colors.GREEN}Package name:{Colors.END} {package_name}")
        print(f"{Colors.GREEN}SHA-1 fingerprint:{Colors.END} {debug_sha1}")
        print("="*50)
    
    # Check for release keystores
    print("\n" + "-"*50)
    print_info("Checking for release keystores...")
    release_keystores = find_release_keystores()
    
    if release_keystores:
        print_success(f"Found {len(release_keystores)} release keystore(s):")
        for keystore in release_keystores:
            print(f"  • {keystore}")
        print("\nTo get SHA-1 from release keystore, run:")
        print(f"{Colors.YELLOW}keytool -list -v -keystore <keystore-path>{Colors.END}")
    else:
        print_warning("No release keystores found in common locations")
    
    # Next steps
    print("\n" + "="*50)
    print(f"{Colors.BOLD}📝 Next Steps:{Colors.END}")
    print("="*50)
    print("1. Go to: https://console.cloud.google.com/apis/credentials")
    print("2. Select your API key")
    print("3. Under 'Application restrictions', choose 'Android apps'")
    print("4. Click 'Add an item'")
    print(f"5. Enter package name: {Colors.GREEN}{package_name}{Colors.END}")
    if debug_sha1:
        print(f"6. Enter SHA-1: {Colors.GREEN}{debug_sha1}{Colors.END}")
    print("7. Click 'Done' and 'Save'")
    print("="*50 + "\n")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nOperation cancelled by user")
        sys.exit(0)
    except Exception as e:
        print_error(f"Unexpected error: {e}")
        sys.exit(1)
