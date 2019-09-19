<cfoutput>

    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== -- >
    
    
              TITLE _____________ /view/service/details.cfm
              AUTHORS ___________ Blake Eddins

    
    < --- ======================================================================================== --->
    <!--- ======================================================================================== --->
    <!--- ======================================================================================== --->


    <!--- ======================= --->
    <!---   MASTER INCLUDE FILE   --->
    <!--- ======================= --->
    
        <cfinclude template="../_include.cfm" />
        
        
    <!--- ============================= --->
    <!---   DEFINE SERVICE PROPERTIES   --->
    <!--- ============================= --->
    
        <cfset deserialzied = StructNew() />
        <cfset deserialized.service = deserializeJSON(view.service.properties) />
        
        
    <!--- ========== --->
    <!---   OUTPUT   --->
    <!--- ========== --->
        
        <div class="mainGroup">
        
            <div class="mainGroupTitle">#view.action_name# Service</div>
                
                <div class="subGroup">
                    
                    <!--- TYPE --->
                    <div class="optionBox">
                        <div class="optionBoxTitle">TYPE</div>
                        <div class="optionBoxGroup">#view.service.type_name#</div>
                    </div>
                    
                    <!--- ================== --->
                    <!---   ! FIELD LOOP !   --->
                    <!--- ================== --->
                    
                        <cfif StructKeyExists(deserialized.service, "field_order")>
                        
                            <cfloop list="#deserialized.service.field_order#" index="field">
                            
                                <!--- FORMAT FIELD LABEL --->
                                <cfset label = uCase(replace(field, "_", " ", "all")) />
                            
                                <div class="optionBox">
                                    <div class="optionBoxTitle">#label#</div>
                                    <div class="optionBoxGroup">
                                        <cfif StructKeyExists(deserialized.service, field)>
                                            #helper.string.formatLineBreaks(deserialized.service[field])#
                                        </cfif>
                                    </div>
                                </div>

                            </cfloop>
                        
                        </cfif>
                    
                    <!--- ================== --->
                    <!---   ! FIELD LOOP !   --->
                    <!--- ================== --->
                    
                    <!--- UPDATED --->
                    <div class="optionBox">
                        <div class="optionBoxTitle">UPDATED</div>
                        <div class="optionBoxGroup">
                            <span class="date">#helper.date.format(view.service.updated_date)#</span>
                            by <span class="user">#helper.admins.masterUsernameFormat(view.service.updated_user)#</span>
                        </div>
                    </div>         
                    
                    <!--- SCHEDULED --->
                    <div class="optionBox">
                        <div class="optionBoxTitle">SCHEDULED</div>
                        <div class="optionBoxGroup">
                        
                        <cfif len(view.service.scheduled_user)
                          and isDate(view.service.scheduled_date)>
                            <span class="date">#helper.date.format(view.service.scheduled_date)#</span>
                            by <span class="user">#helper.admins.masterUsernameFormat(view.service.scheduled_user)#</span>
                        <cfelse>
                            Not yet scheduled
                        </cfif>
                            
                        </div>
                    </div>
                    
                    <!--- SERVICED --->
                    <div class="optionBox">
                        <div class="optionBoxTitle">SERVICED</div>
                        <div class="optionBoxGroup">
                        
                        <cfif len(view.service.serviced_user)
                          and isDate(view.service.serviced_date)>
                            <span class="date">#helper.date.format(view.service.serviced_date)#</span>
                            by <span class="user">#helper.admins.masterUsernameFormat(view.service.serviced_user)#</span>
                        <cfelse>
                            Not yet serviced
                        </cfif>
                            
                        </div>
                    </div>
                    
                    <!--- PARATURE TICKET --->
                    <cfif len(view.service.parature_ticket)>
                        <div class="optionBox">
                            <div class="optionBoxTitle">PARATURE TICKET</div>
                            <div class="optionBoxGroup">#view.service.parature_ticket#</div>
                        </div>
                    </cfif>           
                    
                </div>
                
                <div class="subGroup form_buttons">
                
                <!--- MARK COMPLETE BUTTON FOR MASTER ADMINS ONLY --->
                <cfif session.admingroup eq 1
                  and len(view.service.parature_ticket)
                  and not isDate(view.service.serviced_date)>
                
                    <a href="?controller=service&action=complete&uuid=#view.service.uuid#" class="iconLink iconBtnAdd">Complete</a>
                
                </cfif>
                    
                <!--- CAN'T EDIT SERVICE THAT HAS BEEN COMPLETED
                      OR HAS HAD A PARATURE TICKET CREATED FOR IT --->
                <cfif isDate(view.service.serviced_date)>
                
                    <a href="?controller=service&action=clone&uuid=#view.service.uuid#" class="iconLink iconBtnCopy">Clone</a>
                    
                </cfif>
                    
                <cfif not len(view.service.parature_ticket)
                       or session.admingroup eq 1>
                
                    <a href="?controller=service&action=edit&uuid=#view.service.uuid#" class="iconLink iconBtnEdit">Edit</a>
                    <a href="?controller=service&action=delete&uuid=#view.service.uuid#" class="iconLink iconBtnDelete">Delete</a>

                </cfif>

                    <a href="?controller=service&action=index" class="iconLink iconBtnCancel">Cancel</a>
                
                </div>
            
            </form>  
        
        </div>

</cfoutput>