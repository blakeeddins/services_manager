(function($, undefined){
    
    /* ============================================================================================= */
    /* ============================================================================================= */
    /* =============================================================================================  /
    
    
            TITLE _____________ /service/form/fields.js
            AUTHORS ___________ Blake Eddins
    
    
    /  ============================================================================================= */
    /* ============================================================================================= */
    /* ============================================================================================= */


    /* SCOPE INSTANCE */
    var instance = {};
        
    /* =============== */
    /*   INIT FIELDS   */
    /* =============== */
    
        $(document).ready(function(){
            
            /* ADD ON CLOSE FUNCTIONALITY TO DATE PICKER */
            $('.save_button').click(
                instance.validate
            );
            
            /* ADD ON CHANGE FUNCTIONALITY TO TYPE SELECT */
            $('select[name="type"]').change(
                instance.loadTypeFields
            );
            
            /* LOAD FIELDS IF SERVICE TYPE IS LOADED WITH A VALUE */
            instance.loadTypeFields();

        });
        
        
        
    /* ==================== */
    /*   LOAD TYPE FIELDS   */
    /* ==================== */
    
        instance.loadTypeFields = function(){
        
            var local = {};
            
            /* GET AND FORMAT SERVICE TYPE TEXT */
            local.selected_type = $('select[name="type"] option:selected').text();
            local.selected_type = local.selected_type.split(' ').join('_').toLowerCase();
            
            /* GET FIELDS FOR THAT SERVICE TYPE */
            if(local.selected_type.length){            
                
                /* SHOW LOADER IMAGE */
                $('#service_type_fields').show();
                
                $.ajax({
                  url: "services/" + local.selected_type + "/view/fields.cfm",
                  data: properties,
                  type: "POST",
                  dataType: "html",
                  success: function(html){
                    $("#service_type_fields").html(html);
                    $(".hidden_on_load").show();

                    /* INIT OTHER DATE PICKERS */
                    $('#service_type_fields .date-picker').datepicker({
                        numberOfMonths: 3,
                        showButtonPanel: true,
                        showOn: "both",
                        buttonImage: siteurl + "/images/admin_ui/2.0/calendar.png",
                        dateFormat: "mm/dd/y"
                    });
                      
                    /* INIT UPDATE AVAILABLE SCHEDULED DATES FOR SIS FIELD */
                    instance.updateAvailableScheduledDates();

                    /* ADD TOGGLE TO OPTION BOX HINTS */
                    $('.optionBoxHintToggle').click(function(){
                        $(this).next('.optionBoxHint').toggle();
                        return false;
                    });
                      
                  },
                  error: function(){
                      $("#service_type_fields").html(
                        "<p class='loading'>There was an error loading service fields</p>"
                      );
                  }
                });
                
            }

        }
        
        
        
    /* ============ */
    /*   VALIDATE   */
    /* ============ */
    
        instance.validate = function(){
        
            var local = {};
            
            /* REMOVE ANY PREVIOUS VALIDATION FAILURES */
            $('.need_value').removeClass('need_value');
            
            /* ALL REQUIRED FIELDS NEED VALUES */
            local.missing_fields = [];
            
            $('.required').each(function(){
              
              local.required_field_value = $(this).next().find(':input').val();
              
              if(!local.required_field_value.length){
                  $(this).next().addClass('need_value');
                  local.missing_fields.push("<span> - " + $(this).text() + "</span>");
              }
              
            });    
            
            /* THROW ERROR IF SIS COMPLETION DATE IS AFTER SCHEDULED DATE */
            local.scheduled_date = $('input[name="scheduled_date"]').val();
            local.sis_completion_date = $('input[name="sis_rollover_completion_date"]').val();
            if(new Date(local.scheduled_date) < new Date(local.sis_completion_date)){
                
                /* DISPLAY ERROR MESSAGE */
                $('#app_response').html(
                      "Your Student Information Systems Rollover date is set to <span>" + local.sis_completion_date + ".</span><br />"
                    + "Your Scheduled Start Date for this Services is set to <span>" + local.scheduled_date + ".</span><br />"
                    + "<br />"
                    + "To ensure that old SIS data isn't synced back into our system after the service, we require the "
                    + "service date to be after your SIS Rollover Completion date.  Please choose a new Scheduled Date."
                );
                $('#app_response').addClass("exception");
                $('#app_response').removeClass('hide');
                $('html, body').animate({ scrollTop: 0 }, 'slow');
                
                return false;
            }
                        
            /* THROW ERROR IF FIELDS ARE MISSING */
            if(local.missing_fields.length){
                
                /* DISPLAY ERROR MESSAGE */
                $('#app_response').html(
                      "The following required fields are empty: <br />"
                    + "<br />"
                    + local.missing_fields.join('<br />')
                );
                $('#app_response').addClass("exception");
                $('#app_response').removeClass('hide');
                $('html, body').animate({ scrollTop: 0 }, 'slow');
                
                return false;
                
            }
            
        }
        
        
        
    /* ==================================== */
    /*   UPDATE AVAILABLE SCHEDULED DATES   */
    /* ==================================== */
        
        instance.updateAvailableScheduledDates = function(){
        
            var local = {};
            
            /* MAKES IT SO A FINALSITE ROLLOVER CAN'T BE SCHEDULED
               BEFORE THE SIS COMPLETION DATE */
            $('input[name="sis_rollover_completion_date"]').datepicker(
                  "option"
                , "onClose"
                , function(){
                    
                    var local = {};
                        local.sis_completion_date = new Date($(this).val());
                    
                    if(!isNaN(local.sis_completion_date.valueOf())){
                        datepicker.sis_completion_date = local.sis_completion_date;
                    }
                }
            );
        
        }

})(jQuery);