<cfoutput>

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >


              TITLE _____________ /view/service/form.cfm
              AUTHORS ___________ Blake Eddins


    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->


    <!--- ======================= --->
    <!---   MASTER INCLUDE FILE   --->
    <!--- ======================= --->

        <cfinclude template="../_include.cfm" />


    <!--- =========== --->
    <!---   SCRIPTS   --->
    <!--- =========== --->

        <!--- JAVASCRIPT: jQUERY UI DATE PICKER
              scriptType: {1-keyword,2-path,3-js block} --->
        <cfset application.cfcIncludeScript.addScript(
            script = "app/js/service/form/datepicker.js",
            scriptType = 2
        ) />

        <!--- JAVASCRIPT: SERVICE QUEUE AJAX
              scriptType: {1-keyword,2-path,3-js block} --->
        <cfset application.cfcIncludeScript.addScript(
            script = "app/js/service/form/service_queue.js",
            scriptType = 2
        ) />

        <!--- JAVASCRIPT: FIELDS
              scriptType: {1-keyword,2-path,3-js block} --->
        <cfset application.cfcIncludeScript.addScript(
            script = "app/js/service/form/fields.js",
            scriptType = 2
        ) />

    <!--- ===================== --->
    <!---   DEFINE PARAMETERS   --->
    <!--- ===================== --->

        <cfparam name="view.service.type_id" default="1" />
        <cfparam name="view.service.uuid" default="#createUUID()#" />
        <cfparam name="view.service.scheduled_user" default="" />
        <cfparam name="view.service.scheduled_date" default="" />
        <cfparam name="view.service.properties" default="{}" />


    <!--- =========================================== --->
    <!---   DEFINE SERVICE PROPERTIES IN JAVASCRIPT   --->
    <!--- =========================================== --->

        <!--- WE DEFINE IN JAVASCRIPT TO DYNAMICALLY LOAD PRE-FILLED FIELDS --->
        <script>
            properties = #view.service.properties#;
        </script>


    <!--- ========== --->
    <!---   OUTPUT   --->
    <!--- ========== --->

        <div class="mainGroup">

            <div class="mainGroupTitle">#view.action_name# Service</div>

            <form action="?view=service&action=save" method="post">

                <div class="subGroup">

                    <!--- TYPE FIELD --->

                    <!--- CURRENTLY WE ONLY OFFER ONE SERVICE, SO WE JUST DEFAULT TO THAT SERVICE ABOVE
                          SERVICE TYPE CFPARAM --->
                    <div class="optionBox hidden">
                        <div class="optionBoxTitle required">TYPE</div>
                        <div class="optionBoxGroup">
                            <select name="type">
                                <option/></option>

                                <!--- LOOP THROUGH ALL SERVICE TYPES --->
                                <cfloop query="view.service_type">
                                    <option
                                        <cfif id eq view.service.type_id>
                                            selected="selected"
                                        </cfif>
                                     value="#id#|#minutes_to_complete#">#name#</option>
                                </cfloop>

                            </select>
                        </div>
                    </div>

                    <!--- ================================ --->
                    <!---   ! AJAX SERVICE TYPE FIELDS !   --->
                    <!--- ================================ --->

                    <!--- Javascript used to load these fields dynamically is in
                          /app/js/service/form/fields.js. --->
                    <div id="service_type_fields" class="hidden_on_load">
                        <p class="loading">
                            ...loading fields...<br />
                            <img src="#REQUEST.baseImagesURL#loadingbar.gif" title="loading" />
                        </p>
                    </div>

                    <!--- ================================ --->
                    <!---   ! AJAX SERVICE TYPE FIELDS !   --->
                    <!--- ================================ --->

                    <!--- SCHEDULED FIELD --->
                    <div class="optionBox hidden_on_load">
                        <div class="optionBoxTitle">PICK AN AVAILABLE START DATE</div>
                        <div class="optionBoxGroup">
                            <input name="scheduled_date"
                                   type="text"
                                   class="date-picker"
                                   value="#helper.date.format(view.service.scheduled_date)#"
                                   placeholder="mm/dd/yy"
                                   readonly="readonly" />


                        <a href="##" class="optionBoxHintToggle">Hint</a>
                        <div class="optionBoxHint">All chosen dates are based on Eastern Standard Time.
                            Dates which are unselectable are unavailable.  This can be because of a company
                            holiday or because capacity has already been filled with other client requests for that date.</div>
                        </div>
                    </div>

                    <!--- HIDDEN FORM FIELDS --->
                    <input type="hidden" name="uuid" value="#view.service.uuid#"  />

                </div>

                <div class="subGroup form_buttons hidden_on_load">
                    <input class="save_button" type="submit" name="action" value="Save #view.action_name#" />
                    <a href="?controller=service&action=index" class="iconLink iconBtnCancel">Cancel</a>
                </div>

            </form>

        </div>

</cfoutput>