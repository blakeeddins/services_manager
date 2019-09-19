<cfoutput>

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /view/layout.cfm
              AUTHORS ___________ Blake Eddins

    
    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    
    
    <!--- ======================= --->
    <!---   MASTER INCLUDE FILE   --->
    <!--- ======================= --->
    
        <cfinclude template="_include.cfm" />
        
        
    <!--- ========== --->
    <!---   OUTPUT   --->
    <!--- ========== --->

        <!DOCTYPE html>
        <html lang="en">
        
            <head>
            
                <title>Support Services Manager</title>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            	<meta http-equiv="X-UA-Compatible" content="IE=Edge">
                    
                <!--- JAVASCRIPT: FINALSITE ADMIN SCRIPTS --->
                <cfset application.cfcIncludeScript.addScripts(
                    scriptNames = "jQuery,jQueryUI_Custom,global_admin"
                ) />
                
            
                <!--- CSS: FINALSITE ADMIN STYLESHEETS --->               
                <cfset application.cfcIncludeScript.addCSS(
                    theCSS = "#REQUEST.baseCSSURL#admin_ui/2.0/main.css"
                ) />
                
            
            
                <!--- CSS: SERVICE INDEX STYLESHEETS --->
                <cfset application.cfcIncludeScript.addCSS(
                    theCSS = "app/css/layout.css"
                ) />
                
            </head>
            <body>

            
                <!--- ============== --->
                <!---   NAVIGATION   --->
                <!--- ============== --->      
                <div id="subBar">
                    <ul>
                    
                    <!--- CONTROLLERS IS DEFINED IN /INDEX.CFM --->
            		<cfloop collection="#controllers#" item="controller">
            		
            		    <cfset nav_class = controller />
            		    
            		    <cfif listFindNoCase(view.path, controller, "/")>
            		        <cfset nav_class = "#nav_class# on" />
            		    </cfif>
            		
                        <li class="#controller#">
            			    <a href="?controller=#controller#&action=index" class="#nav_class#">#controllers[controller].label#</a>
                        </li>
                        
            		</cfloop>
            		
                    </ul>
                    
                </div>

            
                <!--- ================ --->
                <!---   APP RESPONSE   --->
                <!--- ================ --->
            
                <!--- DEFINE APP RESPONSE --->
                <cfparam name="view.response.type" default="hide" />
                <cfparam name="view.response.text" default="Everything's Good Here!" />
                
                <div id="app_response" class="mainGroup #view.response.type#">#view.response.text#</div>

                
                <!--- =========== --->
                <!---   CONTENT   --->
                <!--- =========== --->
                <div class="frame">
                    
                    <!--- VIEW --->
                    <cfinclude template="#view.path#" />

                </div>
                
                <!--- =========== --->
                <!---   SCRIPTS   --->
                <!--- =========== --->
                <cfset application.cfcIncludeScript.output()>
                
            </body>
        
        </html>
            
</cfoutput>