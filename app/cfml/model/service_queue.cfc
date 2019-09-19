<cfcomponent displayname="Service Queue" extends="Model">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /model/service_queue.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    
    
    
    <!--- DEFINE DATABASE AND TABLES --->
    <cfset variables.service_queue_database = "rss" />
    <cfset variables.service_queue_table = "support_services_queue" />
    
    
    
    <!--- ================= --->
    <!---   READ SERVICE   --->
    <!--- ================= --->
    
        <cffunction name="readService" access="public" output="false" returnType="query"
                    hint="RETURNS INDIVIDUAL SERVICES">
            <cfargument name="scheduled_date" type="string" required="false" default="" />
            <cfargument name="scheduled_status" type="string" required="false" default="scheduled" />
            
            <!--- FORMAT SCHEDULED DATE --->
            <cfif isDate(arguments.scheduled_date)>
                <cfset local.scheduled_date = dateFormat(arguments.scheduled_date, "yyyy-mm-dd") />
            </cfif>
            
            <cfquery name="local.return" dataSource="#variables.service_queue_database#">
                SELECT id, datasource, uuid, type_id, updated_date, scheduled_date, scheduled_status, minutes_to_complete
                FROM #variables.service_queue_table#
                WHERE 1=1
                
                <!--- SCHEDULED DATE CLAUSE --->
                <cfif isDefined("local.scheduled_date")>
                    AND (scheduled_date = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#local.scheduled_date#" />)
                </cfif>
                
                <!--- SCHEDULED STATUS CLAUSE --->
                <cfif len(arguments.scheduled_status)> 
                    AND (scheduled_status IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.scheduled_status#" />))
                </cfif>
            </cfquery>
            
            
            <cfreturn local.return />
        </cffunction>
    
        
        
    <!--- ===================== --->
    <!---   READ SERVICE DATE   --->
    <!--- ===================== --->
    
        <cffunction name="readServiceDate" access="public" output="false" returntype="query"
                    hint="READ ALL SERVICES GROUPED BY THEIR SERVICE DATE">
            <cfargument name="minutes_held" type="numeric" required="false" default="15" />
            <cfargument name="exclude_uuid" type="string" required="false" default="" />
            <cfargument name="scheduled_date" type="string" required="false" default="" />
            <cfargument name="type_id" type="numeric" required="false" default="0" />
            
            <!--- TREAT ALL COMPLETE/SCHEDULED/RESERVED (IF LESS THAN MINUTES HELD TIME) STATUSES
                  AS TAKING UP SPACE IN THE AVAILABLE WORK TIME EQUATION. --->
            <cfquery name="local.return" dataSource="#variables.service_queue_database#">
                SELECT type_id, scheduled_date, SUM(minutes_to_complete) AS minutes_to_complete
                FROM #variables.service_queue_table#
                WHERE (
                          scheduled_status = 'scheduled'
                          OR
                          scheduled_status = 'complete'
                          OR
                          (
                              scheduled_status = 'reserved'
                              AND
                              updated_date > DATEADD(minute, #arguments.minutes_held# * -1, GETDATE())
                          )
                  )
                <!--- RESTRICT BY SPECIFIC DATE IF SUPPLIED --->
                <cfif isDate(arguments.scheduled_date)>
                    AND (scheduled_date = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#dateFormat(arguments.scheduled_date, 'yyyy-mm-dd')#" />)
                <cfelse>
                    AND (scheduled_date > GETDATE())
                </cfif>
                  
                <!--- RESTRICT BY TYPE ID IF SUPPLIED --->
                <cfif arguments.type_id>
                    AND (type_id = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#arguments.type_id#" />)
                </cfif>

                <!--- DON'T INCLUDE SERVICE IN QUERY RESULTS --->
                <cfif len(arguments.exclude_uuid)>
                    AND (uuid <> <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.exclude_uuid#" />)
                </cfif>

                GROUP BY type_id, scheduled_date
            </cfquery>

            <cfreturn local.return />
        </cffunction>
        
        
        
    <!--- ========== --->
    <!---   CREATE   --->
    <!--- ========== --->
    
        <cffunction name="create" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />
            <cfargument name="type_id" required="true" type="numeric" />
            <cfargument name="scheduled_date" required="true" type="date" />
            <cfargument name="scheduled_status" required="true" type="string" />
            <cfargument name="minutes_to_complete" required="true" type="numeric" />
            
            <cfquery result="local.result" dataSource="#variables.service_queue_database#">
                INSERT INTO #variables.service_queue_table# (
                    datasource,
                    uuid,
                    type_id,
                    updated_date,
                    scheduled_date,
                    scheduled_status,
                    minutes_to_complete
                )
                VALUES (
                      <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#application.ds#" />
                    , <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.uuid)#" />
                    , <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#arguments.type_id#" />
                    , <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#createODBCDateTime(now())#" />
                    , <cfqueryparam CFSQLTYpe="CF_SQL_TIMESTAMP" value="#createODBCDateTime(arguments.scheduled_date)#" />
                    , <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.scheduled_status)#" />
                    , <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#arguments.minutes_to_complete#" />
                )
            </cfquery>
            
            <cfreturn true />
        </cffunction>
        
        
        
    <!--- ========== --->
    <!---   UPDATE   --->
    <!--- ========== --->
    
        <cffunction name="update" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />
            <cfargument name="type_id" required="true" type="numeric" />
            <cfargument name="scheduled_date" required="true" type="date" />
            <cfargument name="scheduled_status" required="true" type="string" />
            <cfargument name="minutes_to_complete" required="true" type="numeric" />            
            
            <cfquery result="local.result" dataSource="#variables.service_queue_database#">
                UPDATE #variables.service_queue_table#
                SET type_id = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#arguments.type_id#" />
                  , updated_date = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#createODBCDateTime(now())#" />
                  , scheduled_date = <cfqueryparam CFSQLTYpe="CF_SQL_TIMESTAMP" value="#createODBCDateTime(arguments.scheduled_date)#" />
                  , scheduled_status = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.scheduled_status)#" />
                  , minutes_to_complete = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#arguments.minutes_to_complete#" />
                WHERE uuid = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.uuid)#" />
                  AND (
                          scheduled_status = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="reserved" />
                      OR 
                          scheduled_status = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="scheduled" />
                      )
            </cfquery>
            
            <cfreturn true />
        
        </cffunction>
        
        
        
    <!--- ============ --->
    <!---   COMPLETE   --->
    <!--- ============ --->
    
        <cffunction name="complete" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />
            
            <cfquery result="local.result" dataSource="#variables.service_queue_database#">
                UPDATE #variables.service_queue_table#
                SET updated_date = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#createODBCDateTime(now())#" />
                  , scheduled_status = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="complete" />
                WHERE uuid = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.uuid)#" />
                  AND scheduled_status = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="scheduled" />
            </cfquery>

            <cfreturn true />
        </cffunction>
        
        
        
    <!--- ========== --->
    <!---   DELETE   --->
    <!--- ========== --->
    
        <cffunction name="delete" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />
            
            <cfquery result="local.result" dataSource="#variables.service_queue_database#">
                UPDATE #variables.service_queue_table#
                SET scheduled_status = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="deleted" />
                  , updated_date = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#createODBCDateTime(now())#" />
                WHERE uuid = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#trim(arguments.uuid)#" />
            </cfquery>
        
            <cfreturn true />
        </cffunction>
        
    
</cfcomponent>