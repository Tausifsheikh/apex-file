public class mappingProfile {
    
    @AuraEnabled
    public static wrapprofile getDetailProfile(string prf)
    {   
        
        profile prof = [select id,name ,UserLicense.name ,description from profile where name=:prf];
        
        PermissionSet pp=[SELECT ProfileId,iscustom FROM PermissionSet where ProfileId=:prof.id];
        
        wrapprofile cc =  new wrapprofile();
        
        cc.iscustom=pp.iscustom;
        cc.descrpt=prof.description;
        cc.UserLicense=prof.UserLicense.name ;
        return cc;
    }
    @AuraEnabled
    public static list<string>  profileCall(string prf)
    {
        list<profile> prof = new list<profile>();
        if(prf != null)
            prof = [select name from profile where name=:prf];
        else
            prof = [select id,name from profile];
        
        list<string> str = new list<string>();
        for(profile p:prof)
        {
            str.add(p.name);
        }
        return str;
    }
    @AuraEnabled
    public static list<ApexClass> apexCall(string name )
    {
        list<ApexClass> prof1 = new list<ApexClass>();
        
        prof1 = [SELECT id, Name FROM ApexClass WHERE Id IN (SELECT SetupEntityId FROM SetupEntityAccess
                                                             WHERE Parent.Profile.Name=:name)];
        
        return prof1; 
    }
    @AuraEnabled
    public static list<ApexClass> apexCall_2(string name )
    {
        list<ApexClass> prof2 = new list<ApexClass>();
        
        prof2 = [SELECT id, Name FROM ApexClass WHERE Id IN (SELECT SetupEntityId FROM SetupEntityAccess
                                                             WHERE Parent.Profile.Name=:name)];
        
        return prof2;
        
    }
    
    
    @AuraEnabled
    public static list<Data> Main(string name)
    {
        system.debug('ids ======> '+name);
        HttpRequest req=new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('content-Type','application/json');
        string domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
        //string ids = '00e2v00000300VRAAY';
        Profile pr = [select id,name from profile where Name=:name];
        string ids = pr.id ;
        String newString = '\''+ ids + '\'';
        system.debug('newString====> '+newString);
        req.setEndpoint('callout:CallMeBack/services/data/v33.0/tooling/query/?q=Select+id,Layout.Name,RecordType.Name,RecordType.SobjectType+from+ProfileLayout+where+RecordTypeId!=+null+and+ProfileId=+'+newString);
        req.setMethod('GET');
        system.Http h=new system.Http();
        HttpResponse res=h.send(req);
        string body = res.getBody();
        system.debug('body :: :: '+body);
        system.JSONParser jp = JSON.createParser(body);
        list<WrapClass> wrap = new list<WrapClass>();
        while(jp.nextToken() != null)
        {
            if(jp.getText() == 'records')
            {
                jp.nextToken();
                list<WrapClass> wr = (list<WrapClass>)jp.readValueAs(list<WrapClass>.Class);
                
                wrap =wr.clone();
            }
        }
        /* Map<string,object> usrMap=(Map<string,object>)JSON.deserializeUntyped(body);
system.debug(usrMap.keyset());
system.debug(usrMap.values());
system.debug(usrMap.get('records'));
system.debug('Yo Yo '+wrap);
for(WrapClass wr:wrap)
{
system.debug('Name : '+wr.Layout.Name);
}*/
        list<Data> wslist = new list<Data>();
        for(WrapClass wr:wrap)
        {
            
            Data dt = new Data();
            if(wr.RecordType != null )
            {
                dt.LayoutName = wr.RecordType.SobjectType+'.'+ wr.Layout.Name;
                dt.RecordName = wr.RecordType.SobjectType+'.'+wr.RecordType.Name;
                
            }
            wslist.add(dt);
            //system.debug('Name : '+wr.Layout.Name);
        }
        system.debug('wslist =====>'+wslist);
        return wslist;
        
    }
    
    public class Data{
        @AuraEnabled
        public string LayoutName{get;set;}
        @AuraEnabled
        public string RecordName{get;set;}
    }
    
    public class wrapprofile{
        @AuraEnabled
        public    string UserLicense {get;set;}
        @AuraEnabled
        public   boolean iscustom {get;set;}
        @AuraEnabled
        public  string descrpt {get;set;}
        
        
    }
    
}