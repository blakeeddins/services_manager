<cfsilent>

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ _include.cfm
              AUTHORS ___________ Blake Eddins
    
              RESPONSIBILITY ____ Use this include store any logic that is common to all includes
                                  utilized by the app.
                              
                                  The master include should be added to the beginning of all other
                                  include files with the suggested format:
                              
                                  <!--- ======================= --->
                                  <!---   MASTER INCLUDE FILE   --->
                                  <!--- ======================= --->
    
                                      <cfinclude template="_include.cfm" />
    
    
    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->

    <!--- PREVENT INCLUDES FROM BEING ACCESSED ANY WAY OTHER THAN THROUGH THE APPS
          INDEX.CFM VIEW.  THE VARIABLE "inAdmin" IS DEFINED AT THE TOP OF INDEX.CFM --->

    <cfif not isdefined("inAdmin")>
        <cflocation url="/#APPLICATION.webroot#cf_support/services/" addToken="false" />
    </cfif>
 
</cfsilent>