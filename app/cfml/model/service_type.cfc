<cfcomponent displayname="Service Types Model" extends="Model">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /model/service_type.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    
        

    <!--- DEFINE DATABASE TABLES --->
    <cfset variables.service_types_table = "support_services_types" />


        
    <!--- ======== --->
    <!---   READ   --->
    <!--- ======== --->
    
        <cffunction name="read" access="public" output="false" returnType="query">
            <cfargument name="id_list" type="string" required="false" default="" />
        
            <cfquery name="local.return" dataSource="rss">
                SELECT id, name, minutes_to_complete
                FROM #variables.service_types_table#
                
                <cfif len(arguments.id_list)>
                WHERE id IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.id_list#" />)
                </cfif>
                
                ORDER BY name asc
            </cfquery>
        
            <cfreturn local.return />
        </cffunction>
    
    
</cfcomponent>