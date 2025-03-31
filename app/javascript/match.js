$(document).ready(function() {
	$(document).on('click', '#save-button', function(event) {
     event.preventDefault(); // Prevent default action
     var form = $(this).closest('form'); // Find the closest form
     var formData = form.serialize(); // Serialize form data
     $.ajax({
         url: form.attr("action"), // Get form action URL
         type: "PUT", // Set request type to PUT (matches form method)
         data: formData,
         success: function(data) {
          $("#partial_reload_match_info").html(data.partial_html);
          window.location.reload();
         },
         error: function(jqXHR, textStatus, errorThrown) {
             // Handle errors (e.g., display error message)
         }
     });

     // Close the modal using Bootstrap's hide method
     $(".modal").modal('hide');
   });

  $(document).on('click', '#match_handicap_form', function(event) {
     event.preventDefault(); // Prevent default action
     var form = $(this).closest('form'); // Find the closest form
     var formData = form.serialize(); // Serialize form data
     var matchId = $("#match_form").attr("action").split("/").pop();
     formData += "&match_id=" + matchId;
     $.ajax({
         url: form.attr("action"), // Get form action URL
         type: "PUT", // Set request type to PUT (matches form method)
         data: formData,
         success: function(data) {
           // Handle successful response (e.g., update UI, display success message)
          $("#partial_reload_match_info").html(data.partial_html);
          // alert('Update match details');
          window.location.reload();
         },
         error: function(jqXHR, textStatus, errorThrown) {
           // Handle errors (e.g., display error message)
         }
     });
     $(".modal").modal('hide');
  });

	$(document).on('click', '#change-captain', function(event) {
     event.preventDefault(); // Prevent default action
     var form = $(this).closest('form'); // Find the closest form
     var formData = form.serialize(); // Serialize form data
     var matchId = $("#match_form").attr("action").split("/").pop();
     formData += "&match_id=" + matchId;
     $.ajax({
         url: form.attr("action"), // Get form action URL
         type: "PUT", // Set request type to PUT (matches form method)
         data: formData,
         success: function(data) {
           // Handle successful response (e.g., update UI, display success message)
					$("#partial_reload_match_info").html(data);
         },
         error: function(jqXHR, textStatus, errorThrown) {
           // Handle errors (e.g., display error message)
         }
     });
     $(".modal").modal('hide');
   });

  function validScores() {
    let valid = true;
    $('.form-control.score').each(function() {
      const value = $(this).val();
      if (value === '' || parseInt(value) === 0) {
        $(this).addClass('isInvalid');
        valid = false;
      } else {
        $(this).removeClass('isInvalid');
      }
    });
    return valid
  }

  $(document).on('submit', '#matchScoreForm', function(event) {
    const valid = validScores();
    if (!valid) {
      event.preventDefault();
      $(".invalidScores").text('Please enter a valid score (non-zero and non-empty) for all players.');
    }
  });

  $(document).on('change', '.form-control.score', function(event) {
    const valid = validScores();
    if (event.target.value != 0 && valid) {
      $('.submit-score-card').removeAttr('disabled');
    }
  });

  // console.log('datepicker and select')
  jQuery("#datetimepicker").datetimepicker();
  function formatState(state) {
    if (!state.id) {
      return state.text;
    }
    var $state = $(
      '<span><img src="' +
        $(state.element).attr("data-src") +
        '" class="img-flag" /> ' +
        state.text +
        "</span>"
    );
    return $state;
  }
  $("select.custom").select2({
    minimumResultsForSearch: Infinity,
    templateResult: formatState,
    templateSelection: formatState,
  });
});