<cfcomponent displayname="Service Model" extends="Model">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /model/service.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    
    
    
    <!--- DEFINE DATABASE TABLES --->
    <cfset variables.services_table = "support_services" />
    <cfset variables.service_types_table = "support_services_types" />
    <cfset variables.adminusers = "adminusers" />

                           
                           
    <!--- ======== --->
    <!---   READ   --->
    <!--- ======== --->              
                           
        <cffunction name="read" access="public" output="false" returnType="query">
            <cfargument name="uuid" required="false" type="string" default="" />
            <cfargument name="scheduled_date" required="false" type="string" default="" />
            <cfargument name="join_type_name" required="false" type="boolean" default="true" />
            <cfargument name="join_user_name" required="false" type="boolean" default="true" />
            <cfargument name="exclude_deleted" required="false" type="boolean" default="true" />
            <cfargument name="exclude_parature_ticketed" required="false" type="boolean" default="false" />
            <cfargument name="exclude_serviced" required="false" type="boolean" default="false" />
            <cfargument name="order_by" required="false" type="string" default="id DESC" />
                
            <!--- DEFINE FIELDS --->
            <cfset local.fields = "d.id,"
                                & "d.uuid,"
                                & "d.type_id,"
                                & "d.updated_by,"
                                & "d.scheduled_by,"
                                & "d.serviced_by,"
                                & "d.updated_date,"
                                & "d.scheduled_date,"
                                & "d.serviced_date,"
                                & "d.properties,"
                                & "d.is_deleted,"
                                & "d.parature_ticket" />
            
                                
            <!--- DEFINE JOINS --->
            <cfset local.join = "" />
                                
            <!--- JOIN TYPE NAME --->
            <cfif arguments.join_type_name eq true>
            
                <cfset local.fields = listAppend(
                    local.fields,
                    "t.name AS type_name"
                ) />
                
                <cfset local.join = listAppend(
                    local.join,
                    "LEFT JOIN #variables.service_types_table# AS t ON d.type_id = t.id",
                    " "
                ) />
                
            </cfif>
            
            <!--- JOIN USER NAME --->
            <cfif arguments.join_user_name eq true>
            
                <cfset local.fields = listAppend(
                    local.fields,
                    "a1.username AS updated_user,
                     a2.username AS scheduled_user,
                     a3.username AS serviced_user,
                     a1.email AS updated_user_email,
                     a2.email AS scheduled_user_email,
                     a3.email AS serviced_user_email"
                ) />
                
                <!--- CREATED BY KEY --->
                <cfset local.join = listAppend(
                    local.join,
                    "LEFT JOIN #variables.adminusers# AS a1 ON d.updated_by = a1.adminid",
                    " "
                ) />

                <!--- SCHEDULED BY KEY --->
                <cfset local.join = listAppend(
                    local.join,
                    "LEFT JOIN #variables.adminusers# AS a2 ON d.scheduled_by = a2.adminid",
                    " "
                ) />
                
                <!--- SERVICED BY KEY --->
                <cfset local.join = listAppend(
                    local.join,
                    "LEFT JOIN #variables.adminusers# AS a3 ON d.serviced_by = a3.adminid",
                    " "
                ) /> 
                
            </cfif>


            <!--- COMPILE QUERY --->
            <cfquery name="local.return" dataSource="#application.ds#">
                SELECT #local.fields#
                FROM #variables.services_table# as d
                
                <!--- JOINS --->
                #local.join#
                
                <!--- CONDITIONS --->
                WHERE 1=1
                
                <!--- EXCLUDE DELETED --->
                <cfif arguments.exclude_deleted>
                    AND d.is_deleted = 'false'
                </cfif>
                
                <!--- EXCLUDE PARATURE TICKETED --->
                <cfif arguments.exclude_parature_ticketed>
                    AND d.parature_ticket IS NULL
                </cfif>
                
                <!--- EXCLUDE SERVICED --->
                <cfif arguments.exclude_serviced>
                    AND d.serviced_by IS NULL
                </cfif>
                
                <!--- BY UUID --->
                <cfif len(arguments.uuid)>
                    AND d.uuid = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.uuid)#" />
                </cfif>
                
                <!--- BY SCHEDULED DATE --->
                <cfif isDate(arguments.scheduled_date)>
                    AND d.scheduled_date = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP"
                                                         value="#dateFormat(arguments.scheduled_date, 'yyyy-mm-dd')#" />
                </cfif>
                
                ORDER BY #arguments.order_by#
            </cfquery>
        
            <cfreturn local.return />
        </cffunction>    

        
    
    <!--- ========== --->
    <!---   CREATE   --->
    <!--- ========== --->
    
        <cffunction name="create" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />
            <cfargument name="type_id" required="true" type="numeric" />
            <cfargument name="properties" required="true" type="struct" />
            <cfargument name="scheduled_date" required="false" type="string" default="" />
            
            <!--- CHECK THAT A SCHEDULED DATE WAS PASSED --->
            <cfif isDate(arguments.scheduled_date)>
                <cfset local.scheduled_date = createODBCDateTime(arguments.scheduled_date) />
                <cfset local.scheduled_is_null = false />
            <cfelse>
                <cfset local.scheduled_date = "" />
                <cfset local.scheduled_is_null = true />
            </cfif>
    
            <cfquery result="local.result" dataSource="#application.ds#">
                INSERT INTO #variables.services_table# (
                    uuid,
                    type_id,
                    updated_by,
                    updated_date,
                    scheduled_by,
                    scheduled_date,
                    properties,
                    is_deleted
                )
                VALUES (
                      <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.uuid)#" />
                    , <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#arguments.type_id#" />
                    , <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#session.admin#" />
                    , <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#createODBCDateTime(now())#" />
                    , <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#session.admin#" null="#local.scheduled_is_null#" />
                    , <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#local.scheduled_date#" null="#local.scheduled_is_null#" />
                    , <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#serializeJSON(arguments.properties)#" />
                    , <cfqueryparam CFSQLType="CF_SQL_BIT" value="false" />
                )
            </cfquery>
        
            <cfreturn true />
        </cffunction>
        
        
        
    <!--- ========== --->
    <!---   UPDATE   --->
    <!--- ========== --->
    
        <cffunction name="update" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />
            <cfargument name="type_id" required="false" type="numeric" default="0" />
            <cfargument name="properties" required="false" type="struct" default="#StructNew()#" />
            <cfargument name="scheduled_date" required="false" type="string" default="" />
            <cfargument name="mark_updated" required="false" type="boolean" default="true" />
            <cfargument name="is_deleted" required="false" type="boolean" default="false" />
            <cfargument name="parature_ticket" required="false" type="numeric" default="0" />

            <cfquery result="local.result" dataSource="#application.ds#">

                UPDATE #variables.services_table#
                SET uuid = uuid
                
                    <!--- TYPE ID --->
                    <cfif arguments.type_id>
                  , type_id = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#arguments.type_id#" />
                    </cfif>
                    
                    <!--- UPDATED --->
                    <cfif mark_updated>
                  , updated_by = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#session.admin#" />
                  , updated_date = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#createODBCDateTime(now())#" />
                    </cfif>
                    
                    <!--- SCHEDULED --->
                    <cfif isDate(arguments.scheduled_date)>
                  , scheduled_by = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#session.admin#" />
                  , scheduled_date = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#trim(arguments.scheduled_date)#" />
                    </cfif>
                  
                    <!--- PROPERTIES --->
                    <cfif not structIsEmpty(arguments.properties)>
                  , properties = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#serializeJSON(arguments.properties)#" />
                    </cfif>
                    
                    <!--- PARATURE TICKET --->
                    <cfif arguments.parature_ticket>
                  , parature_ticket = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#arguments.parature_ticket#" />
                    </cfif>
                    
                    <!--- IS DELETED --->
                  , is_deleted = <cfqueryparam CFSQLType="CF_SQL_BIT" value="#arguments.is_deleted#" />

                WHERE uuid = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.uuid)#" />

            </cfquery>
        
            <cfreturn true />
        </cffunction>
        
        
    <!--- ============ --->
    <!---   COMPLETE   --->
    <!--- ============ --->
    
        <cffunction name="complete" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />

            <cfquery result="local.result" dataSource="#application.ds#">

                UPDATE #variables.services_table#
                SET serviced_by = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#session.admin#" />
                  , serviced_date = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#createODBCDateTime(now())#" />
                WHERE uuid = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.uuid)#" />

            </cfquery>
        
            <cfreturn true />
        </cffunction>
        
        
    <!--- ========== --->
    <!---   DELETE   --->
    <!--- ========== --->
    
        <cffunction name="delete" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />
        
            <cfquery result="local.result" dataSource="#application.ds#">

                UPDATE #variables.services_table#
                SET updated_by = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#session.admin#" />                            
                  , updated_date = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#createODBCDateTime(now())#" />         
                  , is_deleted = <cfqueryparam CFSQLType="CF_SQL_BIT" value="true" />
                WHERE uuid = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.uuid)#" />

            </cfquery>
        
            <cfreturn true />
        </cffunction>


</cfcomponent>