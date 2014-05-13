global class CheckInController{

    public CheckInController(){}
    
    @RemoteAction
    global static List<Account> getNearby(String lat, String lon){

        // SOQL query to get the nearest accounts
        String queryString =
        'SELECT Id, Name, Location__Latitude__s, Location__Longitude__s, ' +
        'Phone, BillingStreet ' +
        'FROM Account ' +
        'WHERE DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') < 20 ' +
        'ORDER BY DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') ' +
        'LIMIT 10';

        // Run and return the query results
        return(database.Query(queryString)); 
    }
    
    @RemoteAction
    global static boolean insertTask(String acctId, String status, String comments) {
        try {
            Task myTask = new Task();
            myTask.WhatId = acctId;
            myTask.OwnerId= UserInfo.GetUserId();
            myTask.Status = status;
            myTask.Subject = 'On-Site';
            myTask.Description = comments;
            myTask.Priority = 'Normal';
            myTask.ActivityDate = date.today();
            insert myTask;
            
            FeedItem post = new FeedItem();
            post.ParentId = acctId;
            post.Body = UserInfo.getName() + ' just checked in for an on-site meeting.\n' + comments;
            post.type = 'LinkPost'; 
            post.LinkUrl = '/' + myTask.Id;
            post.Title = 'Checked In: ' + myTask.subject;
            insert post; 
        } catch(System.Exception ex) {
            system.debug(ex.getMessage());
        }
        
        return true;
    }
    
    global String getTaskStatuses() {
        Schema.DescribeFieldResult statusField = Task.Status.getDescribe();
        List<String> plValues = new List<String>();
        for (Schema.PicklistEntry pe : statusField.getPicklistValues()) {
            plValues.add(pe.getValue());
        }
        return JSON.serialize(plValues);
    }
}