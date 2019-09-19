<cfcomponent displayname="Fields Model">

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /services/end_of_year/model/fields.cfc
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    
    
    
    <!--- DEFINE DATABASE AND TABLES --->
    <cfset variables.fields_database = "rss" />
    <cfset variables.fields_table = "support_services_fields" />
    <cfset variables.join_types_fields_table = "support_services_types_n_fields" />
    <cfset variables.options_table = "support_services_fields_options" />
    <cfset variables.join_fields_options_table = "support_services_fields_n_fields_options" />
    
    
    <!--- DEFINE SERVICE TYPE ID --->
    <cfset this.type_id = 1 />

                           
                           
    <!--- ======== --->
    <!---   READ   --->
    <!--- ======== --->              
                           
        <cffunction name="read" access="public" output="false" returnType="query">

            <cfquery name="local.return" dataSource="#variables.fields_database#">
                SELECT f.id, f.label, f.name, f.type, f.maxlength, f.placeholder, f.default_value, f.required, f.hint
                FROM #variables.join_types_fields_table# AS t
                LEFT JOIN #variables.fields_table# AS f
                    ON t.field_id = f.id
                WHERE (t.type_id = 1)
                ORDER BY t.field_order
            </cfquery>
        
            <cfreturn local.return />
        </cffunction>
        
        
    <!--- ================ --->
    <!---   READ OPTIONS   --->
    <!--- ================ --->
    
        <cffunction name="readOptions" access="public" output="false" returnType="query">
            <cfargument name="field_id" type="numeric" required="true" />
            
            <cfquery name="local.return" dataSource="#variables.fields_database#">
                SELECT o.name, o.value
                FROM #variables.join_fields_options_table# AS f
                LEFT JOIN #variables.options_table# AS o
                    ON f.field_option_id = o.id
                WHERE (f.field_id = #val(arguments.field_id)#)
                ORDER BY f.field_option_order
            </cfquery>
        
            <cfreturn local.return />
        </cffunction>

</cfcomponent>