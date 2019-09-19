<cfcomponent displayname="Controller">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >


              TITLE _____________ /controller/controller.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->



    <!--- ===================== --->
    <!---   ON MISSING METHOD   --->
    <!--- ===================== --->

        <cffunction name="OnMissingMethod" access="public" output="true" returntype="any"
                    hint="Handles missing method exceptions.">

            <cfargument name="missingMethodName" type="string" required="true" />
            <cfargument name="missingMethodArguments" type="struct" required="true" />

            <!--- IF ACTION IS MISSING, CALL INDEX AND PASS EXCEPTION RESPONSE --->
            <cfset local.return = index() />

            <cfset local.return.response = this.exception("action not found") />

            <cfreturn local.return />
        </cffunction>



    <!--- ========= --->
    <!---   INDEX   --->
    <!--- ========= --->

        <cffunction name="index" access="public" output="false" returnType="void">
            <!--- DEFAULT ACTION ON ERROR.  SPECIFIC CONTROLLERS MAY HAVE SPECIFIC
                  INDEX ACTIONS WHICH OVERRIDE THIS ONE. --->
            <cflocation url="#REQUEST.baseSSLURL#/cf_support/services/" addToken="false" />
        </cffunction>

    <!--- ==================== --->
    <!---   SUCCESS RESPONSE   --->
    <!--- ==================== --->

        <cffunction name="success" access="public" output="false" returnType="struct">
            <cfargument name="type" required="false" type="string" default="" />

            <cfset local.return.type = "success" />

            <cfswitch expression="#trim(arguments.type)#">
                <cfcase value="saved">
                    <cfset local.return.text = "The service was successfully saved!" />
                </cfcase>
                <cfcase value="deleted">
                    <cfset local.return.text = "The service was successfully deleted!" />
                </cfcase>
                <cfcase value="completed">
                    <cfset local.return.text = "The service was successfully completed!" />
                </cfcase>
                <cfdefaultcase>
                    <cfset local.return.text = "Success!" />
                </cfdefaultcase>
            </cfswitch>

            <cfreturn local.return />
        </cffunction>

    <!--- ==================== --->
    <!---   WARNING RESPONSE   --->
    <!--- ==================== --->

        <cffunction name="warning" access="public" output="false" returnType="struct">
            <cfargument name="type" required="false" type="string" default="" />

            <cfset local.return.type = "warning" />

            <cfswitch expression="#trim(arguments.type)#">
                <cfcase value="reserved date">
                    <cfset local.return.text = "Please review your answers, then click the ""Save"" button below to schedule the service." />
                </cfcase>
                <cfdefaultcase>
                    <cfset local.return.text = "Warning!" />
                </cfdefaultcase>
            </cfswitch>

            <cfreturn local.return />
        </cffunction>


    <!--- ====================== --->
    <!---   EXCEPTION RESPONSE   --->
    <!--- ====================== --->

        <cffunction name="exception" access="public" output="false" returnType="struct">
            <cfargument name="type" required="false" type="string" default="" />

            <cfset local.return.type = "exception" />

            <cfswitch expression="#trim(arguments.type)#">
                <cfcase value="reserved date">
                    <cfset local.return.text = "There was an exception and the date could not be reserved!  Try again later." />
                </cfcase>
                <cfcase value="saved">
                    <cfset local.return.text = "There was an issue and the service was not saved!  Try again later." />
                </cfcase>
                <cfcase value="does not exist">
                    <cfset local.return.text = "Service #url.uuid# doesn't exist!" />
                </cfcase>
                <cfcase value="edited">
                    <cfset local.return.text = "This service is associated with a Parature ticket and cannot be edited." />
                </cfcase>
                <cfcase value="deleted">
                    <cfset local.return.text = "This service is associated with a Parature ticket and cannot be deleted." />
                </cfcase>
                <cfcase value="completed">
                    <cfset local.return.text = "At this time the 'complete' action is restricted to Finalsite employees only" />
                </cfcase>
                <cfcase value="action not found">
                    <cfset local.return.text = "The requested action was not found." />
                </cfcase>
                <cfdefaultcase>
                    <cfset local.return.text = "Error!" />
                </cfdefaultcase>
            </cfswitch>

            <cfreturn local.return />
        </cffunction>

</cfcomponent>