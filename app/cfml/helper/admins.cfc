<cfcomponent displayname="Master Admins Helper">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /helper/admins.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    
    
    <!--- DECLARE PRIVATE VARIABLES --->
    <cfset variables.master_admins_list = "" />
    
    
    <!--- ======== --->
    <!---   INIT   --->
    <!--- ======== --->
    
    <cffunction name="init" access="public" output="false" returnType="component">
    
        <!--- CREATE A LIST OF MASTER ADMIN USERNAMES --->
        <cfquery name="local.results" dataSource="#application.ds#">
            SELECT username
            FROM adminusers
            WHERE groupid = 1
        </cfquery>
        
        <cfset variables.master_admins_list = valueList(local.results.username) />
    
        <cfreturn this />
    </cffunction>



    <!--- =============================== --->
    <!---   MASK MASTER ADMIN USERNAMES   --->
    <!--- =============================== --->
    
        <cffunction name="masterUsernameFormat" access="public" output="false" returnType="string">
            <cfargument name="username" required="true" type="string" />
            
            <cfif listFindNoCase(variables.master_admins_list, trim(arguments.username))>
                <cfset local.return = "Finalsite" />
            <cfelse>
                <cfset local.return = arguments.username />
            </cfif>
        
            <cfreturn local.return />
        </cffunction>
        
</cfcomponent>