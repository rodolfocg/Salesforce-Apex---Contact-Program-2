# Contact-Tracing-Program 
Contact Tracing program for identifying persons and locations in risk of COVID-19 contamination using SALESFORCE

App designed to check and monitor people's health status according to each other. If a person gets infected, the app can determine if other people has been contacted and changes the health status accordingly. The system uses a match between visit dates and location for tracing.

//Users:         (COMPLETED)
-Persons: Workers can acess the User View Tab to check their own health card. Has it's own name, phone number and token number.
-Admins: create and update new persons and locations status. Has it's own name, phone number and token number.

//Funcionalities:              (COMPLETED)
Health Card: shows the Name, phone number and a tokenized number for each person. It also shows Recent Visits, Persons contacted in the last 30 days and Health Status. (Name and phone number can only be seen by the admin, common users can only the token number that can be reported to admin's)
Person and Location tracing: Identifies names, visit dates and locations that were used by the persons and creates location and person traces.

//Dashboards 

----Location View: Count and details of locations used by the persons. Locations can be used to trace person to person relations (Visitation etc.) and widespread of the virus.  (COMPLETED)
Aura Dashboard (Completed)

---Health Admin view: Dashboard used by the administrator to get an overview of how many people are in Red Status or Green, Yellow and Orange status.
-Show how many persons are in each Status (Score 1 to 10). (COMPLETED)

-Create new person (mobile/name)  (COMPLETED)

-Recent updates, locations and visit dates on the Health Card  (COMPLETED)

-Aura dashboard (Completed)

//USER VIEW DashBoard:
Used by the individuals to check persons and locations they personally contacted in 30. (COMPLETED)
Each one has a health card that contains: phone number, update date and people he contacted in the last 30 days. (Only the admins can see the name and phones from the health cards. Common users will only see a token value, that can be submitted to an admin). (COMPLETED)

Aura Dashboard (Completed)

SALESFORCE 2022

<img width="2004" alt="Contact Tracing" src="https://user-images.githubusercontent.com/83418602/163292262-34745390-2711-4c6c-b175-4a687ffe772e.png">

