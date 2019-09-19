<cfoutput>

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /services/end_of_year/view/fields.cfm
              AUTHORS ___________ Blake Eddins

    
    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    
    <!--- ================== --->
    <!---   HELPER CLASSES   --->
    <!--- ================== --->
    
        <!--- DEFINE THESE CLASSES TO BE USED BY THE VIEW
              TO PERFORM CERTAIN REPEATABLE FUNCTIONS --->
              
        <cfset helper = StructNew() />

        <!--- ADJUST THE WAY DATES DISPLAY IN THE VIEW --->
        <cfset helper.date = createObject(
            "component",
            "#application.webrootcfc#cf_support.services.app.cfml.helper.date"
        ) />
    
        
        
    <!--- ====================== --->
    <!---   GET SERVICE FIELDS   --->
    <!--- ====================== --->
    
        <cfinvoke component="#application.webrootcfc#cf_support.services.services.end_of_year.model.fields"
                  method="read"
                  returnVariable="service_fields" />
        
        
    <!--- ========== --->
    <!---   OUTPUT   --->
    <!--- ========== --->
    
        <!--- DEFINE FIELD ORDER LIST --->
        <cfset field_order_list = "" />
    
        <cfloop query="service_fields">
        
            <!--- MARK REQUIRED FIELDS AS SUCH --->
            <cfset required_class = "" />
            <cfif service_fields.required>
                <cfset required_class = "required" />
            </cfif>
            
            <cfif service_fields.type eq "header">
            
                <div class="subGroupTitle">#service_fields.label#</div>
            
            <cfelse>

                <div class="optionBox">
                    <div class="optionBoxTitle #required_class#">#service_fields.label#</div>
                    <div class="optionBoxGroup">

                        <!--- DEFINE DEFAULT VALUE OF FIELD --->
                        <cfparam name="form.#service_fields.name#" default="#service_fields.default_value#" />

                        <!--- ============================= --->
                        <!---   ! SWITCH THE INPUT TYPE !   --->
                        <!--- ============================= --->
                        <cfswitch expression="#trim(service_fields.type)#">

                            <cfcase value="select">
                                <select name="#service_fields.name#">

                                    <!--- GET FIELD OPTIONS --->
                                    <cfinvoke component="#application.webrootcfc#cf_support.services.services.end_of_year.model.fields"
                                              method="readOptions"
                                              field_id="#service_fields.id#"
                                              returnVariable="service_fields_options" />

                                    <cfloop query="service_fields_options">

                                        <!--- MARK SELECTED IF WE HAVE A MATCH --->
                                        <cfif form[service_fields.name] eq service_fields_options.value>
                                            <cfset selected = "selected='selected'" />
                                        <cfelse>
                                            <cfset selected = "" />
                                        </cfif>

                                        <option value="#service_fields_options.value#" #selected#>
                                            #service_fields_options.name#
                                        </option>
                                    </cfloop>

                                </select>

                            </cfcase>

                            <cfcase value="textarea">
                                <textarea name="#service_fields.name#"
                                          placeholder="#service_fields.placeholder#"
                                >#form[service_fields.name]#</textarea>
                            </cfcase>
                                
                            <cfcase value="checkbox">

                                    <!--- GET FIELD OPTIONS --->
                                    <cfinvoke component="#application.webrootcfc#cf_support.services.services.end_of_year.model.fields"
                                              method="readOptions"
                                              field_id="#service_fields.id#"
                                              returnVariable="service_fields_options" />

                                    <cfloop query="service_fields_options">

                                        <!--- MARK SELECTED IF WE HAVE A MATCH --->
                                        <cfif listFindNoCase(form[service_fields.name], service_fields_options.value)>
                                            <cfset selected = "checked='checked'" />
                                        <cfelse>
                                            <cfset selected = "" />
                                        </cfif>

                                        <div class="checkbox">
                                            <input name="#service_fields.name#"
                                                   type="checkbox"
                                                   value="#service_fields_options.value#"
                                                   #selected# />
                                            #service_fields_options.name#
                                        </div>
                                    </cfloop>
                            </cfcase>
                                
                            <cfcase value="date">
                                <input name="#service_fields.name#"
                                       type="text"
                                       class="date-picker"
                                       value="#helper.date.format(form[service_fields.name])#"
                                       placeholder="#service_fields.placeholder#"
                                       readonly="readonly" />
                            </cfcase>

                            <cfdefaultcase>
                                <input name="#service_fields.name#"
                                       type="text"
                                       maxlength="#service_fields.maxlength#"
                                       value="#form[service_fields.name]#"
                                       placeholder="#service_fields.placeholder#" />
                            </cfdefaultcase>

                        </cfswitch>
                        <!--- ============================= --->
                        <!---   ! SWITCH THE INPUT TYPE !   --->
                        <!--- ============================= --->
                            
                        
                        <!--- DISPLAY HINT ICON IF AVAILABLE --->
                        <cfif len(service_fields.hint)>
                            <a href="##" class="optionBoxHintToggle">Hint</a>
                            <div class="optionBoxHint">#service_fields.hint#</div>
                        </cfif>

                    </div>
                </div>

                <!--- ADD EACH FIELD TO FIELD ORDER LIST --->
                <cfset field_order_list = listAppend(field_order_list, service_fields.name) />
                
            </cfif>
        
        </cfloop>
        
        <!--- ORDER THAT THE FIELDS SHOULD APPEAR IN THE "DETAILS" VIEW --->
        <input name="field_order" type="hidden" value="#field_order_list#" />

</cfoutput>