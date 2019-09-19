<cfcomponent displayname="Service Types Controller" extends="Controller">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /controller/service_type.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->

    <!--- DEFINE CONTROLLER --->    
    <cfset this.name = "service_type" />

    <!--- SERVICE TYPES MODEL --->
    <cfset variables.service_type = createObject(
        "component",
        "#application.webrootcfc#cf_support.services.app.cfml.model.service_type"
    ) />


        
    <!--- ======== --->
    <!---   FIND   --->
    <!--- ======== --->
    
        <cffunction name="find" access="public" output="false" returnType="struct">
            <cfargument name="id_list" required="true" type="string" />
        
            <!--- DEFINE ACTION --->
            <cfset local.return.action_name = "Index" />
            
            <!--- GET SERVICE TYPES BY TYPE ID LIST --->
            <cfset local.return.service_type = variables.service_type.read(
                id = arguments.id_list
            ) />
        
            <cfreturn local.return />
        </cffunction>
    
    
</cfcomponent>