<cfsilent>

    <!--- ==================================================================================== --->
    <!--- ==================================================================================== --->
    <!--- ==================================================================================== -- >
    
    
              TITLE _____________ index.cfm
              AUTHORS ___________ Blake Eddins
    
    
    < --- ==================================================================================== --->
    <!--- ==================================================================================== --->
    <!--- ==================================================================================== --->


    <!--- ==================== --->
    <!---   PERMISSION CHECK   --->
    <!--- ==================== --->
    
        <!--- CHECK FOR ADMIN SESSION AND PROMPT USER WITH MESSAGE IF NOT LOGGED IN --->
        <cfinclude template="../../admincheck1.cfm" />
        
        <!--- INCLUDES CAN'T BE CALLED DIRECTLY.  SEE /APP/CFML/VIEW/_INCLUDE.CFM FOR USE --->
        <cfset inAdmin = true />
        
        
        
    <!--- ================== --->
    <!---   HELPER CLASSES   --->
    <!--- ================== --->
    
        <!--- DEFINE THESE CLASSES TO BE USED BY THE VIEW
              TO PERFORM CERTAIN REPEATABLE FUNCTIONS --->
              
        <cfset helper = StructNew() />
    
        <!--- ADD STRING HELPER --->
        <cfset helper.string = createObject(
            "component",
            "#application.webrootcfc#cf_support.services.app.cfml.helper.string"
        ) />

        <!--- ADJUST THE WAY DATES DISPLAY IN THE VIEW --->
        <cfset helper.date = createObject(
            "component",
            "#application.webrootcfc#cf_support.services.app.cfml.helper.date"
        ) />
        
        <!--- CONCEAL MASTER ADMIN USERNAMES DISPLAY IN THE VIEW --->
        <cfset helper.admins = createObject(
            "component",
            "#application.webrootcfc#cf_support.services.app.cfml.helper.admins"
        ).init() />


    <!--- =========== --->
    <!---   ROUTING   --->
    <!--- =========== --->
    
        <!--- DEFINE DEFAULT CONTROLLER AND ACTION --->
        <cfparam name="url.controller" default="service" />
        <cfparam name="url.action" default="index" />


        <!--- DEFINE ACCEPTBLE ROUTES --->
        <cfset controllers = createObject("java", "java.util.LinkedHashMap").init() />
        <cfset controllers[ 'service' ] = { label = 'Service' } />
        

        <!--- CATCH UNACCEPTABLE CONTROLLER CALLS --->
        <cfif not isDefined("controllers.#url.controller#")>
            <cfset url.controller = "service" />
        </cfif>

                
        <!--- CALL CONTROLLER BASED ON URL PARAMS AND DEFINE
              "VIEW" SCOPE WHICH VARIABLES FROM THE CONTROLLER
              EXIST IN. --->
        <cfinvoke component="app.cfml.controller.#url.controller#"
                  method="#url.action#"
                  returnVariable="view" />

</cfsilent>
<cfoutput>

    <!--- =============== --->
    <!---   OUTPUT VIEW   --->
    <!--- =============== --->
    
        <!--- THE SPECIFIC VIEW TEMPLATE IS CALLED WITHIN LAYOUT.CFM --->
        <cfinclude template="app/cfml/view/layout.cfm" />

</cfoutput>
