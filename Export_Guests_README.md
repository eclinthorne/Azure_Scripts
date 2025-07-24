# Azure_Scripts
A series of scripts I find useful in entraID.
# Guest User Export Script for Microsoft Entra ID (Azure AD)

## 📘 Overview
This PowerShell script exports detailed information about guest users in Microsoft Entra ID (formerly Azure AD). It connects to Microsoft Graph API, retrieves guest user data, optionally filters users based on group membership, and exports the results to a timestamped CSV file.

## ✨ Features
- Connects to Microsoft Graph API using required scopes
- Retrieves guest users (`userType eq 'Guest'`)
- Extracts key attributes:
  - Display Name
  - Email
  - UPN (User Principal Name)
  - ObjectId
  - Account creation date
  - Last interactive sign-in
  - Last non-interactive sign-in
  - Days since last login
- Optional filtering to exclude users not in any groups
- Escapes special characters for CSV compatibility
- Timestamped CSV file naming
- Logs progress with timestamps

## 🛠 Requirements
- PowerShell 5.1 or later
- Microsoft Graph PowerShell module (`Microsoft.Graph.Users`)
- Admin permissions in Azure AD:
  - `User.Read.All`
  - `GroupMember.Read.All`
- Internet access

## 🚀 Usage
1. Open PowerShell with administrative privileges.
2. Run the script.
3. When prompted, select a folder to save the CSV file.
4. The script will:
   - Connect to Microsoft Graph
   - Retrieve guest users
   - Optionally filter by group membership
   - Export the data to a timestamped CSV file

### 🔄 Toggle Group Membership Filtering
To enable or disable group membership filtering, modify this line in the script:

```powershell
$FilterByGroupMembership = $true  # Set to $false to include all users regardless of group membership
