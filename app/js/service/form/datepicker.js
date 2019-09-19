(function($, undefined){
    
    /* ============================================================================================= */
    /* ============================================================================================= */
    /* =============================================================================================  /
    
    
            TITLE _____________ /service/form/datepicker.js
            AUTHORS ___________ Blake Eddins
    
    
    /  ============================================================================================= */
    /* ============================================================================================= */
    /* ============================================================================================= */
    
    /* SCOPE PUBLIC */
    datepicker = {};


    /* SCOPE PRIVATE */
    var instance = {};
    
    /* DEFINE SIS COMPLETION DATE */
    datepicker.sis_completion_date = new Date();
    

    /* ========================= */
    /*   CONSTRUCT DATE PICKER   */
    /* ========================= */
        
        $(document).ready(function(){
            
            /* PRELOAD DISABLED DATES */
            instance.disabled_dates = instance.getDisabledDates();
    
            /* jQUERY UI DATE PICKER */
            $('input[name="scheduled_date"]').datepicker({
                numberOfMonths: 3,
                showButtonPanel: true,
                showOn: "both",
                buttonImage: siteurl + "/images/admin_ui/2.0/calendar.png",
                dateFormat: "mm/dd/y",
                beforeShowDay: instance.beforeShowDay
            });
        
        });


    /* ====================== */
    /*   GET DISABLED DATES   */
    /* ====================== */
        
        instance.getDisabledDates = function(){
        
            var local = {};
        
            /* DISABLE DATE SETTING IF ERROR IS RETURNED FROM SERVER */
            try{
                $.ajax({
                    url: "../services/app/cfml/controller/service_queue.cfc?"
                       + "method=indexRemote",
                    async: false,
                    success: function(data){
                        local.return = $.parseJSON(data);
                    }
                });
            }
            catch(err){
                local.return = "error";
            };
            
            return local.return;
        }
        

    /* ==================== */
    /*   IS DISABLED DATE   */
    /* ==================== */

        instance.isDisabledDate = function(date){
            
            /* SCOPE */
            var local = {};
            
            /* DEFINE DEFAULT RETURN */
            local.return = false;
            
            /* GET DISABLED DATES */
            if(instance.disabled_dates === undefined){
                instance.disabled_dates = instance.getDisabledDates();
            }
            
            local.disabled_dates_count = instance.disabled_dates.length;
            
            /* CONSTRUCT DATE */
            local.month = date.getMonth() + 1;
            local.day = date.getDate();
            local.year = date.getFullYear();
            local.date = local.month + '-' + local.day + '-' + local.year;
            
            /* LOOP THROUGH EACH DISABLED DATE */
            for(i = 0; i < local.disabled_dates_count; i++){
                
                /* CHECK IF DATE MATCHES DISABLED DATE */
                if($.inArray(local.date, instance.disabled_dates) != -1){
                    local.return = true;
                }
                
            }
            
            return local.return;
            
        }
        
        
    /* =================== */
    /*   BEFORE SHOW DAY   */
    /* =================== */
        
        instance.beforeShowDay = function(date){
            
            /* SCOPE */
            var local = {};
            
            /* DEFINE DEFAULT STATE */
            local.return = false;

            if(
                   $.datepicker.noWeekends(date)[0]                 /* DATE NOT A WEEKEND */
                && instance.disabled_dates != "error"               /* AJAX CALL WAS SUCCESSFUL */
                && !instance.isDisabledDate(date)                   /* DATE NOT DISABLED */
                && date > new Date()                                /* DATE NOT BEFORE TODAY */
                && date > datepicker.sis_completion_date            /* DATE NOT BEFORE SIS COMPLETION DATE */
            ){
                local.return = true;
            }
            
            /* MUST WRAP IN AN ARRAY */
            return [local.return];
        }

})(jQuery);