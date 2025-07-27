#!/bin/bash

# Script to create AD_Automation_Scripts directory structure
# Author: Generated for AD GPO deployment project
# Date: $(date +%Y-%m-%d)

set -e  # Exit on any error

echo "Creating AD_Automation_Scripts directory structure..."

# Create main directory
#mkdir -p AD_Automation_Scripts

# Navigate to main directory
#cd AD_Automation_Scripts

# Create root files
touch README.md
touch CHANGELOG.md

# Create setup directory and files
mkdir -p setup
touch setup/initialise_domain_controller.ps1

# Create scripts directory structure
mkdir -p scripts

# Create validation directory and files
mkdir -p scripts/validation
touch scripts/validation/validate_ou_structure.ps1
touch scripts/validation/validate_gpo_links.ps1

# Create ou_creation directory and files
mkdir -p scripts/ou_creation
touch scripts/ou_creation/create_organisational_units.ps1

# Create gpo directory structure and files
mkdir -p scripts/gpo/{Sysadmin,General_User,Business_Development,Digital_Content,Digital,PR_Image_Control,Finance_Admin,Sales_Marketing,Production_MCR,News,Music_Library_Mgt,Programs,Quality_Control,Research,Technology,Traffic_Control,Servers,Service_Accounts}

# Create GPO scripts
touch scripts/gpo/Sysadmin/apply_sysadmin_gpo.ps1
touch scripts/gpo/General_User/apply_general_user_gpo.ps1
touch scripts/gpo/Business_Development/apply_business_dev_gpo.ps1
touch scripts/gpo/Digital_Content/apply_digital_content_gpo.ps1
touch scripts/gpo/Digital/apply_digital_gpo.ps1
touch scripts/gpo/PR_Image_Control/apply_pr_image_control_gpo.ps1
touch scripts/gpo/Finance_Admin/apply_finance_admin_gpo.ps1
touch scripts/gpo/Sales_Marketing/apply_sales_marketing_gpo.ps1
touch scripts/gpo/Production_MCR/apply_production_mcr_gpo.ps1
touch scripts/gpo/News/apply_news_gpo.ps1
touch scripts/gpo/Music_Library_Mgt/apply_music_library_gpo.ps1
touch scripts/gpo/Programs/apply_programs_gpo.ps1
touch scripts/gpo/Quality_Control/apply_quality_control_gpo.ps1
touch scripts/gpo/Research/apply_research_gpo.ps1
touch scripts/gpo/Technology/apply_technology_gpo.ps1
touch scripts/gpo/Traffic_Control/apply_traffic_control_gpo.ps1
touch scripts/gpo/Servers/apply_servers_gpo.ps1
touch scripts/gpo/Service_Accounts/apply_service_accounts_gpo.ps1

# Create user_creation directory structure and files
mkdir -p scripts/user_creation/{Digital,PR_Image_Control,Finance_Admin,Sales_Marketing,Production_MCR,News,Music_Library_Mgt,Programs,Quality_Control,Research,Technology,Traffic_Control,Servers,Service_Accounts}

# Create user creation scripts
touch scripts/user_creation/Digital/create_digital_users.ps1
touch scripts/user_creation/PR_Image_Control/create_pr_image_control_users.ps1
touch scripts/user_creation/Finance_Admin/create_finance_admin_users.ps1
touch scripts/user_creation/Sales_Marketing/create_sales_marketing_users.ps1
touch scripts/user_creation/Production_MCR/create_production_mcr_users.ps1
touch scripts/user_creation/News/create_news_users.ps1
touch scripts/user_creation/Music_Library_Mgt/create_music_library_users.ps1
touch scripts/user_creation/Programs/create_programs_users.ps1
touch scripts/user_creation/Quality_Control/create_quality_control_users.ps1
touch scripts/user_creation/Research/create_research_users.ps1
touch scripts/user_creation/Technology/create_technology_users.ps1
touch scripts/user_creation/Traffic_Control/create_traffic_control_users.ps1
touch scripts/user_creation/Servers/create_servers_users.ps1
touch scripts/user_creation/Service_Accounts/create_service_accounts_users.ps1

# Create logs directory and files
mkdir -p logs
touch logs/validation.log
touch logs/gpo_application.log
touch logs/user_creation.log

# Create backups directory structure
mkdir -p backups/gpo_exports
mkdir -p backups/user_exports

echo "Directory structure created successfully!"
echo ""
echo "Summary:"
echo "- Created main directory: AD_Automation_Scripts"
echo "- Created $(find . -type d | wc -l) directories"
echo "- Created $(find . -type f | wc -l) files"
echo ""
echo "To verify the structure, run:"
echo "tree AD_Automation_Scripts"
echo "or"
echo "find AD_Automation_Scripts -type f | sort"