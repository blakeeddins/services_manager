<cfcomponent displayname="String Helper">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /helper/string.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->



    <!--- =============================== --->
    <!---   FORMAT LINE BREAKS FOR HTML   --->
    <!--- =============================== --->
            
    <!--- BUILD IN COLDFUSION FUNCTION paragraphFormat() TURNS SINGLE LINE 
          BREAKS INTO SPACES FOR SOME STUPID REASON.  THIS CORRECTS THAT --->
    
        <cffunction name="formatLineBreaks" access="public" output="false" returnType="string">
            <cfargument name="string" required="true" type="string" />
                  
            <!--- MAKE MAC AND WINDOWS LINE BREAKS STYLE CONSISTENT --->
            <cfset local.return = replace(arguments.string, chr(13)&chr(10), chr(10), "ALL") />
            <cfset local.return = replace(local.return, chr(13), chr(10), "ALL") />
            
            <!--- REPLACE LINE BREAKS WITH BREAK TAGS --->
            <cfset local.return = replace(local.return, chr(10), "<br />", "ALL") />
        
            <cfreturn local.return />
        </cffunction>
        
</cfcomponent>