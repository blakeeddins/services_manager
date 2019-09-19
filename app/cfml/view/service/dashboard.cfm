<cfoutput>

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >


              TITLE _____________ /view/service/dashboard.cfm
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->


    <!--- ======================= --->
    <!---   MASTER INCLUDE FILE   --->
    <!--- ======================= --->

        <cfinclude template="../_include.cfm" />

    <!--- ================================================ --->
    <!---   LOOP THROUGH FIND QUERY AND BUILD TABLE ROWS   --->
    <!--- ================================================ --->

        <cfset saved = "" />
        <cfset scheduled = "" />
        <cfset completed = "" />

        <cfloop query="#view.service#">

            <!--- DEFINE SERVICE PROPERTIES --->
            <cfset deserialized = StructNew() />
            <cfset deserialized.service = deserializeJSON(properties) />

            <cfparam name="uuid" default="" />
            <cfparam name="deserialized.service.summary" default="[Missing Summary]" />
            <cfparam name="type_name" default="[Missing Type]" />
            <cfparam name="updated_user" default="[Missing User]" />
            <cfparam name="updated_date" default="[Missing Date]" />
            <cfparam name="scheduled_user" default="" />
            <cfparam name="scheduled_date" default="" />
            <cfparam name="serviced_user" default="" />
            <cfparam name="serviced_date" default="" />

            <!--- SHARED FIELDS NO MATTER THE SERVICE STATUS --->
            <cfsavecontent variable="shared_fields">
                <td class="manage_button_field">
                    <a href="?controller=service&action=manage&uuid=#uuid#" class="iconLink iconBtnManage">Manage</a>
                </td>
                <td class="summary_field">#deserialized.service.summary#</td>
                <!---<td class="type_field">#type_name#</td>--->
            </cfsavecontent>

            <!--- ADD SERVICE TO COMPLETED TABLE --->
            <cfif len(serviced_date)>

                <!--- ADD SPECIAL CLASS IS SERVICE WAS COMPLETED TODAY --->
                <cfif helper.date.isToday(serviced_date)>
                    <cfset today_class = "today" />
                <cfelse>
                    <cfset today_class = "not_today" />
                </cfif>

                <cfsavecontent variable="table_row">
                    <tr>
                        #shared_fields#
                        <td class="scheduled_user_field center_field">#helper.admins.masterUsernameFormat(scheduled_user)#</td>
                        <td class="scheduled_date_field center_field">#helper.date.format(scheduled_date)#</td>
                        <td class="serviced_user_field center_field">#helper.admins.masterUsernameFormat(serviced_user)#</td>
                        <td class="serviced_date_field center_field #today_class#">#helper.date.format(serviced_date)#</td>
                    </tr>
                </cfsavecontent>

                <cfset completed = completed & table_row />


            <cfelseif len(scheduled_date)>

                <!--- ADD SPECIAL CLASS IS SERVICE WAS SCHEDULED TODAY --->
                <cfif helper.date.isToday(scheduled_date)>
                    <cfset today_class_scheduled = "today" />
                <cfelse>
                    <cfset today_class_scheduled = "not_today" />
                </cfif>

                <!--- ADD SPECIAL CLASS IS SERVICE WAS SCHEDULED TODAY --->
                <cfif helper.date.isToday(updated_date)>
                    <cfset today_class_updated = "today" />
                <cfelse>
                    <cfset today_class_updated = "not_today" />
                </cfif>

                <cfsavecontent variable="table_row">
                    <tr>
                        #shared_fields#
                        <td class="updated_user_field center_field">#helper.admins.masterUsernameFormat(updated_user)#</td>
                        <td class="updated_date_field center_field #today_class_updated#">#helper.date.format(updated_date)#</td>
                        <td class="scheduled_user_field center_field">#helper.admins.masterUsernameFormat(scheduled_user)#</td>
                        <td class="scheduled_date_field center_field #today_class_scheduled#">#helper.date.format(scheduled_date)#</td>
                    </tr>
                </cfsavecontent>

                <cfset scheduled = scheduled & table_row />


            <cfelse>

                <!--- ADD SPECIAL CLASS IS SERVICE WAS SCHEDULED TODAY --->
                <cfif helper.date.isToday(updated_date)>
                    <cfset today_class = "today" />
                <cfelse>
                    <cfset today_class = "not_today" />
                </cfif>

                <cfsavecontent variable="table_row">
                    <tr>
                        #shared_fields#
                        <td class="updated_user_field center_field">#helper.admins.masterUsernameFormat(updated_user)#</td>
                        <td class="updated_date_field center_field #today_class#">#helper.date.format(updated_date)#</td>
                        <td class="scheduled_user_field center_field">#helper.admins.masterUsernameFormat(scheduled_user)#</td>
                        <td class="scheduled_date_field center_field">#helper.date.format(scheduled_date)#</td>
                    </tr>
                </cfsavecontent>

                <cfset saved = saved & table_row />
            </cfif>

        </cfloop>


    <!--- ========== --->
    <!---   OUTPUT   --->
    <!--- ========== --->

        <div class="mainGroup">

            <div class="mainGroupTitle">Services Manager Maintenance</div>

            <div class="subGroup">
                <br>
                We are currently accepting End-of-Year (EoY) Service requests via our support ticketing system for the upcoming academic year.<br>

                The service will be performed on the date that you choose. There are a limited number of slots available each day we perform these services, so you'll want to sign up as soon as possible if you need the update performed by a specific date! <br><br>

                <a href="../zendesk.cfm?newTicket=ticket">Click Here</a> to open up a new Support Ticket, and specify “End of Year Service” in the ticket options.<br><br>

                <a href="https://www.finalsitesupport.com/hc/en-us/articles/115001010627">Click here</a> for additional information about what the End of Year Service process entails. <br><br>

                <a href="https://www.finalsitesupport.com/hc/en-us/articles/115000097912">Click here</a> for more details about End of Year Services for schools using Finalsite Learn Enhanced (Gradebook and Reports).  <br><br>
            </div>

        </div>

        <!---

        <div class="mainGroup">

            <div class="mainGroupTitle">New Service</div>

            <div class="subGroup">
                <a href="?controller=service&action=new" class="iconLink iconBtnAdd">New Service</a>
            </div>

        </div>

        <!--- SAVED --->
        <div id="saved_services" class="mainGroup">

            <div class="mainGroupTitle">Saved Services</div>

            <div class="subGroup">

                <cfif len(saved)>

                    <table class="itemList">
                        <tr>
                            <th>Action</th>
                            <th>Summary</th>
                            <!---<th>Type</th>--->
                            <th class="center_field">Updated By</th>
                            <th class="center_field">Updated Date</th>
                            <th class="center_field">Scheduled By</th>
                            <th class="center_field">Scheduled Date</th>
                        </tr>

                        <!--- DISPLAY TABLE ROWS --->
                        #saved#

                    </table>

                <cfelse>

                    <p>No saved services</p>

                </cfif>

            </div>

        </div>


        <!--- SCHEDULED --->
        <div id="scheduled_services" class="mainGroup">

            <div class="mainGroupTitle">Scheduled Services</div>

            <div class="subGroup">

                <cfif len(scheduled)>

                    <table class="itemList">
                        <tr>
                            <th>Action</th>
                            <th>Summary</th>
                            <!---<th>Type</th>--->
                            <th class="center_field">Updated By</th>
                            <th class="center_field">Updated Date</th>
                            <th class="center_field">Scheduled By</th>
                            <th class="center_field">Scheduled Date</th>
                        </tr>

                        <!--- DISPLAY TABLE ROWS --->
                        #scheduled#

                    </table>

                <cfelse>

                    <p>No scheduled services</p>

                </cfif>


            </div>

        </div>


        <!--- COMPLETED --->
        <div id="completed_services" class="mainGroup">

            <div class="mainGroupTitle">Completed Services</div>

            <div class="subGroup">

                <cfif len(completed)>

                    <table class="itemList">
                        <tr>
                            <th>Action</th>
                            <th>Summary</th>
                            <!---<th>Type</th>--->
                            <th class="center_field">Scheduled By</th>
                            <th class="center_field">Scheduled Date</th>
                            <th class="center_field">Serviced By</th>
                            <th class="center_field">Serviced Date</th>
                        </tr>

                        <!--- DISPLAY TABLE ROWS --->
                        #completed#

                    </table>

                <cfelse>

                    <p>No completed services</p>

                </cfif>

            </div>

        </div>

    --->

</cfoutput>