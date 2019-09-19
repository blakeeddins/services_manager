(function($, undefined){
    
    /* ============================================================================================= */
    /* ============================================================================================= */
    /* =============================================================================================  /
    
    
            TITLE _____________ /service/form/service_queue.js
            AUTHORS ___________ Blake Eddins
    
    
    /  ============================================================================================= */
    /* ============================================================================================= */
    /* ============================================================================================= */


    /* SCOPE INSTANCE */
    var instance = {};
    
    /* DEFINE Service QUEUE DATA */
    instance.data = {};
        
    /* ============== */
    /*   INIT QUEUE   */
    /* ============== */
    
        $(document).ready(function(){
            
            /* ADD ON CLOSE FUNCTIONALITY TO DATE PICKER */
            $('input[name="scheduled_date"]').datepicker(
                "option",
                "onClose",
                instance.reserveDate
            );
            
            /* ADD ON CHANGE FUNCTIONALITY TO TYPE SELECT */
            $('select[name="type"]').change(
                instance.reserveDate
            );
            
        });
            
        
        
    /* =========================== */
    /*   CHECK DATE AVAILABILITY   */
    /* =========================== */
    
        instance.reserveDate = function(){
        
            var local = {};
            
            /* DEFINE QUEUE DATA */
            instance.data.scheduled_date = $('input[name="scheduled_date"]').val();
            instance.data.uuid = $('input[name="uuid"]').val();
            
            /* TYPE ID AND MINUTES TO COMPLETE ARE SET IN THE VALUE
               OF THE SELECT AS {TYPE ID|MINUTES TO COMPLETE} SO
               WE SPLIT THEM AND DEFINE THEM AS THEIR OWN VARIABLES */
            local.type = $('select[name="type"]').val();
            local.type = local.type.split('|');

            instance.data.type_id = local.type[0];
            instance.data.minutes_to_complete = local.type[1];
            
            
            /* VERIFY THAT TYPE AND DATE ARE SET BEFORE CHECKING */
            if(instance.data.type_id.length
            && instance.data.minutes_to_complete.length
            && instance.data.scheduled_date.length){

                $.ajax({
                    url: "../services/app/cfml/controller/service_queue.cfc?"
                       + "method=reserveRemote",
                    type: "POST",
                    data: instance.data,
                    beforeSend: function(){
                    
                      /* SAVE BUTTON'S CURRENT VALUE */
                      instance.save_button_value = $('.save_button').val();                      
                      
                      /* DISABLE SAVE BUTTON UNTIL DATE HAS BEEN CHECKED AND RESERVED */
                      $('.save_button').prop('disabled', true)
                                       .attr('value','Reservation In Progress');
                      
                        
                    },
                    success: function(data){
                    
                        var local = {}; 
                        
                        local.response = $.parseJSON(data)["RESPONSE"];
                        
                        /* DISPLAY SUCCESS MESSAGE */
                        $('#app_response').text(local.response["TEXT"])
                                          .addClass(local.response["TYPE"])
                                          .removeClass('hide')
                                          .removeClass('exception')
                                          .removeClass('success');
                        $('html, body').animate({ scrollTop: 0 }, 'slow');
                                                
                        /* RE-ENABLE SAVE BUTTON */
                        $('.save_button').attr('value', instance.save_button_value)
                                         .prop('disabled', false);
                        
                    }
                });

            }
            
        }

})(jQuery);
