<cfcomponent displayname="Service Controller" extends="Controller">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /controller/service.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->

    <!--- DEFINE CONTROLLER --->    
    <cfset this.name = "service" />
        

    <!--- SERVICE MODEL --->
    <cfset variables.service = createObject(
        "component",
        "#application.webrootcfc#cf_support.services.app.cfml.model.service"
    ) />
    
    <!--- SERVICE TYPE MODEL --->
    <cfset variables.service_type = createObject(
        "component",
        "#application.webrootcfc#cf_support.services.app.cfml.model.service_type"
    ) />
    
    <!--- SERVICE QUEUE CONTROLLER --->
    <cfset variables.service_queue = createObject(
        "component",
        "#application.webrootcfc#cf_support.services.app.cfml.controller.service_queue"
    ) />
    
    <!--- DATE HELPER --->
    <cfset variables.helper.date = createObject(
        "component",
        "#application.webrootcfc#cf_support.services.app.cfml.helper.date"
    ) />
        
        
    <!--- ========= --->
    <!---   INDEX   --->
    <!--- ========= --->
    
        <cffunction name="index" access="public" output="false" returnType="struct">
        
            <!--- DEFINE ACTION --->
            <cfset local.return.path = "#this.name#/dashboard.cfm" />
            <cfset local.return.action_name = "Index" />
            
            <!--- GET ALL SERVICE FOR VIEW --->
            <cfset local.return.service = variables.service.read(
                order_by = "d.serviced_date,d.scheduled_date,d.updated_date DESC"
            ) />
        
            <cfreturn local.return />
        </cffunction>
        
        
    <!--- ======== --->
    <!---   FIND   --->
    <!--- ======== --->
    
        <cffunction name="find" access="public" output="false" returnType="struct">
            <cfargument name="scheduled_date" type="string" required="false" default="" />
            <cfargument name="exclude_parature_ticketed" type="boolean" required="false" default="false" />
            <cfargument name="exclude_serviced" type="boolean" required="false" default="false" />
        
            <!--- DEFINE ACTION --->
            <cfset local.return.action_name = "Find" />
            
            <!--- FIND SERVICE --->
            <cfset local.return.service = variables.service.read(
                scheduled_date = arguments.scheduled_date,
                exclude_parature_ticketed = arguments.exclude_parature_ticketed,
                exclude_serviced = arguments.exclude_serviced
            ) />
        
            <cfreturn local.return />
        </cffunction>
        
        
    <!--- ======= --->
    <!---   NEW   --->
    <!--- ======= --->
    
        <cffunction name="new" access="public" output="false" returnType="struct">
        
            <!--- DEFINE ACTION --->
            <cfset local.return.path = "#this.name#/form.cfm" />
            <cfset local.return.action_name = "New" />
            
            <!--- GET ALL SERVICE TYPES FOR VIEW --->
            <cfset local.return.service_type = variables.service_type.read() />
            
            <cfreturn local.return />
        </cffunction>      
    
    
    
    <!--- ======== --->
    <!---   EDIT   --->
    <!--- ======== --->
    
        <cffunction name="edit" access="public" output="false" returnType="struct">
        
            <!--- EXTEND "NEW" ACTION --->
            <cfset local.return = this.new() />
        
            <!--- DEFINE URL PARAM --->
            <cfparam name="url.uuid" default="" />

            <!--- GET SERVICE TO EDIT --->
            <cfset local.return.service = variables.service.read(
                uuid = url.uuid
            ) />
            
            <!--- REDIRECT TO INDEX IF RECORD NOT FOUND TO EDIT
                  OR IF THE SERVICE ISN'T ELIGIBLE TO BE EDITED --->
            <cfif not local.return.service.recordcount>
            
                <cfset local.return = this.index() />
                <cfset local.return.response = this.exception("does not exist") />

            <cfelseif isDefined("url.action")
                  and url.action eq "edit" 
                  and len(local.return.service.parature_ticket)
                  and session.admingroup neq 1>
                
                <cfset local.return = this.index() />
                <cfset local.return.response = this.exception("edited") />
            
            <cfelse>
            
                <cfset local.return.action_name = "Edit" />
                
            </cfif>
            
            <cfreturn local.return />
        </cffunction>


     
    <!--- ========== --->
    <!---   MANAGE   --->
    <!--- ========== --->
    
        <cffunction name="manage" access="public" output="false" returnType="struct">
        
            <!--- EXTEND "EDIT" ACTION --->
            <cfset local.return = this.edit() />
        
            <!--- DEFINE ACTION IF NOT REDIRECTED TO INDEX --->
            <cfif local.return.action_name neq "Index">
                <cfset local.return.path = "#this.name#/details.cfm" />
                <cfset local.return.action_name = "Manage" />
            </cfif>
        
            <cfreturn local.return />
        </cffunction>

        
        
    <!--- ========= --->
    <!---   CLONE   --->
    <!--- ========= --->
    
        <cffunction name="clone" access="public" output="false" returnType="struct">
        
            <!--- EXTEND "EDIT" ACTION --->
            <cfset local.return = this.edit() />

            <cfif local.return.service.recordcount>
            
                <!--- CREATE A NEW UUID --->
                <cfset querySetCell(local.return.service, "uuid", createUUID()) />
                
                <!--- NULL SCHEDULED DATE --->
                <cfset querySetCell(local.return.service, "scheduled_date", "") />
            
                <!--- DEFINE ACTION --->
                <cfset local.return.action_name = "New" />
                
            </cfif>
            
            <cfreturn local.return />
        </cffunction>

        
        
    <!--- ======== --->
    <!---   SAVE   --->
    <!--- ======== --->
        
        <cffunction name="save" access="public" output="false" returnType="struct">
        
            <!--- DEFINE ACTION --->
            <cfset local.return.action_name = "Save" />
            
            <!--- DEFINE APP RESPONSE --->
            <cfset local.response = false />

        
            <!--- MAKE SURE A FORM WAS SUBMITTED --->
            <cfif not structIsEmpty(form)>
            
                <!--- BELOW WE'LL NEED TO REMOVE SOME KEYS FROM THE FORM
                      STRUCT.  FOR SOME REASON IF A VARIABLE IS SET EQUAL 
                      TO THE FORM STRUCT, ANY ACTION DONE TO THAT VARIABLE
                      IS ALSO DONE TO THE FORM STRUCT.
                      
                      LONG STORY SHORT, WE NEED TO BE EXPLICIT FOR THE KEYS
                      WE WANT SEPARATE FROM THE PROPERTIES STRUCT --->
                <cfset local.uuid = form.uuid />
                <cfset local.action = form.action />
                
                <!--- ADJUST SUBMITTED DATE TO SERVER TIME --->
                <cfset local.scheduled_date = variables.helper.date.format(
                    datetime = form.scheduled_date,
                    day_shift_direction = "toServer"
                ) />
                
                <!--- SPLIT TYPE INTO TYPE_ID AND MINUTES_TO_COMPLETE --->
                <cfif len(form.type)>
                    <cfset local.type_id = listGetAt(form.type, 1, "|") />
                    <cfset local.minutes_to_complete = listGetAt(form.type, 2, "|") />
                </cfif>
                
                <!--- IF NOT SCHEDULE DATE IS PASSED, DON'T WORRY ABOUT THE
                      QUEUE.  MOVE ON TO SUBMITTING THE SERVICE.
                      
                      IF A DATE WAS SUBMITTED TRY AND CHANGE QUEUE STATUS FROM
                      "RESERVED" TO "SCHEDULED" IN QUEUE --->
                <cfif not len(local.scheduled_date)>
                
                    <cfset local.queue_response = true />
                    
                <cfelseif isDate(local.scheduled_date)>
                
                    <cfset local.queue_response = variables.service_queue.schedule(
                        uuid = local.uuid,
                        type_id = local.type_id,
                        scheduled_date = local.scheduled_date,
                        minutes_to_complete = local.minutes_to_complete
                    ) />

                </cfif>
                
                <!--- SAVE THE SERVICE TO THE DB --->
                <cfif local.queue_response>
                
                    <!--- HERE IS WHERE WE CLEAR OUT ANY FORM KEYS THAT WE
                          DON'T WANT INCLUDED IN THE PROPERTIES FIELD.
                          
                          WE DO THIS BECAUSE IN THE "DETAILS" VIEW WE NEED TO
                          DYNAMICALLY LOAD FIELDS FOR DIFFERENT SERVICE TYPES
                          WITHOUT WORRYING ABOUT WHAT FIELDS SHOW.
                          
                          CLEARING THESE SHOULD LEAVE ONLY SERVICE "FIELDS". --->
                    <cfset structDelete(form, "ACTION") />
                    <cfset structDelete(form, "FIELDNAMES") />
                    <cfset structDelete(form, "MINUTES_TO_COMPLETE") />
                    <cfset structDelete(form, "SCHEDULED_DATE") />
                    <cfset structDelete(form, "TYPE") />
                    <cfset structDelete(form, "TYPE_ID") />
                    <cfset structDelete(form, "UUID") />
                
                    <cfswitch expression="#trim(local.action)#">
                        <cfcase value="Save New">
                            
                            <cfset local.response = variables.service.create(
                                uuid = local.uuid,
                                type_id = local.type_id,
                                properties = form,
                                scheduled_date = local.scheduled_date
                            ) />
                        
                        </cfcase>
                        <cfcase value="Save Edit">
                        
                            <cfset local.response = variables.service.update(
                                uuid = local.uuid,
                                type_id = local.type_id,
                                properties = form,
                                scheduled_date = local.scheduled_date
                            ) />
                    
                        </cfcase>
                        <cfdefaultcase>
                            <cfset local.response = false />
                        </cfdefaultcase>
                    </cfswitch>
                        
                    <!--- APP RESPONSE --->
                    <cfif local.response>
                
                        <cfset local.return.response = this.success("saved") />
                        
                    <cfelse>
                    
                        <!--- DELETE FROM QUEUE --->
                        <cfset variables.service_queue.delete(
                            uuid = local.uuid
                        ) />
    
                        <cfset local.return.response = this.exception("saved") />
                    
                    </cfif>
                    
                <cfelse>
                
                    <!--- QUEUE RESPONSE --->
                    <cfset local.return.response = this.exception("reserved date") />
                
                </cfif>
                
            <cfelse>
            
                <cfset local.return.response = this.exception() />
                
            </cfif>
            
            <!--- SEND US BACK TO THE INDEX VIEW --->
            <cfset structAppend(local.return, this.index()) />
        
            <cfreturn local.return />
        </cffunction>
        
        
        
    <!--- ========== --->
    <!---   DELETE   --->
    <!--- ========== --->
    
        <cffunction name="delete" access="public" output="false" returnType="struct">
        
            <!--- DEFINE ACTION --->
            <cfset local.return.action_name = "Delete" />
            
            <!--- DEFINE PARAMS --->
            <cfparam name="url.uuid" default="" />
            
            <!--- READ SERVICE FIRST TO MAKE SURE IT CAN BE DELETED --->
            <cfset local.response = variables.service.read(
                uuid = trim(url.uuid)
            ) />
            
            <!--- DON'T DELETE ANY  SERVICE THAT ALREADY HAS A 
                  PARATURE TICKET NUMBER --->
            <cfif not len(local.response.parature_ticket)
               or session.admingroup eq 1>
                
                <!--- PERFORM DELETION --->
                <cfset local.response = variables.service.delete(
                    uuid = url.uuid
                ) />
                
                <!--- DELETE FROM QUEUE --->
                <cfset variables.service_queue.delete(
                    uuid = url.uuid
                ) />
                
                <!--- APP RESPONSE --->
                <cfif local.response>
            
                    <cfset local.return.response = this.success("deleted") />
                
                </cfif>
                
            <cfelse>
            
                <cfset local.return.response = this.exception("deleted") />
            
            </cfif>

            <!--- SEND US BACK TO THE INDEX VIEW --->
            <cfset structAppend(local.return, this.index()) />
            
            <cfreturn local.return />
        </cffunction>
        
        
        
    <!--- ============ --->
    <!---   COMPLETE   --->
    <!--- ============ --->
    
        <cffunction name="complete" access="public" output="false" returnType="struct">
        
            <!--- MASTER ADMINS ONLY --->
            <cfif isDefined("session.admingroup")
              and session.admingroup eq 1>
            
                <!--- DEFINE ACTION --->
                <cfset local.return.action_name = "Complete" />
                
                <!--- DEFINE PARAMS --->
                <cfparam name="url.uuid" default="" />
                
                <!--- PERFORM UPDATE --->
                <cfset local.response = variables.service.complete(
                    uuid = url.uuid
                ) />
                
                <!--- UPDATE QUEUE --->
                <cfset variables.service_queue.complete(
                    uuid = url.uuid
                ) />
                
                <!--- APP RESPONSE --->
                <cfif local.response>
            
                    <cfset local.return.response = this.success("completed") />
                
                </cfif>
                
            <cfelse>
            
                <cfset local.return.response = this.exception("completed") />
            
            </cfif>

            <!--- SEND US BACK TO THE INDEX VIEW --->
            <cfset structAppend(local.return, this.index()) />
        
            <cfreturn local.return />
        </cffunction>
        
        
    <!--- ========== --->
    <!---   UPDATE   --->
    <!--- ========== --->
    
        <cffunction name="update" access="public" output="false" returnType="struct">
            <cfargument name="uuid" required="true" type="string" />
            <cfargument name="parature_ticket" required="false" type="numeric" default="0">
        
            <!--- DEFINE ACTION --->
            <cfset local.return.action_name = "Update" />
            
            <!--- PERFORM DELETION --->
            <cfset local.return.response = variables.service.update(
                uuid = arguments.uuid,
                parature_ticket = arguments.parature_ticket,
                mark_updated = false
            ) />

            
            <cfreturn local.return />
        </cffunction>
    
</cfcomponent>