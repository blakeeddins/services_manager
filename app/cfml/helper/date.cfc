<cfcomponent displayname="Date Helper">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /helper/date.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->



    <!--- ====================== --->
    <!---   LOCALIZE DATETIMES   --->
    <!--- ====================== --->
    
        <cffunction name="format" access="public" output="false" returnType="string">
            <cfargument name="datetime" required="true" type="string" />
            <cfargument name="format" required="false" type="string" default="mm/dd/yy" />
            <cfargument name="day_shift_direction" required="false" type="string" default="toLocal" />
            
            <cfif isDate(arguments.datetime)>
                
                <cfset local.return = arguments.datetime />
            
                <!--- LOCALIZE
                      [NOTE: 5/27/15 BY BLAKE
                             WE HAVE REMOVED LOCALIZATION AND ASK CLIENTS TO SCHEDULE
                             ACCORDING TO EST
                <cfset local.return = dateAdd(
                    "d",
                    serverToLocalDayShift(arguments.day_shift_direction),
                    arguments.datetime
                ) /> --->
                
                <!--- FORMAT --->
                <cfset local.return = dateFormat(local.return, arguments.format) />
                
            <cfelse>
            
                <cfset local.return = "" />
                
            </cfif>
        
            <cfreturn local.return />
        </cffunction>
        
        
    <!--- ============= --->
    <!---   DAY SHIFT   --->
    <!--- ============= --->
    
    <!--- USING APPLICATION.CFCTIMESHIFT.SERVERTOLOCAL() WAS CAUSING SCHEDULED DATES TO SHIFT
          INCORRECTLY IF THE TIME WAS SET TO 00:00:00.000 BECAUSE IT SHIFTS HOURS INSTEAD OF
          DAYS.  THIS WILL ONLY SHIFT DAYS --->
    
        <cffunction name="serverToLocalDayShift" access="public" output="false" returnType="string"
                    hint="Compares server to local time and adjusts the day if they don't match.">
            <cfargument name="direction" type="string" required="false" default="" />
        
            <!--- GET LOCAL CURRENT DAY --->
            <cfset local.current_time = dateFormat(
                application.cfcTimeShift.serverToLocal(now()),
                "d"
            ) />
            
            <!--- GET SERVER (EST) CURRENT DAY --->
            <cfset local.server_time = dateFormat(
                now(),
                "d"
            ) />
            
            <!--- GET DAY DIFFERNCE --->
            <cfswitch expression="#trim(arguments.direction)#">
                <cfcase value="toLocal">
                    <cfreturn local.current_time - local.server_time />
                </cfcase>
                <cfcase value="toServer">
                    <cfreturn local.server_time - local.current_time />
                </cfcase>
                <cfdefaultcase>
                    <cfreturn 0 />
                </cfdefaultcase>
            </cfswitch>
        
        </cffunction>
        
        
    <!--- ============ --->
    <!---   IS TODAY   --->
    <!--- ============ --->
    
        <cffunction name="isToday" access="public" output="false" returnType="boolean">
            <cfargument name="date" required="true" type="date" />
            
            <cfset local.date_formatted = dateFormat(arguments.date, "yyyy-mm-dd") />
            <cfset local.now_formatted = dateFormat(now(), "yyyy-mm-dd") />
            
            <cfif local.date_formatted eq local.now_formatted>
                <cfreturn true />
            <cfelse>
                <cfreturn false />
            </cfif>
        
        </cffunction>
        
</cfcomponent>