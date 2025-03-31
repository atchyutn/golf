$(document).ready(function() {
	$(document).on('click', '#invite_form', function(event) {
    event.preventDefault(); // Prevent the default form submission
    var formData = $(this.form).serialize(); // Serialize form data
    if ($(this.form).find('[name="invitation[invitee_email]"]').val().trim() === '') {
      $('#user-present').text('Enter email address')
      return; // Prevent form submission
    }
    $.ajax({
      type: 'POST',
      url: $(this.form).attr('action'),
      data: formData,
      success: function(response) {
      	$('.team-page').html(response)
        // Handle successful form submission
        $(".invite-sent").text("Invite sent")
        // window.location.reload();
      },
      error: function(xhr, status, error) {
      	var errorMessage = xhr.responseJSON.message;
      	 $('#user-present').text(errorMessage);
      }
    });
  });
});