<cfcomponent displayname="Service Queue Controller" extends="Controller">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /controller/service_queue.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->

    <!--- DEFINE CONTROLLER --->    
    <cfset this.name = "service_queue" />
    
    <!--- DEFINE MAX MINUTES AVAILABLE PROPERTY --->
    <cfset this.max_minutes_available = 360 />
        

    <!--- SERVICE QUEUE MODEL --->
    <cfset variables.service_queue = createObject(
        "component",
        "#application.webrootcfc#cf_support.services.app.cfml.model.service_queue"
    ) />
    
    
    <!--- ========= --->
    <!---   INDEX   --->
    <!--- ========= --->
    
        <cffunction name="index" access="public" output="false" returnType="struct">
        
            <!--- DEFINE ACTION --->
            <cfset local.return.action_name = "Index" />
            
            <!--- GET RESERVED DATES --->
            <cfset local.reserved_dates_query = variables.service_queue.readServiceDate() />


            <!--- RETURN RESERVED DATES THAT HAVE MATCHED OR EXCEEDED WORKLOAD IN MINUTES --->
            <cfset local.return.reserved_dates = ArrayNew(1) />

            <cfloop query="local.reserved_dates_query">
                <cfif local.reserved_dates_query.minutes_to_complete gte this.max_minutes_available>
                
                    <!--- FORMAT DATE --->
                    <cfset local.reserved_date = dateFormat(
                        reserved_dates_query.scheduled_date,
                        "m-d-yyyy"
                    ) />
                
                    <cfset ArrayAppend(
                        local.return.reserved_dates,
                        local.reserved_date
                    ) />
                </cfif>
            </cfloop>
            
            <!--- ADD TODAY (LOCAL) AS A RESERVED DATE --->
            <cfset ArrayAppend(
                local.return.reserved_dates,
                dateFormat(
                    application.cfctimeshift.serverToLocal(now()),
                    "m-d-yyyy"
                )
            ) />

            <cfreturn local.return />
        </cffunction>
        
        
        
    <!--- ================ --->
    <!---   INDEX REMOTE   --->
    <!--- ================ --->
    
        <cffunction name="indexRemote" access="remote" output="false" returnFormat="json">
        
            <!--- CALL NON-REMOTE GET SCHEDULED ACTION --->
            <cfset local.return = this.index() />
        
            <cfreturn serializeJSON(local.return.reserved_dates) />
        </cffunction>
        
        
    <!--- ======== --->
    <!---   FIND   --->
    <!--- ======== --->
    
        <cffunction name="find" access="public" output="false" returnType="struct">
            <cfargument name="scheduled_date" type="string" required="false" default="" />
            <cfargument name="scheduled_status" type="string" required="false" default="" />
        
            <!--- DEFINE ACTION --->
            <cfset local.return.action_name = "Find" />
            
            <!--- GET SERVICES BY SCHEDULED DATE --->
            <cfset local.return.services = variables.service_queue.readService(
                scheduled_date = arguments.scheduled_date,
                scheduled_status = arguments.scheduled_status
            ) />
        
            <cfreturn local.return />
        </cffunction>
        
        
    <!--- =========== --->
    <!---   RESERVE   --->
    <!--- =========== --->
    
        <cffunction name="reserve" access="public" output="false" returnType="struct">
        
            <!--- DEFINE ACTION --->
            <cfset local.return.action_name = "Reserve" />
            
            <!--- DEFINE APP RESPONSE --->
            <cfset local.response = false />
            
            <cfif not structIsEmpty(form)>
            
                <cftransaction>
                        
                        <!--- DELETE THE OLD QUEUE ENTRY IF IT EXISTS --->
                        <cfset variables.service_queue.delete(
                            uuid = form.uuid
                        ) />
                        
                        <!--- CREATE THE NEW QUEUE ENTRY --->
                        <cfset local.response = variables.service_queue.create(
                            uuid = form.uuid,
                            type_id = form.type_id,
                            scheduled_date = form.scheduled_date,
                            scheduled_status = "reserved",
                            minutes_to_complete = form.minutes_to_complete
                        ) />

                </cftransaction>
            
            </cfif>
            
            <cfif local.response>
                <cfset local.return.response = this.warning("reserved date") />
            <cfelse>
                <cfset local.return.response = this.exception("reserved date") />
            </cfif>
        
            <cfreturn local.return />
        </cffunction>
        
        
        
    <!--- ================== --->
    <!---   RESERVE REMOTE   --->
    <!--- ================== --->
    
        <cffunction name="reserveRemote" access="remote" output="false" returnFormat="json">
        
            <!--- CALL NON-REMOTE RESERVE ACTION --->
            <cfset local.return = this.reserve() />
        
            <cfreturn serializeJSON(local.return) />
        </cffunction>
        
        
        
    <!--- ============ --->
    <!---   SCHEDULE   --->
    <!--- ============ --->
    
        <cffunction name="schedule" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />
            <cfargument name="type_id" required="true" type="numeric" />
            <cfargument name="scheduled_date" required="true" type="string" />
            <cfargument name="minutes_to_complete" required="true" type="numeric" />
            
            <!--- CHECK THAT THERE ARE STILL SLOTS AVAILABLE FOR THAT DAY --->
            <cfset local.reserved_date_query = variables.service_queue.readServiceDate(
                exclude_uuid = arguments.uuid,
                scheduled_date = arguments.scheduled_date,
                type_id = arguments.type_id
            ) />
            
            <!--- ADJUST RETURNED MINUTES TO COMPLETE WITH ADDITION OF NEWEST REQUESTED SERVICE --->
            <cfset local.minutes_to_complete = val(local.reserved_date_query.minutes_to_complete)
                                             + val(arguments.minutes_to_complete) />
            
            <!--- CHANGE STATUS FROM "RESERVED" TO "SCHEDULED" IF TIME'S AVAILABLE --->
            <cfif local.minutes_to_complete lte this.max_minutes_available>
                <cfset local.return = variables.service_queue.update(
                    uuid = arguments.uuid,
                    type_id = arguments.type_id,
                    scheduled_date = arguments.scheduled_date,
                    scheduled_status = "scheduled",
                    minutes_to_complete = arguments.minutes_to_complete
                ) />
            <cfelse>
                <cfset local.return = false />
            </cfif>
        
            <cfreturn local.return />
        </cffunction>
        
        
    <!--- ========== --->
    <!---   DELETE   --->
    <!--- ========== --->
    
        <cffunction name="delete" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />
        
            <cfset local.return = variables.service_queue.delete(
                uuid = arguments.uuid
            ) />
        
            <cfreturn local.return />
        </cffunction>
        
        
    <!--- ============ --->
    <!---   COMPLETE   --->
    <!--- ============ --->
    
        <cffunction name="complete" access="public" output="false" returnType="boolean">
            <cfargument name="uuid" required="true" type="string" />
        
            <cfset local.return = variables.service_queue.complete(
                uuid = arguments.uuid
            ) />
        
            <cfreturn local.return />
        </cffunction>

    
</cfcomponent>