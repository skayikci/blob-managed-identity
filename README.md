### Steps to create system assigned authentication

1. Create system assigned identity on azure (or via shell)
    1. Go to your app > Settings > Identity
    2. Status > On > Click on : Save
2. Now save your object (principal) id somewhere.
3. Grant accesses to your blob
    1. Now switch to your blob (or create one with default settings)
    2. Access Control (IAM)
    3. Add > Add Role Assignment > Select `Storage Blob Data Contributor'
    4. On the members section > Managed Identity > +Select Members > Select the app that you have created (this one!, i
       mean select the app that you just created managed identity for)
    5. You can verify by going to Access control > Role Assignments > At the bottom > Storage Blob Data Contributor
4. Let's try with postman!

### Disclaimer Text

The sample data provided in this repository, including but not limited to names, addresses, phone numbers, and email
addresses, are entirely fictional. Any resemblance to real persons, living or dead, actual addresses, phone numbers, or
email addresses is purely coincidental.

I do not bear any responsibility for any coincidental matches to real-world data and am not responsible for any related
data issues. This data is meant solely for testing and demonstration purposes.