📄 Bulk Disable Azure AD Users via PowerShell Script
📌 Purpose
This script allows administrators to bulk disable Azure Active Directory (Azure AD) user accounts using their ObjectID values listed in a CSV file. It is ideal for scenarios such as offboarding, guest user cleanup, or temporary access suspension.

✅ Prerequisites
Windows PowerShell 5.1 or later
AzureAD PowerShell module installed:

Admin credentials with permission to manage Azure AD users
📂 CSV Format
The CSV file should contain a single column with the header ObjectID. Each row should include a valid Azure AD ObjectID (GUID) for the user to be disabled.

Example:


🚀 Usage Instructions
Update the script with the correct path to your CSV file:


Run the script in PowerShell:


Authenticate when prompted by Connect-AzureAD.

🔍 Script Behavior
Connects to Azure AD
Imports the CSV file
Iterates through each ObjectID
Attempts to disable the user account using:

Logs:
✅ Successful disables
⚠️ Skipped users (not found)
❌ Failures (errors during execution)
📊 Output Summary
At the end of the run, the script prints:

Total users successfully disabled
Total skipped (not found)
Total failed (errors)
